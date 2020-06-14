# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks if usage of %() or %Q() matches configuration.
      #
      # @example EnforcedStyle: bare_percent (default)
      #   # bad
      #   %Q(He said: "#{greeting}")
      #   %q{She said: 'Hi'}
      #
      #   # good
      #   %(He said: "#{greeting}")
      #   %{She said: 'Hi'}
      #
      # @example EnforcedStyle: percent_q
      #   # bad
      #   %|He said: "#{greeting}"|
      #   %/She said: 'Hi'/
      #
      #   # good
      #   %Q|He said: "#{greeting}"|
      #   %q/She said: 'Hi'/
      #
      class BarePercentLiterals < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `%%%<good>s` instead of `%%%<bad>s`.'

        def on_dstr(node)
          check(node)
        end

        def on_str(node)
          check(node)
        end

        def autocorrect(node)
          src = node.loc.begin.source
          replacement = src.start_with?('%Q') ? '%' : '%Q'
          lambda do |corrector|
            corrector.replace(node.loc.begin, src.sub(/%Q?/, replacement))
          end
        end

        private

        def check(node)
          return if node.heredoc?
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
          style == :percent_q && /^%[^\w]/.match?(source)
        end

        def requires_bare_percent?(source)
          style == :bare_percent && source.start_with?('%Q')
        end

        def add_offense_for_wrong_style(node, good, bad)
          add_offense(node, location: :begin, message: format(MSG,
                                                              good: good,
                                                              bad: bad))
        end
      end
    end
  end
end
