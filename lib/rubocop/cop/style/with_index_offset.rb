# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for offset arithmetic on the index variable inside
      # `each_with_index` or `with_index` blocks.
      #
      # When every usage of the index variable in a block applies the same
      # constant offset (e.g. `index + 1`), the offset can be passed directly
      # to `with_index` instead.
      #
      # @example
      #   # bad
      #   array.each_with_index do |item, index|
      #     puts index + 1
      #   end
      #
      #   # bad
      #   array.each.with_index do |item, index|
      #     puts index + 1
      #   end
      #
      #   # bad
      #   array.each.with_index(0) do |item, index|
      #     puts index + 1
      #   end
      #
      #   # bad
      #   array.each_with_index do |item, index|
      #     puts index.succ
      #   end
      #
      #   # good
      #   array.each.with_index(1) do |item, index|
      #     puts index
      #   end
      #
      class WithIndexOffset < Base
        extend AutoCorrector

        MSG = 'Use `with_index(%<offset>s)` instead of manually computing the offset.'

        # @!method index_plus_int?(node, name)
        def_node_matcher :index_plus_int?, '(send (lvar %1) :+ int)'

        # @!method int_plus_index?(node, name)
        def_node_matcher :int_plus_index?, '(send int :+ (lvar %1))'

        # @!method index_minus_int?(node, name)
        def_node_matcher :index_minus_int?, '(send (lvar %1) :- int)'

        # @!method index_modified?(node, name)
        def_node_matcher :index_modified?, '(send (lvar %1) {:succ :next :pred})'

        def on_block(node)
          send_node = node.send_node
          return unless send_node.method?(:each_with_index) || send_node.method?(:with_index)
          return if nonzero_with_index_offset?(send_node)

          index_name = index_param_name(node)
          return unless index_name

          offset = find_consistent_offset(node.body, index_name)
          return unless offset

          add_offense(send_node.loc.selector, message: format(MSG, offset: offset)) do |corrector|
            correct_method_call(corrector, send_node, offset)
            correct_body_offsets(corrector, node.body, index_name)
          end
        end
        alias on_numblock on_block
        alias on_itblock on_block

        private

        def nonzero_with_index_offset?(send_node)
          return false unless send_node.method?(:with_index) && send_node.arguments.any?

          arg = send_node.first_argument
          !(arg.int_type? && arg.value.zero?)
        end

        def index_param_name(block_node)
          case block_node.type
          when :block
            args = block_node.arguments
            args[1].name if args.size >= 2
          when :numblock
            :_2
          end
        end

        def offset_value(node, index_name)
          if index_plus_int?(node, index_name)
            node.first_argument.value
          elsif int_plus_index?(node, index_name)
            node.receiver.value
          elsif index_minus_int?(node, index_name)
            -node.first_argument.value
          elsif index_modified?(node, index_name)
            node.method?(:pred) ? -1 : 1
          end
        end

        # Returns the consistent offset integer if every usage of the index
        # variable applies the same constant offset, or nil otherwise.
        def find_consistent_offset(body, index_name)
          return unless body

          offsets = []

          each_index_usage(body, index_name) do |node|
            value = offset_value(node, index_name)
            return unless value # bare reference (no offset) -> mixed usage

            offsets << value
          end

          return if offsets.empty?

          offsets.uniq.size == 1 ? offsets.first : nil
        end

        def each_index_usage(node, index_name, &block)
          # If this node is a recognized offset expression, yield it and stop recursing.
          if offset_value(node, index_name)
            yield(node)
            return
          end

          # Bare lvar reference to the index (not wrapped in an offset).
          if node.lvar_type? && node.name == index_name
            yield(node)
            return
          end

          node.each_child_node { |child| each_index_usage(child, index_name, &block) }
        end

        def correct_method_call(corrector, node, offset)
          if node.method?(:each_with_index)
            corrector.replace(node.loc.selector, "each.with_index(#{offset})")
          elsif node.arguments.any?
            corrector.replace(node.first_argument, offset.to_s)
          else
            corrector.insert_after(node.loc.selector, "(#{offset})")
          end
        end

        def correct_body_offsets(corrector, body, index_name)
          each_index_usage(body, index_name) do |node|
            replacement = if int_plus_index?(node, index_name)
                            node.first_argument.source
                          else
                            node.receiver.source
                          end
            corrector.replace(node, replacement)
          end
        end
      end
    end
  end
end
