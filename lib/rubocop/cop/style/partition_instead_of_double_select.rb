# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for consecutive calls to `select`/`filter`/`find_all` and `reject`
      # on the same receiver with the same block body, where `partition` could be
      # used instead. Using `partition` reduces two collection traversals to one.
      #
      # @safety
      #   This cop is unsafe because:
      #
      #   * `Hash#select` and `Hash#reject` return hashes, but `Hash#partition`
      #     returns nested arrays.
      #   * When the receiver has side effects, calling it once (with `partition`)
      #     versus twice (with `select` + `reject`) may produce different results.
      #   * Custom classes may override `select`/`reject` without providing a
      #     compatible `partition` method.
      #
      # @example
      #   # bad
      #   positives = array.select { |x| x > 0 }
      #   negatives = array.reject { |x| x > 0 }
      #
      #   # bad
      #   positives = array.filter { |x| x > 0 }
      #   negatives = array.reject { |x| x > 0 }
      #
      #   # bad
      #   negatives = array.reject { |x| x > 0 }
      #   positives = array.select { |x| x > 0 }
      #
      #   # good
      #   positives, negatives = array.partition { |x| x > 0 }
      #
      class PartitionInsteadOfDoubleSelect < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `partition` instead of consecutive `%<first>s` and `%<second>s` calls.'

        SELECT_METHODS = %i[select filter find_all].freeze
        CANDIDATE_METHODS = (SELECT_METHODS + %i[reject]).to_set.freeze

        def on_block(node)
          return unless CANDIDATE_METHODS.include?(node.method_name)

          container = node_container(node)
          return unless container

          sibling_container = container.left_sibling
          sibling_block = find_matching_block(node, sibling_container)
          return unless sibling_block

          register_offense(node, sibling_block, container, sibling_container)
        end
        alias on_numblock on_block
        alias on_itblock on_block

        private

        def node_container(block_node)
          parent = block_node.parent
          if parent&.begin_type?
            block_node
          elsif parent&.assignment? && parent.parent&.begin_type?
            parent
          end
        end

        def find_matching_block(node, sibling_container)
          return unless sibling_container

          sibling_block = extract_block(sibling_container)
          return unless sibling_block
          return unless complementary_pair?(node, sibling_block)
          return unless node.receiver == sibling_block.receiver
          return unless same_block_contents?(node, sibling_block)

          sibling_block
        end

        def extract_block(container)
          if container.any_block_type?
            container
          elsif container.assignment?
            rhs = container.children.last
            rhs if rhs&.any_block_type?
          end
        end

        def complementary_pair?(block1, block2)
          m1 = block1.method_name
          m2 = block2.method_name
          (SELECT_METHODS.include?(m1) && m2 == :reject) ||
            (m1 == :reject && SELECT_METHODS.include?(m2))
        end

        def same_block_contents?(block1, block2)
          return false unless block1.type == block2.type

          if block1.block_type?
            block1.arguments == block2.arguments &&
              block1.body == block2.body
          else
            block1.body == block2.body
          end
        end

        def register_offense(node, sibling_block, container, sibling_container)
          message = format(MSG, first: sibling_block.method_name, second: node.method_name)

          add_offense(container, message: message) do |corrector|
            next unless both_lvasgn?(container, sibling_container)

            autocorrect(corrector, sibling_block, container, sibling_container)
          end
        end

        def both_lvasgn?(container, sibling_container)
          container.lvasgn_type? && sibling_container.lvasgn_type?
        end

        def autocorrect(corrector, sibling_block, container, sibling_container)
          select_var, reject_var =
            determine_variable_order(sibling_block, container, sibling_container)
          select_block = select_block_for(sibling_block, container)

          partition_call = build_partition_call(select_block)
          replacement = "#{select_var}, #{reject_var} = #{partition_call}"

          corrector.replace(sibling_container, replacement)
          range = range_by_whole_lines(container.source_range, include_final_newline: true)
          corrector.remove(range)
        end

        def determine_variable_order(sibling_block, container, sibling_container)
          if SELECT_METHODS.include?(sibling_block.method_name)
            [sibling_container.children.first, container.children.first]
          else
            [container.children.first, sibling_container.children.first]
          end
        end

        def select_block_for(sibling_block, container)
          if SELECT_METHODS.include?(sibling_block.method_name)
            sibling_block
          else
            container.children.last
          end
        end

        def build_partition_call(block_node)
          block_source = block_node.source
          selector = block_node.send_node.loc.selector
          offset = block_node.source_range.begin_pos
          method_start = selector.begin_pos - offset
          method_end = selector.end_pos - offset

          "#{block_source[0...method_start]}partition#{block_source[method_end..]}"
        end
      end
    end
  end
end
