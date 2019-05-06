# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for `private` or `protected` access modifiers which are
      # applied to a singleton method. These access modifiers do not make
      # singleton methods private/protected. `private_class_method` can be
      # used for that.
      #
      # @example
      #
      #   # bad
      #
      #   class C
      #     private
      #
      #     def self.method
      #       puts 'hi'
      #     end
      #   end
      #
      # @example
      #
      #   # good
      #
      #   class C
      #     def self.method
      #       puts 'hi'
      #     end
      #
      #     private_class_method :method
      #   end
      #
      # @example
      #
      #   # good
      #
      #   class C
      #     class << self
      #       private
      #
      #       def method
      #         puts 'hi'
      #       end
      #     end
      #   end
      class IneffectiveAccessModifier < Cop
        MSG = '`%<modifier>s` (on line %<line>d) does not make singleton ' \
              'methods %<modifier>s. Use %<alternative>s instead.'
        ALTERNATIVE_PRIVATE = '`private_class_method` or `private` inside a ' \
                              '`class << self` block'
        ALTERNATIVE_PROTECTED = '`protected` inside a `class << self` ' \
                                'block'

        def_node_search :private_class_methods, <<-PATTERN
          (send nil? :private_class_method $...)
        PATTERN

        def on_class(node)
          check_node(node.children[2]) # class body
        end

        def on_module(node)
          check_node(node.children[1]) # module body
        end

        private

        def check_node(node)
          return unless node&.begin_type?

          ignored_methods = private_class_method_names(node)

          ineffective_modifier(node, ignored_methods) do |defs_node, modifier|
            add_offense(defs_node,
                        location: :keyword,
                        message: format_message(modifier))
          end
        end

        def private_class_method_names(node)
          private_class_methods(node).to_a.flatten
                                     .select(&:basic_literal?)
                                     .map(&:value)
        end

        def format_message(modifier)
          visibility = modifier.method_name
          alternative = if visibility == :private
                          ALTERNATIVE_PRIVATE
                        else
                          ALTERNATIVE_PROTECTED
                        end
          format(MSG, modifier: visibility,
                      line: modifier.location.expression.line,
                      alternative: alternative)
        end

        def ineffective_modifier(node, ignored_methods, modifier = nil, &block)
          node.each_child_node do |child|
            case child.type
            when :send
              modifier = child if access_modifier?(child)
            when :defs
              next if correct_visibility?(child, modifier, ignored_methods)

              yield child, modifier
            when :kwbegin
              ineffective_modifier(child, ignored_methods, modifier, &block)
            end
          end
        end

        def access_modifier?(node)
          node.bare_access_modifier? && !node.method?(:module_function)
        end

        def correct_visibility?(node, modifier, ignored_methods)
          return true if modifier.nil? || modifier.method_name == :public

          ignored_methods.include?(node.method_name)
        end
      end
    end
  end
end
