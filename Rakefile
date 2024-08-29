# frozen_string_literal: true

# For code coverage measurements to work properly, `SimpleCov` should be loaded
# and started before any application code is loaded.
require 'simplecov' if ENV['COVERAGE']

desc 'Check for no pending changelog entries before release'
task release: 'changelog:check_clean' # Before task is required

require 'bundler'
require 'bundler/gem_tasks'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'
require 'rubocop/rake_task'

Dir['tasks/**/*.rake'].each { |t| load t }

desc 'Run RuboCop over itself'
RuboCop::RakeTask.new(:internal_investigation)

# The `ascii_spec` task has not been failing for a while, so it will not be run by default.
# However, `ascii_spec` task will continue to be checked in CI. If there are any failures
# originating from `ascii_spec` in CI, please run `bundle exec ascii_spec` to investigate.
task default: %i[documentation_syntax_check spec prism_spec internal_investigation]

require 'yard'
YARD::Rake::YardocTask.new

desc 'Syntax check for the documentation comments'
task documentation_syntax_check: :yard_for_generate_documentation do
  require 'parser/ruby25'
  require 'parser/ruby26'
  require 'parser/ruby27'
  require 'parser/ruby34'

  ok = true
  YARD::Registry.load!
  cops = RuboCop::Cop::Registry.global
  cops.each do |cop|
    next if %i[RSpec Capybara FactoryBot].include?(cop.department)

    examples = YARD::Registry.all(:class).find do |code_object|
      next unless RuboCop::Cop::Badge.for(code_object.to_s) == cop.badge

      break code_object.tags('example')
    end

    examples.each do |example|
      buffer = Parser::Source::Buffer.new('<code>', 1)
      buffer.source = example.text

      # Ruby 2.6 or higher does not support a syntax used in
      # `Lint/UselessElseWithoutRescue` cop's example.
      parser = if cop == RuboCop::Cop::Lint::UselessElseWithoutRescue
                 Parser::Ruby25.new(RuboCop::AST::Builder.new)
               # Ruby 2.7 raises a syntax error in
               # `Lint/CircularArgumentReference` cop's example.
               elsif cop == RuboCop::Cop::Lint::CircularArgumentReference
                 Parser::Ruby26.new(RuboCop::AST::Builder.new)
               # Ruby 3.0 raises a syntax error in
               # `Lint/NumberedParameterAssignment` cop's example.
               elsif cop == RuboCop::Cop::Lint::NumberedParameterAssignment
                 Parser::Ruby27.new(RuboCop::AST::Builder.new)
               else
                 Parser::Ruby34.new(RuboCop::AST::Builder.new)
               end
      parser.diagnostics.all_errors_are_fatal = true
      parser.parse(buffer)
    rescue Parser::SyntaxError => e
      path = example.object.file
      puts "#{path}: Syntax Error in an example. #{e}"
      ok = false
    end
  end
  abort unless ok
end
