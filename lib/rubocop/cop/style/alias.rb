# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # The purpose of the this cop is advise the use of
      # alias_method over the alias keyword whenever possible.
      class Alias < Cop
        MSG = 'Use alias_method instead of alias.'

        # TODO: Make this check context aware - alias_method is not
        #   available outside of classes/modules.
        def on_alias(node)
          # alias_method can't be used with global variables
          new, old = *node

          return if new.type == :gvar && old.type == :gvar

          convention(node, :keyword)
        end
      end
    end
  end
end
