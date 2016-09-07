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
      #     foo.try!(:[], 0)
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
          (send _ ${:try :try!} $_ ...)
        PATTERN

        def on_send(node)
          return if target_ruby_version < 2.3

          try_call(node) do |try_method, method_to_try|
            return if try_method == :try && !cop_config['ConvertTry']
            return unless method_to_try.sym_type?
            method, = *method_to_try
            return unless method =~ /\w+[=!?]?/
            add_offense(node, :expression, format(MSG, try_method))
          end
        end

        private

        def autocorrect(node)
          _receiver, _try, method_node, *params = *node
          method = method_node.source[1..-1]
          range = range_between(node.loc.dot.begin_pos,
                                node.loc.expression.end_pos)

          lambda do |corrector|
            corrector.replace(range, replacement(method, params))
          end
        end

        def replacement(method, params)
          new_params = params.map(&:source).join(', ')

          if method.end_with?('=')
            "&.#{method[0...-1]} = #{new_params}"
          elsif params.empty?
            "&.#{method}"
          else
            "&.#{method}(#{new_params})"
          end
        end
      end
    end
  end
end
