# frozen_string_literal: true

require 'aws-sdk-ecs'
require 'aws-sdk-ec2'

module EcsRailsConsole
  class Core
    private

    def ecs_client
      @ecs_client ||= Aws::ECS::Client.new(aws_credentials)
    end

    def ec2_client
      @ec2_client ||= Aws::EC2::Client.new(aws_credentials)
    end

    def vpc_id
      @vpc_id ||= begin
        id = ec2_client.describe_vpcs(
          {
            filters: [{
              name: 'tag:aws:cloudformation:stack-name',
              values: ["#{cluster_name}InfraStack"]
            }]
          }
        )[:vpcs].map(&:vpc_id).first
        abort 'Could not find VPC' if id.empty?

        id
      end
    end

    def subnet_ids(vpc_id)
      @subnet_ids ||= begin
        ids = ec2_client.describe_subnets(
          {
            filters: [
              { name: 'vpc-id', values: [vpc_id] },
              { name: 'tag:aws-cdk:subnet-type', values: ['Public'] }
            ]
          }
        )[:subnets].map(&:subnet_id)
        abort 'Could not find subnets' if ids.empty?

        ids
      end
    end

    def console_security_group_ids(vpc_id)
      @console_security_group_ids ||= begin
        ids = ec2_client.describe_security_groups(
          filters: [
            { name: 'vpc-id', values: [vpc_id] },
            { name: 'group-name',
              values: config['security_groups'] }
          ]
        )[:security_groups].map(&:group_id)
        abort 'Could not find security groups' if ids.empty?

        ids
      end
    end

    def task_definition
      @task_definition ||= begin
        task_definition_name_regex = %r{.*/(#{config['task_definition']}):\d+}
        task_definitions = ecs_client.list_task_definitions(status: 'ACTIVE')
        definition_arn = task_definitions[:task_definition_arns].detect do |arn|
          arn.match(task_definition_name_regex)
        end
        abort 'Could not find console task definition' if definition_arn.empty?

        definition_arn.match(task_definition_name_regex).captures.first
      end
    end

    def run_task
      task = ecs_client.run_task(
        {
          cluster: cluster_name,
          launch_type: 'FARGATE',
          task_definition: task_definition,
          network_configuration: {
            awsvpc_configuration: {
              subnets: subnet_ids(vpc_id),
              security_groups: console_security_group_ids(vpc_id),
              assign_public_ip: 'ENABLED'
            }
          }
        }
      )[:tasks].first

      task_id = task[:task_arn].match(%r{.*/(\w+)$}).captures.first

      ecs_client.wait_until(:tasks_running,
                            {
                              cluster: cluster_name,
                              tasks: [task_id]
                            })[:tasks].first
    end

    def get_public_ip(task_description)
      network_interface_id = task_description[:attachments]
                             .first[:details]
                             .detect { |detail| detail[:name] == 'networkInterfaceId' }[:value]

      ec2_client.describe_network_interfaces(
        network_interface_ids: [
          network_interface_id
        ]
      )[:network_interfaces].first[:association][:public_ip]
    end

    def cluster_name
      @cluster_name ||= config['cluster_name']
    end
  end
end
