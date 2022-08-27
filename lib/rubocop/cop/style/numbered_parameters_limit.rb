# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Detects use of an excessive amount of numbered parameters in a
      # single block. Having too many numbered parameters can make code too
      # cryptic and hard to read.
      #
      # The cop defaults to registering an offense if there is more than 1 numbered
      # parameter but this maximum can be configured by setting `Max`.
      #
      # @example Max: 1 (default)
      #   # bad
      #   foo { _1.call(_2, _3, _4) }
      #
      #   # good
      #   foo { do_something(_1) }
      class NumberedParametersLimit < Base
        extend TargetRubyVersion
        extend ExcludeLimit

        DEFAULT_MAX_VALUE = 1

        minimum_target_ruby_version 2.7
        exclude_limit 'Max'

        MSG = 'Avoid using more than %<max>i numbered %<parameter>s; %<count>i detected.'

        def on_numblock(node)
          _send_node, param_count, * = *node
          return if param_count <= max_count

          parameter = max_count > 1 ? 'parameters' : 'parameter'
          message = format(MSG, max: max_count, parameter: parameter, count: param_count)
          add_offense(node, message: message) { self.max = param_count }
        end

        private

        def max_count
          max = cop_config.fetch('Max', DEFAULT_MAX_VALUE)

          # Ruby does not allow more than 9 numbered parameters
          [max, 9].min
        end
      end
    end
  end
end
