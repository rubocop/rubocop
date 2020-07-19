# frozen_string_literal: true

require 'yard'
require 'rubocop'
require 'rubocop/cops_documentation_generator'

YARD::Rake::YardocTask.new(:yard_for_generate_documentation) do |task|
  task.files = ['lib/rubocop/cop/*/*.rb']
  task.options = ['--no-output']
end

desc 'Generate docs of all cops departments'
task generate_cops_documentation: :yard_for_generate_documentation do
  deps = %w[Bundler Gemspec Layout Lint Metrics Migration Naming Security Style]
  CopsDocumentationGenerator.new(departments: deps).call
end

desc 'Verify that documentation is up to date'
task verify_cops_documentation: :generate_cops_documentation do
  # Do not print diff and yield whether exit code was zero
  sh('git diff --quiet docs') do |outcome, _|
    exit if outcome

    # Output diff before raising error
    sh('GIT_PAGER=cat git diff docs')

    warn 'The docs directory is out of sync. ' \
      'Run `rake generate_cops_documentation` and commit the results.'
    exit!
  end
end
