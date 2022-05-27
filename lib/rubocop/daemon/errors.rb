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
    class GemfileNotFound < StandardError; end
    class InvalidTokenError < StandardError; end
    class ServerStopRequest < StandardError; end
    class UnknownClientCommandError < StandardError; end
    class UnknownServerCommandError < StandardError; end
  end
end
