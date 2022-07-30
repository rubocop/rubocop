# frozen_string_literal: true

require 'rainbow'

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
    # The CLI is a class responsible of handling server command line interface logic.
    # @api private
    class CLI
      # Same exit status value as `RuboCop::CLI`.
      STATUS_SUCCESS = 0
      STATUS_ERROR = 2

      SERVER_OPTIONS = %w[
        --server --no-server --server-status --restart-server --start-server --stop-server
      ].freeze
      EXCLUSIVE_OPTIONS = (SERVER_OPTIONS - %w[--server --no-server]).freeze

      def initialize
        @exit = false
      end

      # rubocop:disable Metrics/MethodLength
      def run(argv = ARGV)
        unless Server.support_server?
          return error('RuboCop server is not supported by this Ruby.') if use_server_option?(argv)

          return STATUS_SUCCESS
        end

        Cache.cache_root_path = fetch_cache_root_path_from(argv)
        deleted_server_arguments = delete_server_argument_from(argv)

        if deleted_server_arguments.size >= 2
          return error("#{deleted_server_arguments.join(', ')} cannot be specified together.")
        end

        server_command = deleted_server_arguments.first

        if EXCLUSIVE_OPTIONS.include?(server_command) && argv.count > allowed_option_count
          return error("#{server_command} cannot be combined with other options.")
        end

        run_command(server_command)

        STATUS_SUCCESS
      end
      # rubocop:enable Metrics/MethodLength

      def exit?
        @exit
      end

      private

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength:
      def run_command(server_command)
        case server_command
        when '--server'
          Server::ClientCommand::Start.new.run unless Server.running?
        when '--no-server'
          Server::ClientCommand::Stop.new.run if Server.running?
        when '--restart-server'
          @exit = true
          Server::ClientCommand::Restart.new.run
        when '--start-server'
          @exit = true
          Server::ClientCommand::Start.new.run
        when '--stop-server'
          @exit = true
          Server::ClientCommand::Stop.new.run
        when '--server-status'
          @exit = true
          Server::ClientCommand::Status.new.run
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength:

      def fetch_cache_root_path_from(arguments)
        cache_root = arguments.detect { |argument| argument.start_with?('--cache-root') }
        return unless cache_root

        if cache_root.start_with?('--cache-root=')
          cache_root.split('=')[1]
        else
          arguments[arguments.index(cache_root) + 1]
        end
      end

      def delete_server_argument_from(all_arguments)
        SERVER_OPTIONS.each_with_object([]) do |server_option, server_arguments|
          server_arguments << all_arguments.delete(server_option)
        end.compact
      end

      def use_server_option?(argv)
        (argv & SERVER_OPTIONS).any?
      end

      def allowed_option_count
        Cache.cache_root_path ? 2 : 1
      end

      def error(message)
        @exit = true
        warn Rainbow(message).red

        STATUS_ERROR
      end
    end
  end
end
