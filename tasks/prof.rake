# frozen_string_literal: true

namespace :prof do
  DUMP_PATH = 'tmp/stackprof.dump'

  desc 'Run RuboCop on itself with profiling on'
  task :run, [:path] do |_task, args|
    path = args.fetch(:path, '.')
    cmd = "bin/rubocop-profile #{path}"
    system cmd
  end

  task :run_if_needed, [:path] do
    Rake::Task[:run].run unless File.exist?(DUMP_PATH)
  end

  desc 'List the slowest cops'
  task slow_cops: :run_if_needed do
    method = 'RuboCop::Cop::Commissioner#trigger_responding_cops'
    cmd = "stackprof #{DUMP_PATH} --text --method '#{method}'"
    puts cmd
    output = `#{cmd}`
    _header, list, _code = *output
      .lines
      .grep_v(/RuboCop::Cop::Commissioner/) # ignore internal calls
      .slice_when { |line| line.match?(/callees.*:|code:/) }
    puts list.first(40)
  end

  desc 'Check a particular method by walking through the callstack'
  task :walk, [:method] => :run_if_needed do |_task, args|
    method = args.fetch(:method) do
      warn 'usage: bundle exec rake walk[Class#method]'
      exit!
    end
    cmd = "stackprof #{DUMP_PATH} --walk --method '#{method}'"
    puts cmd
    system cmd
  end
end
