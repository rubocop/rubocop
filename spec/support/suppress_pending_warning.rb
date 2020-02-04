# frozen_string_literal: true

#
# This is a file that supports testing. An open class has been applied to
# `RuboCop::ConfigLoader.warn_on_pending_cops` to suppress pending cop
# warnings during testing.
#
module RuboCop
  class ConfigLoader
    class << self
      def warn_on_pending_cops(config)
        # noop
      end
    end
  end
end
