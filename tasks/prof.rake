# frozen_string_literal: true

namespace :prof do
  dump_path = 'tmp/rubocop-stackprof.dump'

  desc 'Run RuboCop on itself with profiling on'
  task :run, [:path] do |_task, args|
    # Must be run `rubocop` with the local process.
    require 'rubocop/server'
    if RuboCop::Server.running?
      RuboCop::Server::ClientCommand::Stop.new.run
      puts 'Stop the server for profiling.'
    end

    path = args.fetch(:path, '.')
    cmd = "exe/rubocop --profile #{path}"
    system cmd
  end

  desc 'Run RuboCop on itself only if dump does not exist'
  task :run_if_needed, [:path] do
    Rake::Task['prof:run'].invoke unless File.exist?(dump_path)
  end

  desc 'List the slowest cops'
  task slow_cops: :run_if_needed do
    method = 'Kernel#public_send'
    cmd = "stackprof #{dump_path} --text --method '#{method}'"
    puts cmd
    output = `#{cmd}`
    list = output.lines.grep(/RuboCop::Cop::.+#on_\w+/)
    puts list.first(40)
  end

  desc 'Check a particular method by walking through the callstack'
  task :walk, [:method] => :run_if_needed do |_task, args|
    method = args.fetch(:method) do
      warn "usage: bundle exec rake 'walk[Class#method]'"
      exit!
    end
    cmd = "stackprof #{dump_path} --walk --method '#{method}'"
    puts cmd
    system cmd
  end
end
