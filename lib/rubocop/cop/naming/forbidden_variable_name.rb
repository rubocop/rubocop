# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Checks for assigning to a restricted identifier name. Restricted names
      # are forbidden for local variables, instance variables, class variables,
      # global variables, method arguments (positional, keyword, rest or block),
      # and block arguments.
      #
      # Method names are not covered by this cop.
      #
      # NOTE: The cop is not configured with any restricted identifier names
      # by default. Assign values to the `Identifiers` array to use the cop.
      #
      # @example Identifiers: ['require']
      #   # bad
      #   require = 'json'
      #   require require
      #
      #   # good
      #   gem = 'json'
      #   require gem
      class ForbiddenVariableName < Base
        MSG = '`%<identifier>s` is forbidden, use another name instead.'
        SIGILS = '@$' # if a variable starts with a sigil it will be removed

        def on_lvasgn(node)
          return unless node.name
          return unless forbidden_name?(node.name)

          message = format(MSG, identifier: node.name)
          add_offense(node.loc.name, message: message)
        end
        alias on_ivasgn    on_lvasgn
        alias on_cvasgn    on_lvasgn
        alias on_gvasgn    on_lvasgn
        alias on_arg       on_lvasgn
        alias on_optarg    on_lvasgn
        alias on_restarg   on_lvasgn
        alias on_kwarg     on_lvasgn
        alias on_kwoptarg  on_lvasgn
        alias on_kwrestarg on_lvasgn
        alias on_blockarg  on_lvasgn

        private

        def forbidden_names
          cop_config.fetch('ForbiddenNames', [])
        end

        def forbidden_name?(name)
          !forbidden_names.empty? && forbidden_names.include?(name.to_s.delete(SIGILS))
        end
      end
    end
  end
end
