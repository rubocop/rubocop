# frozen_string_literal: true

require_relative 'platform'

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
  # The bootstrap module for server.
  # @api private
  module Server
    TIMEOUT = 20

    # Options that start a long-lived protocol server on stdio in the current process.
    # They must never be forwarded to the server process, which would run them as
    # a lint request and silently produce no protocol response.
    IN_PROCESS_PROTOCOL_OPTIONS = %w[--lsp --mcp].freeze

    autoload :CLI, 'rubocop/server/cli'
    autoload :Cache, 'rubocop/server/cache'
    autoload :ClientCommand, 'rubocop/server/client_command'
    autoload :Helper, 'rubocop/server/helper'
    autoload :Core, 'rubocop/server/core'
    autoload :ServerCommand, 'rubocop/server/server_command'
    autoload :SocketReader, 'rubocop/server/socket_reader'

    class << self
      def support_server?
        RUBY_ENGINE == 'ruby' && !RuboCop::Platform.windows?
      end

      def running?
        return false unless support_server? # Never running.

        Cache.pid_running?
      end

      # Whether the invocation should be forwarded to the running server process.
      # `--lsp` and `--mcp` always run in the current process even when the server is running:
      # they serve a protocol on stdio, which the server's `exec` command cannot do.
      def forward_to_server?(argv = ARGV)
        return false unless running?

        (IN_PROCESS_PROTOCOL_OPTIONS & argv).empty?
      end

      def wait_for_running_status!(expected)
        start_time = Time.now
        while Server.running? != expected
          sleep 0.1
          next unless Time.now - start_time > TIMEOUT

          warn "running? was not #{expected} after #{TIMEOUT} seconds!"
          exit 1
        end
      end
    end
  end
end

require_relative 'server/errors'
