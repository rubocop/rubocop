# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for options hashes and discourages them if the
      # current Ruby version supports keyword arguments.
      #
      # @example
      #
      #   # bad
      #   def fry(options = {})
      #     temperature = options.fetch(:temperature, 300)
      #     # ...
      #   end
      #
      #
      #   # good
      #   def fry(temperature: 300)
      #     # ...
      #   end
      class OptionHash < Cop
        MSG = 'Prefer keyword arguments to options hashes.'.freeze

        def_node_matcher :option_hash, <<-PATTERN
          (args ... $(optarg [#suspicious_name? _] (hash)))
        PATTERN

        def on_args(node)
          option_hash(node) do |options|
            add_offense(options)
          end
        end

        private

        def suspicious_name?(arg_name)
          cop_config.key?('SuspiciousParamNames') &&
            cop_config['SuspiciousParamNames'].include?(arg_name.to_s)
        end
      end
    end
  end
end
