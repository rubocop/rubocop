# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop check for usages of not (`not` or `!`) called on a method
      # when an inverse of that method can be used instead.
      # Methods that can be inverted by a not (`not` or `!`) should be defined
      # in `InverseMethods`
      # Methods that are inverted by inverting the return
      # of the block that is passed to the method should be defined in
      # `InverseBlocks`
      #
      # @example
      #   # bad
      #   !foo.none?
      #   !foo.any? { |f| f.even? }
      #   !foo.blank?
      #   !(foo == bar)
      #   foo.select { |f| !f.even? }
      #   foo.reject { |f| f != 7 }
      #
      #   # good
      #   foo.none?
      #   foo.blank?
      #   foo.any? { |f| f.even? }
      #   foo != bar
      #   foo == bar
      #   !!('foo' =~ /^\w+$/)
      #   !(foo.class < Numeric) # Checking class hierarchy is allowed
      class InverseMethods < Cop
        include IgnoredNode

        MSG = 'Use `%<inverse>s` instead of inverting `%<method>s`.'.freeze
        CLASS_COMPARISON_METHODS = %i[<= >= < >].freeze
        EQUALITY_METHODS = %i[== != =~ !~ <= >= < >].freeze
        NEGATED_EQUALITY_METHODS = %i[!= !~].freeze
        CAMEL_CASE = /[A-Z]+[a-z]+/

        def_node_matcher :inverse_candidate?, <<-PATTERN
          {
            (send $(send $(...) $_ $...) :!)
            (send (block $(send $(...) $_) $...) :!)
            (send (begin $(send $(...) $_ $...)) :!)
          }
        PATTERN

        def_node_matcher :inverse_block?, <<-PATTERN
          (block $(send (...) $_) ... { $(send ... :!)
                                        $(send (...) {:!= :!~} ...)
                                        (begin ... $(send ... :!))
                                        (begin ... $(send (...) {:!= :!~} ...))
                                      })
        PATTERN

        def on_send(node)
          return if part_of_ignored_node?(node)
          inverse_candidate?(node) do |_method_call, lhs, method, rhs|
            return unless inverse_methods.key?(method)
            return if possible_class_hierarchy_check?(lhs, rhs, method)
            return if negated?(node)

            add_offense(node,
                        message: format(MSG, method: method,
                                             inverse: inverse_methods[method]))
          end
        end

        def on_block(node)
          inverse_block?(node) do |_method_call, method, block|
            return unless inverse_blocks.key?(method)
            return if negated?(node) && negated?(node.parent)

            # Inverse method offenses inside of the block of an inverse method
            # offense, such as `y.reject { |key, _value| !(key =~ /c\d/) }`,
            # can cause auto-correction to apply improper corrections.
            ignore_node(block)
            add_offense(node,
                        message: format(MSG, method: method,
                                             inverse: inverse_blocks[method]))
          end
        end

        def autocorrect(node)
          method_call, _lhs, method, _rhs = inverse_candidate?(node)

          if method_call && method
            lambda do |corrector|
              corrector.remove(not_to_receiver(node, method_call))
              corrector.replace(method_call.loc.selector,
                                inverse_methods[method].to_s)

              if EQUALITY_METHODS.include?(method)
                corrector.remove(end_parentheses(node, method_call))
              end
            end
          else
            correct_inverse_block(node)
          end
        end

        def correct_inverse_block(node)
          method_call, method, block = inverse_block?(node)

          lambda do |corrector|
            corrector.replace(method_call.loc.selector,
                              inverse_blocks[method].to_s)
            correct_inverse_selector(block, corrector)
          end
        end

        def correct_inverse_selector(block, corrector)
          selector = block.loc.selector.source

          if NEGATED_EQUALITY_METHODS.include?(selector.to_sym)
            selector[0] = '='
            corrector.replace(block.loc.selector, selector)
          else
            corrector.remove(block.loc.selector)
          end
        end

        private

        def inverse_methods
          @inverse_methods ||= cop_config['InverseMethods']
                               .merge(cop_config['InverseMethods'].invert)
        end

        def inverse_blocks
          @inverse_blocks ||= cop_config['InverseBlocks']
                              .merge(cop_config['InverseBlocks'].invert)
        end

        def negated?(node)
          node.parent.respond_to?(:method?) && node.parent.method?(:!)
        end

        def not_to_receiver(node, method_call)
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    node.loc.selector.begin_pos,
                                    method_call.loc.expression.begin_pos)
        end

        def end_parentheses(node, method_call)
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    method_call.loc.expression.end_pos,
                                    node.loc.expression.end_pos)
        end

        # When comparing classes, `!(Integer < Numeric)` is not the same as
        # `Integer > Numeric`.
        def possible_class_hierarchy_check?(lhs, rhs, method)
          CLASS_COMPARISON_METHODS.include?(method) &&
            (camel_case_constant?(lhs) ||
             (rhs.size == 1 &&
              camel_case_constant?(rhs.first)))
        end

        def camel_case_constant?(node)
          node.const_type? && node.source =~ CAMEL_CASE
        end
      end
    end
  end
end
