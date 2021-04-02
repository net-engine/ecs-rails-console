# ecs-rails-console

A simple tool to run `rails console` or other Rails CLI commands in AWS ECS Fargate.

## Installation

Add the following lines to your Rails application's Gemfile:
```ruby
group :development do
  gem 'ecs-rails-console'
end
```
And then simply execute:

```shell
$ bundle install
```

## Usage

Generate a config file (optional):
```shell
$ bundle exec ecs_rails_console -g
```

This will generate a  `config/ecs_rails_console.yml`  file, which you can customize.

#### Examples:
For `rails console`:
```shell
$ bundle exec ecs_rails_console
```

For `rails db:migrate:status`:
```shell
$ bundle exec ecs_rails_console bin/rails db:migrate:status
```

For help, run:
```shell
$ bundle exec ecs_rails_console -h
Usage: ecs_rails_console [options]
    -g, --generate-config Generate config file
    -h, --help Display this help
    -e, --environment=ENVIRONMENT Rails environment
    -v, --version Display version
```

## Contributing
[Bug reports](https://github.com/net-engine/ecs-rails-console/issues) and [pull requests](https://github.com/net-engine/ecs-rails-console/pulls) are welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org/) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
