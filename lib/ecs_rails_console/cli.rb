# frozen_string_literal: true

require 'bundler/setup'
require 'yaml'

module EcsRailsConsole
  CONFIG_FILE = "#{Dir.pwd}/config/ecs_rails_console.yml"

  class Cli < Core
    def self.run!(options)
      new(options).run!
    end

    def initialize(options)
      super()
      @environment = options[:environment]
    end

    def run!
      puts "Cluster name: #{cluster_name}"

      task_description = run_task

      public_ip = get_public_ip(task_description)

      puts "it is running on: #{public_ip}"

      system("ssh -tq -oStrictHostKeyChecking=no root@#{public_ip} 'cd /app ; bin/rails console'")
    rescue Aws::ECS::Errors::ExpiredTokenException
      puts "\nHey, it seems your token expired. Authenticate on AWS give another try."
    end

    private

    attr_reader :environment

    def aws_credentials
      config.slice(
        'profile',
        'access_key_id',
        'secret_access_key',
        'region'
      ).transform_keys(&:to_sym)
    end

    def config
      @config ||= YAML.load_file(CONFIG_FILE)[environment] || {}
    end
  end
end
