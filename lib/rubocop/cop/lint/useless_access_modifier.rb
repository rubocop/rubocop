# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for redundant access modifiers, including those with
      # no code, those which are repeated, and leading `public` modifiers in
      # a class or module body.
      #
      # @example
      #
      #   class Foo
      #     public # this is redundant
      #
      #     def method
      #     end
      #
      #     private # this is not redundant
      #     def method2
      #     end
      #
      #     private # this is redundant
      #   end
      class UselessAccessModifier < Cop
        MSG = 'Useless `%s` access modifier.'.freeze

        def_node_matcher :access_modifier, <<-PATTERN
          (send nil ${:public :protected :private})
        PATTERN

        def_node_matcher :method_definition?, <<-PATTERN
          {def (send nil {:attr :attr_reader :attr_writer :attr_accessor} ...)}
        PATTERN

        def on_class(node)
          check_node(node.children[2]) # class body
        end

        def on_module(node)
          check_node(node.children[1]) # module body
        end

        private

        def check_node(node)
          return if node.nil?
          if node.begin_type?
            check_scope(node)
          elsif (vis = access_modifier(node))
            add_offense(node, :expression, format(MSG, vis))
          end
        end

        def check_scope(node, cur_vis = :public)
          unused = nil

          node.children.each do |child|
            if (new_vis = access_modifier(child))
              # does this modifier just repeat the existing visibility?
              if new_vis == cur_vis
                add_offense(child, :expression, format(MSG, cur_vis))
              else
                # was the previous modifier never applied to any defs?
                add_offense(unused, :expression, format(MSG, cur_vis)) if unused
                # once we have already warned about a certain modifier, don't
                # warn again even if it is never applied to any method defs
                unused = child
              end
              cur_vis = new_vis
            elsif method_definition?(child)
              unused = nil
            elsif child.kwbegin_type?
              cur_vis = check_scope(child, cur_vis)
            end
          end

          add_offense(unused, :expression, format(MSG, cur_vis)) if unused

          cur_vis
        end
      end
    end
  end
end
