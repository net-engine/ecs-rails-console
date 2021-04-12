require "optparse"
$LOAD_PATH.push File.expand_path("../", __dir__)

module EcsRailsConsole
  class CommandOptions
    class Options
      attr_accessor :environment, :command

      def initialize
        @environment = "production"
        @command = "bin/rails console"
      end

      def [](symbol)
        send symbol
      end

      def define_options(parser)
        parser.banner = "Usage: esc_rails_console [options]"
        parser.separator ""
        parser.separator "Specific Options:"

        generate_config(parser)
        set_environment(parser)

        parser.separator ""
        parser.separator "Common Options:"
        tail_options(parser)
      end

      private

      def set_environment(parser)
        parser.on("-eENVIRONMENT", "--environment=ENVIRONMENT", "Rails environment") do |e|
          @environment = e
        end
      end

      def generate_config(parser)
        parser.on("-g", "--generate-config", "Generate config file") do
          template = File.expand_path("../../config/ecs_rails_console.yml", __dir__)
          config_file = "config/ecs_rails_console.yml"

          if File.exist?(config_file)
            puts "Configuration file already exists and will be kept untouched."
          else
            FileUtils.mkdir_p(File.dirname(config_file))
            FileUtils.cp(template, "#{Dir.pwd}/#{config_file}")
            puts "File generated: #{config_file}"
          end
          exit
        end
      end

      def tail_options(parser)
        parser.on_tail("-h", "--help", "Display this help") do
          puts parser
          exit
        end

        parser.on_tail("-v", "--version", "Display version") do
          require "ecs_rails_console/version"
          puts EcsRailsConsole::VERSION
          exit
        end
      end
    end

    def parse(args)
      @options = Options.new
      @args = OptionParser.new do |parser|
        @options.define_options(parser)
        parser.parse!(args)
      end
      @options
    rescue OptionParser::InvalidOption => e
      puts e
      puts
      puts @args
      exit
    end

    attr_reader :options, :parser
  end
end
