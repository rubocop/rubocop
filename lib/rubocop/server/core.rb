# frozen_string_literal: true

require 'socket'
require 'securerandom'

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
    # The core of server process. It starts TCP server and perform socket communication.
    # @api private
    class Core
      def self.token
        @token ||= SecureRandom.hex(4)
      end

      def token
        self.class.token
      end

      def start(host, port)
        $PROGRAM_NAME = "rubocop --server #{Cache.project_dir}"

        require 'rubocop'
        start_server(host, port)

        demonize if server_mode?
      end

      private

      def demonize
        Cache.write_port_and_token_files(port: @server.addr[1], token: token)

        pid = fork do
          Process.daemon(true)
          Cache.write_pid_file do
            read_socket(@server.accept) until @server.closed?
          end
        end

        Process.waitpid(pid)
      end

      def server_mode?
        true
      end

      def start_server(host, port)
        @server = TCPServer.open(host, port)

        puts "RuboCop server starting on #{@server.addr[3]}:#{@server.addr[1]}."
      end

      def read_socket(socket)
        SocketReader.new(socket).read!
      rescue InvalidTokenError
        socket.puts 'token is not valid.'
      rescue ServerStopRequest
        @server.close
      rescue UnknownServerCommandError => e
        socket.puts e.message
      rescue Errno::EPIPE => e
        warn e.inspect
      rescue StandardError => e
        socket.puts e.full_message
      ensure
        socket.close
      end
    end
  end
end
