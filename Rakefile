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

task default: %i[documentation_syntax_check spec ascii_spec internal_investigation]

require 'yard'
YARD::Rake::YardocTask.new

desc 'Benchmark a cop on given source file/dir'
task :bench_cop, %i[cop srcpath times] do |_task, args|
  require 'benchmark'
  require 'rubocop'
  include RuboCop
  include RuboCop::Formatter::TextUtil

  cop_name = args[:cop]
  src_path = args[:srcpath]
  iterations = args[:times] ? Integer(args[:times]) : 1

  cop_class = if cop_name.include?('/')
                Cop::Registry.all.find { |klass| klass.cop_name == cop_name }
              else
                Cop::Registry.all.find { |klass| klass.cop_name[/[a-zA-Z]+$/] == cop_name }
              end
  raise "No such cop: #{cop_name}" if cop_class.nil?

  config = ConfigLoader.load_file(ConfigLoader::DEFAULT_FILE)
  cop = cop_class.new(config)

  puts "Benchmarking #{cop.cop_name} on #{src_path} (using default config)"

  files = if File.directory?(src_path)
            Dir[File.join(src_path, '**', '*.rb')]
          else
            [src_path]
          end

  puts "(#{pluralize(iterations, 'iteration')}, #{pluralize(files.size, 'file')})"

  ruby_version = RuboCop::TargetRuby.supported_versions.last
  srcs = files.map { |file| ProcessedSource.from_file(file, ruby_version) }

  puts 'Finished parsing source, testing inspection...'
  puts(Benchmark.measure do
    iterations.times do
      commissioner = Cop::Commissioner.new([cop], [])
      srcs.each { |src| commissioner.investigate(src) }
    end
  end)
end

desc 'Syntax check for the documentation comments'
task documentation_syntax_check: :yard_for_generate_documentation do
  require 'parser/ruby25'
  require 'parser/ruby26'
  require 'parser/ruby27'
  require 'parser/ruby32'

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
                 Parser::Ruby32.new(RuboCop::AST::Builder.new)
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
