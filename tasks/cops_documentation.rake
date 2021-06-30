# frozen_string_literal: true

require 'yard'
require 'rubocop'
require 'rubocop/cops_documentation_generator'

YARD::Rake::YardocTask.new(:yard_for_generate_documentation) do |task|
  task.files = ['lib/rubocop/cop/*/*.rb']
  task.options = ['--no-output']
end

desc 'Update documentation of all cops'
task update_cops_documentation: :yard_for_generate_documentation do
  deps = %w[Bundler Gemspec Layout Lint Metrics Migration Naming Security Style]
  CopsDocumentationGenerator.new(departments: deps).call
end

desc 'Generate docs of all cops departments (obsolete)'
task :generate_cops_documentation do
  puts 'Updating the documentation is now done automatically!'
end
