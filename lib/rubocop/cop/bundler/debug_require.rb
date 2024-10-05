# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # Enforces that if `gem "debug"` is present,
      # `require: "debug/prelude"` or
      # `require: false` is specified.
      #
      # @example
      #   # bad
      #   gem "debug"
      #
      #   # good
      #   gem "debug", require: "debug/prelude"
      #   gem "debug", require: false
      #
      class DebugRequire < Base
        extend AutoCorrector
        include MultilineExpressionIndentation

        MSG = 'Specify `require: "debug/prelude"` or `require: false` when depending on the ' \
              '`debug` gem.'
        RESTRICT_ON_SEND = %i[gem].freeze
        REQUIRE_CORRECTION = 'require: "debug/prelude"'

        # @!method gem_debug_without_correct_require?(node)
        def_node_matcher :gem_debug_without_correct_require?, <<~PATTERN
          (send nil? :gem (str "debug")                                   # gem "debug", followed by
            [!hash]*                                                      # maybe non-hashes (versions),
            [
              $hash                                                       # and a hash
              !(hash                                                      # but not one containing the correct require:
                <(pair (sym :require) {(str "debug/prelude") false}) ...>
              )
            ]?                                                            # (maybe)
          )
        PATTERN

        def on_send(node)
          gem_debug_without_correct_require?(node) do |captures|
            add_offense(node) do |corrector|
              if (kwargs = captures.first)
                update_kwarg(corrector, kwargs)
              else
                append_require_kwarg(corrector, node)
              end
            end
          end
        end

        private

        def update_kwarg(corrector, kwargs)
          pairs = kwargs.pairs

          if (require_pair = pairs.find { |pair| pair.key.value == :require })
            corrector.replace(require_pair, REQUIRE_CORRECTION)
          else
            first_pair = pairs.first
            whitespace = kwargs.parent.multiline? ? "\n#{' ' * indentation(first_pair)}" : ' '
            corrector.insert_before(first_pair, "#{REQUIRE_CORRECTION},#{whitespace}")
          end
        end

        def append_require_kwarg(corrector, node)
          corrector.insert_after(node.last_argument, ", #{REQUIRE_CORRECTION}")
        end
      end
    end
  end
end
