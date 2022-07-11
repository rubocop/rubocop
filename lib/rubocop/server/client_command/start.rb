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
  module Server
    module ClientCommand
      # This class is a client command to start server process.
      # @api private
      class Start < Base
        def run
          if Server.running?
            warn "RuboCop server (#{Cache.pid_path.read}) is already running."
            return
          end

          # if we're a spawned server process, the spawner already has the lock
          # and we can't acquire it recursively
          return start if ENV['RUBOCOP_SERVER_SPAWNED']

          Cache.acquire_lock do |locked|
            unless locked
              # Another process is already starting server,
              # so wait for it to be ready.
              Server.wait_for_status! { Server.running? && Server.listening? }
              exit 0
            end

            start
          end
        end

        private

        def start
          Cache.write_version_file(RuboCop::Version::STRING)

          host = ENV.fetch('RUBOCOP_SERVER_HOST', '127.0.0.1')
          port = ENV.fetch('RUBOCOP_SERVER_PORT', 0)

          Server::Core.new.start(host, port)
        end
      end
    end
  end
end
