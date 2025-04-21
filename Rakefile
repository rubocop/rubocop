# frozen_string_literal: true

# For code coverage measurements to work properly, `SimpleCov` should be loaded
# and started before any application code is loaded.
require 'simplecov' if ENV['COVERAGE']

require 'bundler'
require 'bundler/gem_tasks'

# Remove the default release task
Rake::Task['release'].clear

desc 'Build gem into the pkg directory, create git tag and push the tag only (no gem push)'
task :release do
  gem_helper = Bundler::GemHelper.instance

  # Access the gem specification
  gemspec = gem_helper.gemspec
  version = gemspec.version

  # Build the gem (equivalent to `rake build`)
  Rake::Task['build'].invoke

  # Create a git tag with the version (prefixed with 'v')
  sh "git tag -a -m \"Version #{version}\" v#{version}"

  # Push git tag to remote
  sh "git push origin v#{version}"

  puts "Tagged and pushed v#{version} - the release workflow will now begin"
end

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
task default: %i[codespell documentation_syntax_check spec prism_spec internal_investigation]

require 'yard'
YARD::Rake::YardocTask.new

desc 'Syntax check for the documentation comments'
task documentation_syntax_check: :yard_for_generate_documentation do
  require 'parser/ruby25'
  require 'parser/ruby26'
  require 'parser/ruby27'

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
                 Prism::Translation::Parser35.new(RuboCop::AST::BuilderPrism.new)
               end
      parser.diagnostics.all_errors_are_fatal = true
      parser.parse(buffer)
    rescue Parser::SyntaxError => e
      path = example.object.file
      line, column = buffer.decompose_position(e.diagnostic.location.begin_pos)
      indentation = ' ' * column
      highlight = '^' * Unicode::DisplayWidth.of(e.diagnostic.location.source)

      warn Rainbow(<<~MESSAGE).red
        #{path}:#{line}:#{column} Syntax Error in an example: #{e}
        #{buffer.source_lines[line - 1]}
        #{indentation + highlight}
      MESSAGE

      ok = false
    end
  end
  abort unless ok
end
