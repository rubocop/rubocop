# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for correct grammar when using ActiveSupport's
      # core extensions to the numeric classes.
      #
      # @example
      #   # bad
      #   3.day.ago
      #   1.months.ago
      #
      #   # good
      #   3.days.ago
      #   1.month.ago
      class PluralizationGrammar < Cop
        SINGULAR_DURATION_METHODS = { second: :seconds,
                                      minute: :minutes,
                                      hour: :hours,
                                      day: :days,
                                      week: :weeks,
                                      fortnight: :fortnights,
                                      month: :months,
                                      year: :years }.freeze

        PLURAL_DURATION_METHODS = SINGULAR_DURATION_METHODS.invert.freeze

        MSG = 'Prefer `%s.%s`.'.freeze

        def on_send(node)
          return unless duration_method?(node.method_name)
          return unless literal_number?(node.receiver)

          return unless offense?(node)

          add_offense(node)
        end

        private

        def message(node)
          number, = *node.receiver

          format(MSG, number, correct_method(node.method_name.to_s))
        end

        def autocorrect(node)
          lambda do |corrector|
            method_name = node.loc.selector.source

            corrector.replace(node.loc.selector, correct_method(method_name))
          end
        end

        def correct_method(method_name)
          if plural_method?(method_name)
            singularize(method_name)
          else
            pluralize(method_name)
          end
        end

        def offense?(node)
          number, = *node.receiver

          singular_receiver?(number) && plural_method?(node.method_name) ||
            plural_receiver?(number) && singular_method?(node.method_name)
        end

        def plural_method?(method_name)
          method_name.to_s.end_with?('s')
        end

        def singular_method?(method_name)
          !plural_method?(method_name)
        end

        def singular_receiver?(number)
          number == 1
        end

        def plural_receiver?(number)
          !singular_receiver?(number)
        end

        def literal_number?(node)
          node && (node.int_type? || node.float_type?)
        end

        def pluralize(method_name)
          SINGULAR_DURATION_METHODS.fetch(method_name.to_sym).to_s
        end

        def singularize(method_name)
          PLURAL_DURATION_METHODS.fetch(method_name.to_sym).to_s
        end

        def duration_method?(method_name)
          SINGULAR_DURATION_METHODS.key?(method_name) ||
            PLURAL_DURATION_METHODS.key?(method_name)
        end
      end
    end
  end
end
