# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces safe navigation chains length to not exceed the configured maximum.
      #
      # @example Max: 2 (default)
      #   # bad
      #   user&.address&.zip&.upcase
      #
      #   # good
      #   user&.address&.zip
      #   user.address.zip if user
      #
      class SafeNavigationChainLength < Base
        MSG = 'Avoid safe navigation chains longer than %<max>d calls.'

        def on_csend(node)
          ancestors = csend_ancestors(node)
          add_offense(ancestors.last, message: format(MSG, max: max)) if ancestors.size >= max
        end

        private

        def csend_ancestors(node)
          ancestors = []
          node.each_ancestor do |parent|
            break unless parent.csend_type?

            ancestors << parent
          end
          ancestors
        end

        def max
          cop_config['Max']
        end
      end
    end
  end
end
