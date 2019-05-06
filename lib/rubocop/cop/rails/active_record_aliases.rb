# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks that ActiveRecord aliases are not used. The direct method names
      # are more clear and easier to read.
      #
      # @example
      #   #bad
      #   Book.update_attributes!(author: 'Alice')
      #
      #   #good
      #   Book.update!(author: 'Alice')
      class ActiveRecordAliases < Cop
        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'

        ALIASES = {
          update_attributes: :update,
          update_attributes!: :update!
        }.freeze

        def on_send(node)
          ALIASES.each do |bad, good|
            next unless node.method?(bad)

            add_offense(node,
                        message: format(MSG, prefer: good, current: bad),
                        location: :selector,
                        severity: :warning)
            break
          end
        end

        alias on_csend on_send

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(
              node.loc.selector,
              ALIASES[node.method_name].to_s
            )
          end
        end
      end
    end
  end
end
