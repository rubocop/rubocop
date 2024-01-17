# frozen_string_literal: true

require 'bundler/inline'
require 'tempfile'
require 'tmpdir'
require 'yaml'

# Generates a JSON schema that includes core cops as well as a number of
# extensions.

known_extensions = [
  # Official
  'rubocop-performance',
  'rubocop-rails',
  'rubocop-rspec',
  'rubocop-minitest',
  'rubocop-rake',
  'rubocop-sequel',
  'rubocop-thread_safety',
  'rubocop-capybara',
  'rubocop-factory_bot',
  # Third-party
  'rubocop-require_tools',
  'rubocop-i18n',
  'rubocop-packaging',
  'rubocop-sorbet',
  'rubocop-graphql'
  # 'rubocop-sketchup',
]

gemfile do
  source 'https://rubygems.org'
  gem 'rubocop', path: File.expand_path('..', __dir__)
  known_extensions.each { |extension| gem(extension, require: false) }
end

JS = RuboCop::CLI::Command::JSONSchema

config_contents = { 'require' => known_extensions }
cfg = JS::Configurer.load_stripped_config(config_contents)
builder = JS::SchemaBuilder.new(cfg)
schema_path = File.expand_path('../assets/schema.json', __dir__)
File.write(schema_path, JSON.pretty_generate(builder.build_json_schema))
