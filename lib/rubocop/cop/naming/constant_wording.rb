# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop checks whether constant names are written using
      # clearer wording.
      #
      # You can customize the mapping from undesired name to why
      # this method is not desired.
      #
      # e.g. not to use `whitelist`:
      #
      #   Naming/ConstantWording:
      #     PreferredMethods:
      #       whitelist: 'Please use clearer concepts, such as allow, permitted, approved.'
      #
      # @example
      #   # bad
      #   Whitelist = []
      #   WhiteList = []
      #   Whitelisted = []
      #   Blacklist = []
      #   BLACKLISTED = []
      #
      class ConstantWording < Cop
        include MethodPreference

        MSG = 'Prefer `%<prefer>` over `%<current>`.'.freeze

        def on_casgn(node)
          constant_name = get_constant_name(node)

          check_constant_name(constant_name)
        end

        private

        def get_constant_name(node)
          if node.parent && node.parent.or_asgn_type?
            lhs, _value = *node.parent
            _scope, const_name = *lhs
          else
            _scope, const_name, _value = *node
          end

          const_name
        end

        def message(node)
          constant_name = get_constant_name(node)

          format(MSG,
                 prefer: preferred_method(constant_name),
                 current: constant_name)
        end

        def check_constant_name(constant_name)
          return unless preferred_methods[constant_name.downcase]

          add_offense(node, location: :name)
        end
      end
    end
  end
end
