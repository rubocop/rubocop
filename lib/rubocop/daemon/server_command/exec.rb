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
    module ServerCommand
      class Exec < Base
        def run
          Cache.status_path.delete if Cache.status_path.file?
          # RuboCop output is colorized by default where there is a TTY.
          # We must pass the --color option to preserve this behavior.
          @args.unshift('--color') unless %w[--color --no-color].any? { |f| @args.include?(f) }
          status = RuboCop::CLI.new.run(@args)
          # This status file is read by `rubocop-daemon exec` and `rubocop-daemon-wrapper`,
          # so that they use the correct exit code.
          # Status is 1 when there are any issues, and 0 otherwise.
          Cache.write_status_file(status)
        rescue SystemExit
          Cache.write_status_file(1)
        end
      end
    end
  end
end
