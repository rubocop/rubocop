# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use `File::NULL` instead of hardcoding the null device (`/dev/null` on Unix-like
      # OSes, `NUL` or `NUL:` on Windows), so that code is platform independent.
      # Only looks for full string matches, substrings within a longer string are not
      # considered.
      #
      # NOTE: Uses inside arrays and hashes are ignored.
      #
      # @safety
      #   It is possible for a string value to be changed if code is being run
      #   on multiple platforms and was previously hardcoded to a specific null device.
      #
      #   For example, the following string will change on Windows when changed to
      #   `File::NULL`:
      #
      #   [source,ruby]
      #   ----
      #   path = "/dev/null"
      #   ----
      #
      # @example
      #   # bad
      #   '/dev/null'
      #   'NUL'
      #   'NUL:'
      #
      #   # good
      #   File::NULL
      #
      #   # ok - inside an array
      #   null_devices = %w[/dev/null nul]
      #
      #   # ok - inside a hash
      #   { unix: "/dev/null", windows: "nul" }
      class FileNull < Base
        extend AutoCorrector

        REGEXP = %r{\A(/dev/null|NUL:?)\z}i.freeze
        MSG = 'Use `File::NULL` instead of `%<source>s`.'

        def on_str(node)
          value = node.value

          return if invalid_string?(value)
          return if acceptable?(node)
          return unless REGEXP.match?(value)

          add_offense(node, message: format(MSG, source: value)) do |corrector|
            corrector.replace(node, 'File::NULL')
          end
        end

        private

        def invalid_string?(value)
          value.empty? || !value.valid_encoding?
        end

        def acceptable?(node)
          # Using a hardcoded null device is acceptable when inside an array or
          # inside a hash to ensure behavior doesn't change.
          return false unless node.parent

          node.parent.type?(:array, :pair)
        end
      end
    end
  end
end
