# frozen_string_literal: true

require 'optparse'

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
    class CLI
      def self.new_parser(&_block)
        OptionParser.new do |opts|
          yield(opts)
        end
      end

      def run(argv = ARGV)
        parser.order!(argv)
        return if argv.empty?

        create_subcommand_instance(argv)
      rescue OptionParser::InvalidOption => e
        warn "error: #{e.message}"
        exit 1
      rescue UnknownClientCommandError => e
        warn "rubocop-daemon: #{e.message}. See 'rubocop-daemon --help'."
        exit 1
      end

      def parser
        @parser ||= self.class.new_parser do |opts|
          opts.banner = 'usage: rubocop-daemon <command> [<args>]'
        end
      end

      private

      def create_subcommand_instance(argv)
        subcommand, *args = argv
        find_subcommand_class(subcommand).new(args).run
      end

      def find_subcommand_class(subcommand)
        case subcommand
        when 'exec' then ClientCommand::Exec
        when 'restart' then ClientCommand::Restart
        when 'start' then ClientCommand::Start
        when 'status' then ClientCommand::Status
        when 'stop' then ClientCommand::Stop
        else
          raise UnknownClientCommandError, "#{subcommand.inspect} is not a rubocop-daemon command"
        end
      end
    end
  end
end
