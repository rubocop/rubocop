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
      #   @bad
      #   class C
      #     private
      #
      #     def self.method
      #       puts 'hi'
      #     end
      #   end
      #
      #   @good
      #   class C
      #     def self.method
      #       puts 'hi'
      #     end
      #
      #     private_class_method :method
      #   end
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
        MSG = '`%s` (on line %d) does not make singleton methods %s. ' \
              'Use %s instead.'.freeze
        ALTERNATIVE_PRIVATE = '`private_class_method` or `private` inside a ' \
                              '`class << self` block'.freeze
        ALTERNATIVE_PROTECTED = '`protected` inside a `class << self` ' \
                                'block'.freeze

        def_node_matcher :access_modifier, <<-PATTERN
          (send nil ${:public :protected :private})
        PATTERN

        def_node_matcher :private_class_method, <<-PATTERN
          (send nil :private_class_method $...)
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
            add_offense(defs_node, :keyword,
                        format_message(visibility, modifier))
          end
        end

        def format_message(visibility, modifier)
          alternative = if visibility == :private
                          ALTERNATIVE_PRIVATE
                        else
                          ALTERNATIVE_PROTECTED
                        end
          format(MSG, visibility, modifier.location.expression.line, visibility,
                 alternative)
        end

        def check_scope(node, cur_vis = :public)
          node.children.reduce(cur_vis) do |visibility, child|
            check_child_scope(child, visibility)
          end
        end

        def check_child_scope(node, cur_vis)
          if (new_vis = access_modifier(node))
            cur_vis = change_visibility(node, new_vis)
          elsif node.defs_type?
            mark_method_as_useless(node, cur_vis) if cur_vis != :public
          elsif (methods = private_class_method(node))
            # don't warn about defs nodes which are followed by a call to
            # `private_class_method :name`
            # obviously the programmer knows what they are doing
            revert_method_uselessness(methods)
          elsif node.kwbegin_type?
            cur_vis = check_scope(node, cur_vis)
          end

          cur_vis
        end

        def change_visibility(node, new_vis)
          @last_access_modifier = node
          new_vis
        end

        def mark_method_as_useless(node, cur_vis)
          _, method_name, = *node
          @useless[method_name] = [node, cur_vis, @last_access_modifier]
        end

        def revert_method_uselessness(methods)
          methods.each do |sym|
            next unless sym.sym_type?
            @useless.delete(sym.children[0])
          end
        end
      end
    end
  end
end
