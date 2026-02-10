# frozen_string_literal: true

# Puma is a fast, concurrent web server for Ruby & Rack
#
# Learn more at: https://puma.io
# Bridgetown configuration documentation:
# https://www.bridgetownrb.com/docs/configuration/puma

# This port number typically gets overridden by Bridgetown's boot & config loader
# so you probably don't want to touch the number here
#
port ENV.fetch('BRIDGETOWN_PORT', 4000)

# You can adjust the number of workers (separate processes) and threads
# (per process) based on your production system
#
workers ENV.fetch('BRIDGETOWN_CONCURRENCY', 4) if ENV['BRIDGETOWN_ENV'] == 'production'

max_threads_count = ENV.fetch('BRIDGETOWN_MAX_THREADS', 5)
min_threads_count = ENV.fetch('BRIDGETOWN_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

pidfile ENV['PIDFILE'] || 'tmp/pids/server.pid'

# Preload the application for maximum performance
#
preload_app!

# Use the Bridgetown logger format
#
require 'bridgetown-core/rack/logger'
log_formatter do |msg|
  Bridgetown::Rack::Logger.message_with_prefix msg
end
