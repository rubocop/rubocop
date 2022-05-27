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
      class Exec < Base
        def run
          args = parser.parse(@argv)
          ensure_server!
          Cache.status_path.delete if Cache.status_path.file?
          send_request(
            command: 'exec',
            args: args,
            body: $stdin.tty? ? '' : $stdin.read,
          )
          exit_with_status!
        end

        private

        def parser
          @parser ||= CLI.new_parser do |p|
            p.banner = 'usage: rubocop-daemon exec [options] [files...] [-- [rubocop-options]]'
          end
        end

        def exit_with_status!
          raise "rubocop-daemon: Could not find status file at: #{Cache.status_path}" unless Cache.status_path.file?

          status = Cache.status_path.read
          raise "rubocop-daemon: '#{status}' is not a valid status!" if (status =~ /^\d+$/).nil?

          exit status.to_i
        end
      end
    end
  end
end
