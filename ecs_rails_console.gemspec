# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ecs_rails_console/version"

Gem::Specification.new do |s|
  s.name = "ecs-rails-console"
  s.version = EcsRailsConsole::VERSION
  s.authors = ["Eduardo Ramos"]
  s.email = ["ramos.eduardo87@gmail.com"]

  s.summary = "Run Rails Console in AWS ECS"
  s.description = "Provide a way to run Rails Console in a container running on AWS ECS Fargate."
  s.homepage = "http://rubygems.org/gems/ecs-rails-console"
  s.license = "MIT"

  s.files = Dir.glob("{lib,bin}/**/*")
  s.bindir = "bin"
  s.executables = ["ecs_rails_console", "erc"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.7"

  s.add_runtime_dependency "aws-sdk-ec2", "~> 1.227"
  s.add_runtime_dependency "aws-sdk-ecs", "~> 1.75"

  s.add_development_dependency "standard", "~> 1"
end
