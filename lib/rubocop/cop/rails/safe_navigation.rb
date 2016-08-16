# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop converts usages of `try!` to `&.`. It can also be configured
      # to convert `try`. It will convert code to use safe navigation if the
      # target Ruby version is set to 2.3+
      #
      # @example
      #   # ConvertTry: false
      #     # bad
      #     foo.try!(:bar)
      #     foo.try!(:bar, baz)
      #     foo.try!(:bar) { |e| e.baz }
      #
      #     # good
      #     foo.try(:bar)
      #     foo.try(:bar, baz)
      #     foo.try(:bar) { |e| e.baz }
      #
      #     foo&.bar
      #     foo&.bar(baz)
      #     foo&.bar { |e| e.baz }
      #
      #
      #   # ConvertTry: true
      #     # bad
      #     foo.try!(:bar)
      #     foo.try!(:bar, baz)
      #     foo.try!(:bar) { |e| e.baz }
      #     foo.try(:bar)
      #     foo.try(:bar, baz)
      #     foo.try(:bar) { |e| e.baz }
      #
      #     # good
      #     foo&.bar
      #     foo&.bar(baz)
      #     foo&.bar { |e| e.baz }
      class SafeNavigation < Cop
        MSG = 'Use safe navigation (`&.`) instead of `%s`.'.freeze

        def_node_matcher :try_call, <<-PATTERN
          (send _ ${:try :try!} ...)
        PATTERN

        def on_send(node)
          return if target_ruby_version < 2.3

          try_call(node) do |method|
            return if method == :try && !cop_config['ConvertTry']
            add_offense(node, :expression, format(MSG, method))
          end
        end

        private

        def autocorrect(node)
          _receiver, _try, method, *params = *node

          range = Parser::Source::Range.new(node.loc.expression.source_buffer,
                                            node.loc.dot.begin_pos,
                                            node.loc.expression.end_pos)

          replacement = "&.#{method.source[1..-1]}"
          unless params.empty?
            replacement += "(#{params.map(&:source).join(', ')})"
          end

          lambda do |corrector|
            corrector.replace(range, replacement)
          end
        end
      end
    end
  end
end
