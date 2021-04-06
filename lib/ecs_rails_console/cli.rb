# frozen_string_literal: true

require "bundler/setup"
require "yaml"

module EcsRailsConsole
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
    end

    private

    attr_reader :environment

    def aws_credentials
      config.slice(
        "profile",
        "access_key_id",
        "secret_access_key",
        "region"
      ).transform_keys(&:to_sym)
    end

    def config
      @config ||= YAML.load_file(config_file_from_project)[environment] || {}
    end

    def config_file_from_project
      "#{Dir.pwd}/config/ecs_rails_console.yml"
    end
  end
end
