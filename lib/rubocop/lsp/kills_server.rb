#
# This code is based on https://github.com/standardrb/standard.
#
# Copyright (c) 2023 Test Double, Inc.
#
# The MIT License (MIT)
#
# https://github.com/standardrb/standard/blob/main/LICENSE.txt
#
module Standard
  module Lsp
    class KillsServer
      def call(&blk)
        at_exit(&blk) unless blk.nil?
        exit 0
      end
    end
  end
end
