# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks the indentation of hash values that start on the next line.
      #
      # @example
      #   # bad
      #   {
      #     foo:
      #     bar
      #   }
      #
      #   # bad
      #   {
      #     foo:
      #             bar
      #   }
      #
      #   # good
      #   {
      #     foo:
      #       bar
      #   }
      #
      class HashValueIndentation < Base
        include Alignment
        extend AutoCorrector

        MSG = 'Indent hash value %<configured_indentation_width>d spaces relative to hash key.'

        def on_pair(node)
          return unless node.value_on_new_line?
          return unless node.parent.braces?
          return if hash_table_alignment?(node)

          check_alignment([node.value], expected_indentation(node))
        end

        private

        def autocorrect(corrector, node)
          AlignmentCorrector.correct(corrector, processed_source, node, column_delta)
        end

        def message(_node)
          format(MSG, configured_indentation_width: configured_indentation_width)
        end

        def expected_indentation(node)
          node.key.source_range.column + configured_indentation_width
        end

        def hash_table_alignment?(node)
          return false unless config.cop_enabled?('Layout/HashAlignment')

          cop_config = config.for_cop('Layout/HashAlignment')
          config_key = node.hash_rocket? ? 'EnforcedHashRocketStyle' : 'EnforcedColonStyle'

          Array(cop_config.fetch(config_key, [])).include?('table')
        end
      end
    end
  end
end
