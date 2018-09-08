# frozen_string_literal: true

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) { |t| t.ruby_opts = '-E UTF-8' }
RSpec::Core::RakeTask.new(:ascii_spec) { |t| t.ruby_opts = '-E ASCII' }

namespace :parallel do
  desc 'Run RSpec in parallel'
  task :spec do
    sh('rspec-queue spec/')
  end

  desc 'Run RSpec in parallel with ASCII encoding'
  task :ascii_spec do
    sh('RUBYOPT="$RUBYOPT -E ASCII" rspec-queue spec/')
  end
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
