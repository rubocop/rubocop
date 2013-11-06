# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # The purpose of the this cop is advise the use of
      # alias_method over the alias keyword whenever possible.
      class Alias < Cop
        MSG = 'Use alias_method instead of alias.'

        def on_block(node)
          method, _args, body = *node

          _receiver, method_name = *method

          # using alias is the only option in certain scenarios
          # in such scenarios we don't want to report an offence
          if method_name == :instance_exec
            on_node(:alias, body) { |n| ignore_node(n) }
          end
        end

        def on_alias(node)
          return if ignored_node?(node)

          # alias_method can't be used with global variables
          new, old = *node

          return if new.type == :gvar && old.type == :gvar

          convention(node, :keyword)
        end
      end
    end
  end
end
