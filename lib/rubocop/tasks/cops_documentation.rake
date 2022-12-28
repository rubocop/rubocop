# frozen_string_literal: true

require 'rubocop'
require 'rubocop/cops_documentation_generator'
require 'yard'

YARD::Rake::YardocTask.new(:yard_for_generate_documentation) do |task|
  task.files = ['lib/rubocop/cop/*/*.rb']
  task.options = ['--no-output']
end

desc 'Update documentation of all cops'
task update_cops_documentation: :yard_for_generate_documentation do
  deps = %w[Bundler Gemspec Layout Lint Metrics Migration Naming Security Style]
  CopsDocumentationGenerator.new(departments: deps).call
end
