# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop checks whether constant names are written using
      # clearer wording.
      #
      # @example
      #   # bad
      #   Whitelist = []
      #   WhiteList = []
      #   Whitelisted = []
      #   Blacklist = []
      #   BLACKLISTED = []
      #
      #   # good
      #   Allowlist = []
      #   PermittedList = []
      #   Denylist = []
      class ConstantWording < Cop
        MSG = 'Please use clearer names for constants.'.freeze

        def on_casgn(node)
          constant_name = get_constant_name(node)

          add_offense(node, location: :name) if not_clear?(constant_name)
        end

        private

        NAME_DENY_LIST = %i[
          whitelist
          blacklist
          blacklisted
          whitelisted
        ].freeze

        def get_constant_name(node)
          if node.parent && node.parent.or_asgn_type?
            lhs, _value = *node.parent
            _scope, const_name = *lhs
          else
            _scope, const_name, _value = *node
          end

          const_name
        end

        def not_clear?(const_name)
          NAME_DENY_LIST.include?(const_name.downcase)
        end
      end
    end
  end
end
