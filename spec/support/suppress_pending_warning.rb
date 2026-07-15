# frozen_string_literal: true

#
# This is a file that supports testing. An open class has been applied to
# `RuboCop::PendingCopsReporter.warn_on_pending_cops` to suppress pending cop
# warnings during testing.
#
module RuboCop
  class PendingCopsReporter
    class << self
      # The self-alias suppresses Ruby's method redefinition warning and marks
      # the redefinition as intentional for `Lint/DuplicateMethods`.
      alias warn_on_pending_cops warn_on_pending_cops
      def warn_on_pending_cops(config)
        # noop
      end
    end
  end
end
