# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # The purpose of the this cop is advise the use of
      # alias_method over the alias keyword where appropriate.
      class Alias < Cop
        MSG = 'Use `alias_method` instead of `alias`.'

        def on_module(node)
          _name, body = *node
          return if body.nil?

          # using alias in lexical module scope is acceptable
          ignore_alias_in(body)
        end

        def on_class(node)
          _name, _superclass, body = *node
          return if body.nil?

          # using alias in lexical class scope is acceptable
          ignore_alias_in(body)
        end

        def on_block(node)
          method, _args, body = *node
          _receiver, method_name = *method

          # using alias is the only option in certain scenarios
          # in such scenarios we don't want to report an offense
          return unless method_name == :instance_exec

          ignore_alias_in(body)
        end

        def on_alias(node)
          return if ignored_node?(node)

          # alias_method can't be used with global variables
          new, old = *node

          return if new.type == :gvar && old.type == :gvar

          add_offense(node, :keyword)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            # replace alias with alias_method
            corrector.replace(node.loc.keyword, 'alias_method')
            # insert a comma
            new, old = *node
            corrector.insert_after(new.loc.expression, ',')
            # convert bareword arguments to symbols
            corrector.replace(new.loc.expression, ":#{new.children.first}")
            corrector.replace(old.loc.expression, ":#{old.children.first}")
          end
        end

        private

        def ignore_alias_in(body)
          body.each_node(:alias) { |n| ignore_node(n) }
        end
      end
    end
  end
end
