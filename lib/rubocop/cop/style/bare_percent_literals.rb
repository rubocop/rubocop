# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks if usage of %() or %Q() matches configuration.
      class BarePercentLiterals < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `%%%s` instead of `%%%s`.'.freeze

        def on_dstr(node)
          check(node)
        end

        def on_str(node)
          check(node)
        end

        private

        def check(node)
          return if node.loc.respond_to?(:heredoc_body)
          return unless node.loc.respond_to?(:begin)
          return unless node.loc.begin

          msg = case node.loc.begin.source
                when /^%[^\w]/
                  format(MSG, 'Q', '') if style == :percent_q
                when /^%Q/
                  format(MSG, '', 'Q') if style == :bare_percent
                end
          add_offense(node, :begin, msg) if msg
        end

        def autocorrect(node)
          src = node.loc.begin.source
          replacement = src.start_with?('%Q') ? '%' : '%Q'
          lambda do |corrector|
            corrector.replace(node.loc.begin, src.sub(/%Q?/, replacement))
          end
        end
      end
    end
  end
end
