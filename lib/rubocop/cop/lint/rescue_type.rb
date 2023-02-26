# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Check for arguments to `rescue` that will result in a `TypeError`
      # if an exception is raised.
      #
      # @example
      #   # bad
      #   begin
      #     bar
      #   rescue nil
      #     baz
      #   end
      #
      #   # bad
      #   def foo
      #     bar
      #   rescue 1, 'a', "#{b}", 0.0, [], {}
      #     baz
      #   end
      #
      #   # good
      #   begin
      #     bar
      #   rescue
      #     baz
      #   end
      #
      #   # good
      #   def foo
      #     bar
      #   rescue NameError
      #     baz
      #   end
      class RescueType < Base
        extend AutoCorrector

        MSG = 'Rescuing from `%<invalid_exceptions>s` will raise a ' \
              '`TypeError` instead of catching the actual exception.'
        INVALID_TYPES = %i[array dstr float hash nil int str sym].freeze

        def on_resbody(node)
          rescued, _, _body = *node
          return if rescued.nil?

          exceptions = *rescued
          invalid_exceptions = invalid_exceptions(exceptions)
          return if invalid_exceptions.empty?

          add_offense(
            node.loc.keyword.join(rescued.source_range),
            message: format(MSG, invalid_exceptions: invalid_exceptions.map(&:source).join(', '))
          ) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def autocorrect(corrector, node)
          rescued, _, _body = *node
          range = Parser::Source::Range.new(node.source_range.source_buffer,
                                            node.loc.keyword.end_pos,
                                            rescued.source_range.end_pos)

          corrector.replace(range, correction(*rescued))
        end

        private

        def correction(*exceptions)
          correction = valid_exceptions(exceptions).map(&:source).join(', ')
          correction = " #{correction}" unless correction.empty?

          correction
        end

        def valid_exceptions(exceptions)
          exceptions - invalid_exceptions(exceptions)
        end

        def invalid_exceptions(exceptions)
          exceptions.select { |exception| INVALID_TYPES.include?(exception.type) }
        end
      end
    end
  end
end
