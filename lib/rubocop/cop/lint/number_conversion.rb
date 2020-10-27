# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop warns the usage of unsafe number conversions. Unsafe
      # number conversion can cause unexpected error if auto type conversion
      # fails. Cop prefer parsing with number class instead.
      #
      # Conversion with `Integer`, `Float`, etc. will raise an `ArgumentError`
      # if given input that is not numeric (eg. an empty string), whereas
      # `to_i`, etc. will try to convert regardless of input (`''.to_i => 0`).
      # As such, this cop is disabled by default because it's not necessarily
      # always correct to raise if a value is not numeric.
      #
      # NOTE: Some values cannot be converted properly using one of the `Kernel`
      # method (for instance, `Time` and `DateTime` values are allowed by this
      # cop by default). Similarly, Rails' duration methods do not work well
      # with `Integer()` and can be ignored with `IgnoredMethods`.
      #
      # @example
      #
      #   # bad
      #
      #   '10'.to_i
      #   '10.2'.to_f
      #   '10'.to_c
      #
      #   # good
      #
      #   Integer('10', 10)
      #   Float('10.2')
      #   Complex('10')
      #
      # @example IgnoredMethods: [minutes]
      #
      #   # good
      #   10.minutes.to_i
      #
      # @example IgnoredClasses: [Time, DateTime] (default)
      #
      #   # good
      #   Time.now.to_datetime.to_i
      class NumberConversion < Base
        extend AutoCorrector
        include IgnoredMethods

        CONVERSION_METHOD_CLASS_MAPPING = {
          to_i: "#{Integer.name}(%<number_object>s, 10)",
          to_f: "#{Float.name}(%<number_object>s)",
          to_c: "#{Complex.name}(%<number_object>s)"
        }.freeze
        MSG = 'Replace unsafe number conversion with number '\
              'class parsing, instead of using '\
              '%<number_object>s.%<to_method>s, use stricter '\
              '%<corrected_method>s.'
        RESTRICT_ON_SEND = CONVERSION_METHOD_CLASS_MAPPING.keys.freeze

        def_node_matcher :to_method, <<~PATTERN
          (send $_ ${:to_i :to_f :to_c})
        PATTERN

        def on_send(node)
          to_method(node) do |receiver, to_method|
            next if receiver.nil? || ignore_receiver?(receiver)

            message = format(
              MSG,
              number_object: receiver.source,
              to_method: to_method,
              corrected_method: correct_method(node, receiver)
            )
            add_offense(node, message: message) do |corrector|
              corrector.replace(node, correct_method(node, node.receiver))
            end
          end
        end

        private

        def correct_method(node, receiver)
          format(CONVERSION_METHOD_CLASS_MAPPING[node.method_name],
                 number_object: receiver.source)
        end

        def ignore_receiver?(receiver)
          if receiver.send_type? && ignored_method?(receiver.method_name)
            true
          elsif (receiver = top_receiver(receiver))
            receiver.const_type? && ignored_class?(receiver.const_name)
          else
            false
          end
        end

        def top_receiver(node)
          receiver = node
          receiver = receiver.receiver until receiver.receiver.nil?
          receiver
        end

        def ignored_classes
          cop_config.fetch('IgnoredClasses', [])
        end

        def ignored_class?(name)
          ignored_classes.include?(name.to_s)
        end
      end
    end
  end
end
