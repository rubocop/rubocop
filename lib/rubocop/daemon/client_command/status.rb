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
      class Status < Base
        def run
          parser.parse(@argv)

          if Daemon.running?
            puts 'rubocop-daemon is running.'
          else
            puts 'rubocop-daemon is not running.'
          end
        end

        private

        def parser
          @parser ||= CLI.new_parser do |p|
            p.banner = 'usage: rubocop-daemon status'
          end
        end
      end
    end
  end
end
