# encoding: utf-8
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
          if node && node.begin_type?
            clear
            check_scope(node)

            @useless.each do |_name, (defs_node, visibility, modifier)|
              add_offense(defs_node, :keyword,
                          format_message(visibility, modifier))
            end
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
          node.children.each do |child|
            if (new_vis = access_modifier(child))
              @last_access_modifier = child
              cur_vis = new_vis
            elsif child.defs_type?
              if cur_vis != :public
                _, method_name, = *child
                @useless[method_name] = [child, cur_vis, @last_access_modifier]
              end
            elsif (methods = private_class_method(child))
              # don't warn about defs nodes which are followed by a call to
              # `private_class_method :name`
              # obviously the programmer knows what they are doing
              methods.select(&:sym_type?).each do |sym|
                @useless.delete(sym.children[0])
              end
            elsif child.kwbegin_type?
              cur_vis = check_scope(child, cur_vis)
            end
          end

          cur_vis
        end
      end
    end
  end
end
