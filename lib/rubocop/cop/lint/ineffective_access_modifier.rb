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
              'methods %<modifier>s. Use %<alternative>s instead.'.freeze
        ALTERNATIVE_PRIVATE = '`private_class_method` or `private` inside a ' \
                              '`class << self` block'.freeze
        ALTERNATIVE_PROTECTED = '`protected` inside a `class << self` ' \
                                'block'.freeze

        def_node_matcher :private_class_method, <<-PATTERN
          (send nil? :private_class_method $...)
        PATTERN

        def on_class(node)
          check_node(node.children[2]) # class body
        end

        def on_module(node)
          check_node(node.children[1]) # module body
        end

        private

        def clear
          @useless = {}
          @last_access_modifier = nil
        end

        def check_node(node)
          return unless node && node.begin_type?

          clear
          check_scope(node)

          @useless.each do |_name, (defs_node, visibility, modifier)|
            add_offense(defs_node,
                        location: :keyword,
                        message: format_message(visibility, modifier))
          end
        end

        def format_message(visibility, modifier)
          alternative = if visibility == :private
                          ALTERNATIVE_PRIVATE
                        else
                          ALTERNATIVE_PROTECTED
                        end
          format(MSG, modifier: visibility,
                      line: modifier.location.expression.line,
                      alternative: alternative)
        end

        def check_scope(node, cur_vis = :public)
          node.each_child_node.reduce(cur_vis) do |visibility, child|
            check_child_scope(child, visibility)
          end
        end

        def check_child_scope(node, cur_vis)
          case node.type
          when :send
            cur_vis = check_send(node, cur_vis)
          when :defs
            check_defs(node, cur_vis)
          when :kwbegin
            check_scope(node, cur_vis)
          end

          cur_vis
        end

        def check_send(node, cur_vis)
          if node.bare_access_modifier? && !node.method?(:module_function)
            @last_access_modifier = node
            return node.method_name
          elsif (methods = private_class_method(node))
            # don't warn about defs nodes which are followed by a call to
            # `private_class_method :name`
            # obviously the programmer knows what they are doing
            revert_method_uselessness(methods)
          end

          cur_vis
        end

        def check_defs(node, cur_vis)
          mark_method_as_useless(node, cur_vis) if cur_vis != :public
        end

        def mark_method_as_useless(node, cur_vis)
          @useless[node.method_name] = [node, cur_vis, @last_access_modifier]
        end

        def revert_method_uselessness(methods)
          methods.each do |sym|
            next unless sym.sym_type?
            @useless.delete(sym.value)
          end
        end
      end
    end
  end
end
