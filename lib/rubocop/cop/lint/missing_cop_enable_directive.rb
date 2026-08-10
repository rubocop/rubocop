# frozen_string_literal: true

# rubocop:disable-next Lint/RedundantCopDisableDirective
module RuboCop
  module Cop
    module Lint
      # Checks that there is an `# rubocop:enable ...` statement
      # after a `# rubocop:disable ...` statement. This will prevent leaving
      # cop disables on wide ranges of code, that later contributors to
      # a file wouldn't be aware of.
      #
      # You can set `MaxRangeSize` to define the maximum number of
      # consecutive lines a cop can be disabled for.
      #
      # - `.inf` any size (default)
      # - `0` allows only single-line disables
      # - `1` means the maximum allowed is as follows:
      #
      # [source,ruby]
      # ----
      # # rubocop:disable SomeCop
      # a = 1
      # # rubocop:enable SomeCop
      # ----
      #
      # @example MaxRangeSize: .inf (default)
      #
      #   # good
      #   # rubocop:disable Layout/SpaceAroundOperators
      #   x= 0
      #   # rubocop:enable Layout/SpaceAroundOperators
      #   # y = 1
      #   # EOF
      #
      #   # bad
      #   # rubocop:disable Layout/SpaceAroundOperators
      #   x= 0
      #   # EOF
      #
      # @example MaxRangeSize: 2
      #
      #   # good
      #   # rubocop:disable Layout/SpaceAroundOperators
      #   x= 0
      #   # With the previous, there are 2 lines on which cop is disabled.
      #   # rubocop:enable Layout/SpaceAroundOperators
      #
      #   # bad
      #   # rubocop:disable Layout/SpaceAroundOperators
      #   x= 0
      #   x += 1
      #   # Including this, that's 3 lines on which the cop is disabled.
      #   # rubocop:enable Layout/SpaceAroundOperators
      #
      class MissingCopEnableDirective < Base
        include RangeHelp

        MSG = 'Re-enable %<cop>s %<type>s with `%<directive>s` after disabling it.'
        MSG_BOUND = 'Re-enable %<cop>s %<type>s within %<max_range>s lines after disabling it.'

        def on_new_investigation
          each_missing_enable do |cop, line_range|
            next if acceptable_range?(cop, line_range)

            comment = processed_source.comment_at_line(line_range.begin)

            add_offense(comment, message: message(cop, comment))
          end
        end

        private

        def each_missing_enable
          processed_source.disabled_line_ranges.each do |cop, line_ranges|
            line_ranges.each do |line_range|
              # A `disable-next` scope closes itself with its statement.
              next if line_range.respond_to?(:directive) && line_range.directive.disable_next?

              yield cop, line_range
            end
          end
        end

        def acceptable_range?(cop, line_range)
          # This has to remain a strict inequality to handle
          # the case when max_range is Float::INFINITY
          return true if line_range.max - line_range.min < max_range + 2
          # A name that is not registered as written (e.g. a wrongly-namespaced
          # cop) suppresses nothing; `Lint/RedundantCopDisableDirective` reports
          # it, so demanding its re-enablement would only add noise.
          return true unless Registry.global.names.include?(cop)

          expected_open_range?(cop, line_range)
        end

        def expected_open_range?(cop, line_range)
          # This cop is disabled in the config, it is not expected to be re-enabled
          return true if line_range.min == CommentConfig::CONFIG_DISABLED_LINE_RANGE_MIN

          cop_class = RuboCop::Cop::Registry.global.find_by_cop_name(cop)
          !!(cop_class &&
             !processed_source.registry.enabled?(cop_class, config) &&
             line_range.max == Float::INFINITY)
        end

        def max_range
          @max_range ||= cop_config['MaxRangeSize']
        end

        def message(cop, comment, type = 'cop')
          directive = DirectiveComment.new(comment)
          if department_enabled?(cop, comment)
            type = 'department'
            cop = cop.split('/').first
          end

          if max_range == Float::INFINITY
            # A range opened by `rubocop:push` is closed by `rubocop:pop`,
            # not by `rubocop:enable`.
            enabling_directive = directive.push? ? '# rubocop:pop' : '# rubocop:enable'
            format(MSG, cop: cop, type: type, directive: enabling_directive)
          else
            format(MSG_BOUND, cop: cop, type: type, max_range: max_range)
          end
        end

        def department_enabled?(cop, comment)
          DirectiveComment.new(comment).in_directive_department?(cop)
        end
      end
    end
  end
end
