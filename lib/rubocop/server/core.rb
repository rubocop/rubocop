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
        return start_spawned(host, port) if ENV['RUBOCOP_SERVER_SPAWNED']

        require 'rubocop' if forking?
        start_server(host, port)

        demonize if server_mode?
      end

      private

      def forking?
        RUBY_ENGINE == 'ruby' && !RuboCop::Platform.windows?
      end

      def demonize
        Cache.write_port_and_token_files(port: @server.addr[1], token: token)

        if forking?
          pid = fork do
            $PROGRAM_NAME = "rubocop --server #{Cache.project_dir}"
            Process.daemon(true)
            Cache.write_pid_file do
              read_socket(@server.accept) until @server.closed?
            end
          end

          Process.waitpid(pid)
        else
          spawn_server
        end
      end

      def ruby_exe
        ruby = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])

        ruby.gsub! File::SEPARATOR, File::ALT_SEPARATOR if File::ALT_SEPARATOR

        ruby
      end

      def spawn_server
        host = @server.addr[3]
        port = @server.addr[1]
        @server.close
        pid = spawn({ 'RUBOCOP_SERVER_SPAWNED' => 'true',
                      'RUBOCOP_SERVER_HOST' => host,
                      'RUBOCOP_SERVER_PORT' => port.to_s },
                    ruby_exe, $PROGRAM_NAME, '--start-server')
        Process.detach(pid)
        Server.wait_for_status! { Server.listening? }
      end

      # actually run a server in this process that started in another process
      def start_spawned(host, port)
        $PROGRAM_NAME = "rubocop --server #{Cache.project_dir}"

        # We're a background process now, so need to ignore Ctrl-C
        # from the foreground
        trap('SIGINT') { nil } if RuboCop::Platform.windows?

        require 'rubocop'
        @server = TCPServer.new(host, port.to_i)

        Cache.write_pid_file do
          read_socket(@server.accept) until @server.closed?
        end
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
