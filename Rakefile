# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'bundler/gem_tasks'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Dir['tasks/**/*.rake'].each { |t| load t }

RSpec::Core::RakeTask.new(:spec) { |t| t.ruby_opts = '-E UTF-8' }
RSpec::Core::RakeTask.new(:ascii_spec) { |t| t.ruby_opts = '-E ASCII' }

desc 'Run test and RuboCop in parallel'
task parallel: %i[parallel:spec parallel:ascii_spec internal_investigation]

namespace :parallel do
  desc 'Run RSpec in parallel'
  task :spec do
    sh('rspec-queue spec/')
  end

  desc 'Run RSpec in parallel with ASCII encoding'
  task :ascii_spec do
    sh('RUBYOPT="-E ASCII" rspec-queue spec/')
  end
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

desc 'Run RuboCop over itself'
RuboCop::RakeTask.new(:internal_investigation).tap do |task|
  if RUBY_ENGINE == 'ruby' &&
     RbConfig::CONFIG['host_os'] !~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    task.options = %w[--parallel]
  end
end

task default: %i[spec ascii_spec internal_investigation]

require 'yard'
YARD::Rake::YardocTask.new

desc 'Open a REPL for experimentation'
task :repl do
  require 'pry'
  require 'rubocop'
  ARGV.clear
  RuboCop.pry
end

desc 'Benchmark a cop on given source file/dir'
task :bench_cop, %i[cop srcpath times] do |_task, args|
  require 'benchmark'
  require 'rubocop'
  include RuboCop
  include RuboCop::Formatter::TextUtil

  cop_name = args[:cop]
  src_path = args[:srcpath]
  iterations = args[:times] ? args[:times].to_i : 1

  cop_class = if cop_name.include?('/')
                Cop::Cop.all.find { |klass| klass.cop_name == cop_name }
              else
                Cop::Cop.all.find do |klass|
                  klass.cop_name[/[a-zA-Z]+$/] == cop_name
                end
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

  puts "(#{pluralize(iterations, 'iteration')}, " \
    "#{pluralize(files.size, 'file')})"

  ruby_version = RuboCop::Config::KNOWN_RUBIES.last
  srcs = files.map { |file| ProcessedSource.from_file(file, ruby_version) }

  puts 'Finished parsing source, testing inspection...'
  puts(Benchmark.measure do
    iterations.times do
      commissioner = Cop::Commissioner.new([cop], [])
      srcs.each { |src| commissioner.investigate(src) }
    end
  end)
end
