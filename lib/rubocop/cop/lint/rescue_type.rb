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
      class RescueType < Cop
        include RescueNode

        MSG = 'Rescuing from `%s` will raise a `TypeError` instead of ' \
              'catching the actual exception.'.freeze
        INVALID_TYPES = %i[array dstr float hash nil int str sym].freeze

        def on_resbody(node)
          rescued, _, _body = *node
          return if rescued.nil?
          exceptions = *rescued
          invalid_exceptions = invalid_exceptions(exceptions)
          return if invalid_exceptions.empty?

          add_offense(node,
                      node.loc.keyword.join(rescued.loc.expression),
                      format(MSG, invalid_exceptions.map(&:source).join(', ')))
        end

        private

        def autocorrect(node)
          rescued, _, _body = *node
          range = Parser::Source::Range.new(node.loc.expression,
                                            node.loc.keyword.end_pos,
                                            rescued.loc.expression.end_pos)

          lambda do |corrector|
            corrector.replace(range, correction(*rescued))
          end
        end

        def correction(*exceptions)
          correction = valid_exceptions(exceptions).map(&:source).join(', ')
          correction = " #{correction}" unless correction.empty?

          correction
        end

        def valid_exceptions(exceptions)
          exceptions - invalid_exceptions(exceptions)
        end

        def invalid_exceptions(exceptions)
          exceptions.select do |exception|
            INVALID_TYPES.include?(exception.type)
          end
        end
      end
    end
  end
end
