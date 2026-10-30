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
      # This class is a client command to stop server process.
      # @api private
      class Stop < Base
        def run
          return unless check_running_server

          server_pid = Cache.pid
          client_pid = fork do
            send_request(command: 'stop')
            if server_pid
              Server.wait_for_process_exit!(server_pid)
            else
              Server.wait_for_running_status!(false)
            end
          end

          Process.waitpid(client_pid)
        end
      end
    end
  end
end
