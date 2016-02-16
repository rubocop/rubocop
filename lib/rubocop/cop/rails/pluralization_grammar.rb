# encoding: utf-8
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
          receiver, method_name, *_args = *node
          return if receiver.nil?
          return unless duration_method?(method_name)
          return unless literal_number?(receiver)
          number, = *receiver
          if singular_receiver?(number) && plural_method?(method_name)
            add_offense(node,
                        :expression,
                        format(MSG, number, singularize(method_name)))
          elsif plural_receiver?(number) && singular_method?(method_name)
            add_offense(node,
                        :expression,
                        format(MSG, number, pluralize(method_name)))
          end
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            method_name = node.loc.selector.source
            replacement = if plural_method?(method_name)
                            singularize(method_name)
                          else
                            pluralize(method_name)
                          end
            corrector.replace(node.loc.selector, replacement)
          end
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
          node.int_type? || node.float_type?
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
