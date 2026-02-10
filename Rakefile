# frozen_string_literal: true

require 'bridgetown'

Bridgetown.load_tasks

# Run rake without specifying any command to execute a deploy build by default.
task default: :deploy

#
# Standard set of tasks, which you can customize if you wish:
#
desc 'Build the Bridgetown site for deployment'
task deploy: [:clean, 'frontend:build'] do
  Bridgetown::Commands::Build.start
end

desc 'Build the site in a test environment'
task :test do
  ENV['BRIDGETOWN_ENV'] = 'test'
  Bridgetown::Commands::Build.start
end

desc 'Runs the clean command'
task :clean do
  Bridgetown::Commands::Clean.start
end

namespace :frontend do
  desc 'Build the frontend with esbuild for deployment'
  task :build do
    sh 'touch frontend/styles/jit-refresh.css'
    sh 'npm run esbuild'
  end

  desc 'Watch the frontend with esbuild during development'
  task :dev do
    sh 'touch frontend/styles/jit-refresh.css'
    sh 'npm run esbuild-dev'
  rescue Interrupt
  end
end
