# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant uses of double splat hash braces.
      #
      # @example
      #
      #   # bad
      #   do_something(**{foo: bar, baz: qux})
      #
      #   # good
      #   do_something(foo: bar, baz: qux)
      #
      #   # bad
      #   do_something(**{foo: bar, baz: qux}.merge(options))
      #
      #   # good
      #   do_something(foo: bar, baz: qux, **options)
      #
      class RedundantDoubleSplatHashBraces < Base
        extend AutoCorrector

        MSG = 'Remove the redundant double splat and braces, use keyword arguments directly.'
        MERGE_METHODS = %i[merge merge!].freeze

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def on_hash(node)
          return if node.pairs.empty? || node.pairs.any?(&:hash_rocket?)
          return unless (parent = node.parent)
          return if parent.call_type? && !merge_method?(parent)
          return unless (kwsplat = node.each_ancestor(:kwsplat).first)
          return if allowed_double_splat_receiver?(kwsplat)

          add_offense(kwsplat) do |corrector|
            autocorrect(corrector, node, kwsplat)
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        private

        def allowed_double_splat_receiver?(kwsplat)
          return false unless kwsplat.children.first.call_type?

          root_receiver = root_receiver(kwsplat.children.first)

          !root_receiver&.hash_type?
        end

        def autocorrect(corrector, node, kwsplat)
          corrector.remove(kwsplat.loc.operator)
          corrector.remove(opening_brace(node))
          corrector.remove(closing_brace(node))

          merge_methods = select_merge_method_nodes(kwsplat)
          return if merge_methods.empty?

          autocorrect_merge_methods(corrector, merge_methods, kwsplat)
        end

        def root_receiver(node)
          receiver = node.receiver
          if receiver&.receiver
            root_receiver(receiver)
          else
            receiver
          end
        end

        def select_merge_method_nodes(kwsplat)
          extract_send_methods(kwsplat).select do |node|
            merge_method?(node)
          end
        end

        def opening_brace(node)
          node.loc.begin.join(node.children.first.source_range.begin)
        end

        def closing_brace(node)
          node.children.last.source_range.end.join(node.loc.end)
        end

        def autocorrect_merge_methods(corrector, merge_methods, kwsplat)
          range = range_of_merge_methods(merge_methods)

          new_kwsplat_arguments = extract_send_methods(kwsplat).map do |descendant|
            convert_to_new_arguments(descendant)
          end
          new_source = new_kwsplat_arguments.compact.reverse.unshift('').join(', ')

          corrector.replace(range, new_source)
        end

        def range_of_merge_methods(merge_methods)
          begin_merge_method = merge_methods.last
          end_merge_method = merge_methods.first

          begin_merge_method.loc.dot.begin.join(end_merge_method.source_range.end)
        end

        def extract_send_methods(kwsplat)
          kwsplat.each_descendant(:send, :csend)
        end

        def convert_to_new_arguments(node)
          return unless merge_method?(node)

          node.arguments.map do |arg|
            if arg.hash_type?
              arg.source
            else
              "**#{arg.source}"
            end
          end
        end

        def merge_method?(node)
          MERGE_METHODS.include?(node.method_name)
        end
      end
    end
  end
end
