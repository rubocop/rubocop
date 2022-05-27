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
      autoload :Base, 'rubocop/daemon/server_command/base'
      autoload :Exec, 'rubocop/daemon/server_command/exec'
      autoload :Stop, 'rubocop/daemon/server_command/stop'
    end
  end
end
