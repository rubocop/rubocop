# frozen_string_literal: true

#
# This code is based on https://github.com/fohte/rubocop-daemon.
#
# Copyright (c) 2018 Hayato Kawai
#
# The MIT License (MIT)
#
# https://github.com/fohte/rubocop-daemon/blob/master/LICENSE.txt
#
module RuboCop
  module Daemon
    TIMEOUT = 20

    autoload :CLI, 'rubocop/daemon/cli'
    autoload :Cache, 'rubocop/daemon/cache'
    autoload :ClientCommand, 'rubocop/daemon/client_command'
    autoload :Helper, 'rubocop/daemon/helper'
    autoload :Server, 'rubocop/daemon/server'
    autoload :ServerCommand, 'rubocop/daemon/server_command'
    autoload :SocketReader, 'rubocop/daemon/socket_reader'

    def self.running?
      Cache.dir.exist? && Cache.pid_path.file? && Cache.pid_running?
    end

    def self.wait_for_running_status!(expected)
      start_time = Time.now
      while Daemon.running? != expected
        sleep 0.1
        next unless Time.now - start_time > TIMEOUT

        warn "running? was not #{expected} after #{TIMEOUT} seconds!"
        exit 1
      end
    end
  end
end

require 'rubocop/daemon/errors'
