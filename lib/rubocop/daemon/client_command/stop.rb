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
    module ClientCommand
      class Stop < Base
        def run
          return unless check_running_server

          parser.parse(@argv)
          send_request(command: 'stop')
          Daemon.wait_for_running_status!(false)
        end

        private

        def parser
          @parser ||= CLI.new_parser do |p|
            p.banner = 'usage: rubocop-daemon stop'
          end
        end
      end
    end
  end
end
