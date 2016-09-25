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

          source = node.loc.begin.source
          if requires_percent_q?(source)
            add_offense_for_wrong_style(node, 'Q', '')
          elsif requires_bare_percent?(source)
            add_offense_for_wrong_style(node, '', 'Q')
          end
        end

        def requires_percent_q?(source)
          style == :percent_q && source =~ /^%[^\w]/
        end

        def requires_bare_percent?(source)
          style == :bare_percent && source =~ /^%Q/
        end

        def add_offense_for_wrong_style(node, good, bad)
          add_offense(node, :begin, format(MSG, good, bad))
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
