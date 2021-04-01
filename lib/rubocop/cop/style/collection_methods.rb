# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of consistent method names
      # from the Enumerable module.
      #
      # Unfortunately we cannot actually know if a method is from
      # Enumerable or not (static analysis limitation), so this cop
      # can yield some false positives.
      #
      # You can customize the mapping from undesired method to desired method.
      #
      # e.g. to use `detect` over `find`:
      #
      #   Style/CollectionMethods:
      #     PreferredMethods:
      #       find: detect
      #
      # The default mapping for `PreferredMethods` behaves as follows.
      #
      # @example
      #   # bad
      #   items.collect
      #   items.collect!
      #   items.inject
      #   items.detect
      #   items.find_all
      #   items.member?
      #
      #   # good
      #   items.map
      #   items.map!
      #   items.reduce
      #   items.find
      #   items.select
      #   items.include?
      #
      class CollectionMethods < Base
        include MethodPreference
        extend AutoCorrector

        MSG = 'Prefer `%<prefer>s` over `%<current>s`.'

        def on_block(node)
          check_method_node(node.send_node)
        end

        def on_send(node)
          return unless implicit_block?(node)

          check_method_node(node)
        end

        private

        def check_method_node(node)
          return unless preferred_methods[node.method_name]

          message = message(node)
          add_offense(node.loc.selector, message: message) do |corrector|
            corrector.replace(node.loc.selector, preferred_method(node.loc.selector.source))
          end
        end

        def implicit_block?(node)
          return false unless node.arguments.any?

          node.last_argument.block_pass_type? ||
            node.last_argument.sym_type? && methods_accepting_symbol.include?(node.method_name.to_s)
        end

        def message(node)
          format(MSG, prefer: preferred_method(node.method_name), current: node.method_name)
        end

        # Some enumerable methods accept a bare symbol (ie. _not_ Symbol#to_proc) instead
        # of a block.
        def methods_accepting_symbol
          Array(cop_config['MethodsAcceptingSymbol'])
        end
      end
    end
  end
end
