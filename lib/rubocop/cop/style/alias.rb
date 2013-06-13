# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class Alias < Cop
        MSG = 'Use alias_method instead of alias.'

        def on_alias(node)
          add_offence(:convention,
                      node.loc.keyword,
                      MSG)

          super
        end
      end
    end
  end
end
