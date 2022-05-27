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
      autoload :Base, 'rubocop/daemon/client_command/base'
      autoload :Exec, 'rubocop/daemon/client_command/exec'
      autoload :Restart, 'rubocop/daemon/client_command/restart'
      autoload :Start, 'rubocop/daemon/client_command/start'
      autoload :Status, 'rubocop/daemon/client_command/status'
      autoload :Stop, 'rubocop/daemon/client_command/stop'
    end
  end
end
