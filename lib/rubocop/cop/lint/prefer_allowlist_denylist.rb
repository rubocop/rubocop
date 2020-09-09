# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # @example PreferAllowlistDenylist: blacklist
      #   # Use `allowlist` instead of `whitelist`.
      #
      #   # bad
      #   bad_whitelist_method
      #
      #   # bad
      #   BAD_BLACKLIST_CONST
      #
      #   # good
      #   good_allowlist_method
      #
      #   # good
      #   GOOD_ALLOWLIST_CONST
      #
      # @example EnforcedStyle: foo
      #   # Use `denylist` instead of `blacklist`.
      #
      #   # bad
      #   bad_blacklist_method
      #
      #   # bad
      #   BAD_BLACKLIST_CONST
      #
      #   # good
      #   good_denylist_method
      #
      #   # good
      #   GOOD_DENYLIST_CONST
      #
      class PreferAllowlistDenylist < Base
        MSG = "Use 'allowlist' and 'denylist' instead of 'whitelist' and 'blacklist'."

        def on_send(node)
          return if allowlisted?(node)

          node_text = node.to_s.downcase
          return unless node_text.include?('blacklist') || node_text.include?('whitelist')

          add_offense(node)
        end

        def allowlisted?(node)
          allowlist = [
            'lib/rubocop/cop/lint/prefer_allowlist_denylist',
            'spec/rubocop/cop/lint/prefer_allowlist_denylist'
          ]
          node_source_filename = node.loc.selector.source_buffer.name
          allowlist.any? { |allowlisted_file| node_source_filename.match(allowlisted_file) }
        end
      end
    end
  end
end
