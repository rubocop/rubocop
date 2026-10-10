# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for exact regexp match inside `Regexp` literals.
      #
      # `=~` returns an index and `match` returns `MatchData`, so they are only
      # autocorrected when their value is used as a condition. The same goes for
      # safe navigation calls, which return `nil` for a `nil` receiver.
      #
      # @example
      #
      #   # bad
      #   string =~ /\Astring\z/
      #   /\Astring\z/ === string
      #   string.match(/\Astring\z/)
      #   string.match?(/\Astring\z/)
      #
      #   # good
      #   string == 'string'
      #
      #   # bad
      #   string !~ /\Astring\z/
      #
      #   # good
      #   string != 'string'
      #
      class ExactRegexpMatch < Base
        extend AutoCorrector

        MSG = 'Use `%<prefer>s`.'
        RESTRICT_ON_SEND = %i[=~ === !~ match match?].freeze
        BOOLEAN_METHODS = %i[=== !~ match?].to_set.freeze

        # `String#===` is plain equality, so `===` only matches with the regexp as its receiver.
        # @!method exact_regexp_match(node)
        def_node_matcher :exact_regexp_match, <<~PATTERN
          {
            (call _ {:=~ :!~ :match :match?} (regexp (str $_) (regopt)))
            (send (regexp (str $_) (regopt)) :=== _)
          }
        PATTERN

        def on_send(node)
          return unless (receiver = node.receiver)
          return unless (regexp = exact_regexp_match(node))
          return unless (parsed_regexp = parse_regexp(regexp))
          return unless exact_match_pattern?(parsed_regexp)

          string = escape_single_quotes(parsed_regexp[1].text)
          subject = node.method?(:===) ? node.first_argument : receiver
          prefer = "#{subject.source} #{new_method(node)} '#{string}'"

          add_offense(node, message: format(MSG, prefer: prefer)) do |corrector|
            autocorrect(corrector, node, prefer)
          end
        end
        alias on_csend on_send

        private

        def autocorrect(corrector, node, prefer)
          return unless boolean_result?(node) || truthiness_only?(node)

          corrector.replace(node, parenthesize?(node) ? "(#{prefer})" : prefer)
        end

        # `=~` returns an index, `match` returns `MatchData` and `&.` can return `nil`,
        # so replacing them with `==` is only safe where the value is used as a condition.
        def boolean_result?(node)
          node.send_type? && BOOLEAN_METHODS.include?(node.method_name)
        end

        def truthiness_only?(node)
          return true unless node.value_used?

          parent = node.parent
          if parent.type?(:begin, :and, :or)
            truthiness_only?(parent)
          elsif parent.type?(:if, :while, :until)
            parent.condition.equal?(node)
          else
            parent.send_type? && parent.method?(:!)
          end
        end

        def parenthesize?(node)
          return false unless (parent = node.parent)&.call_type?

          parent.receiver.equal?(node) || (parent.operator_method? && !parent.method?(:[]))
        end

        # Escape characters that are special inside a single-quoted string so the
        # generated literal (e.g. for `/\Afoo'bar\z/`) stays valid Ruby.
        def escape_single_quotes(text)
          text.gsub(/['\\]/) { |char| "\\#{char}" }
        end

        def exact_match_pattern?(parsed_regexp)
          tokens = parsed_regexp.map(&:token)
          return false unless tokens[0] == :bos && tokens[1] == :literal && tokens[2] == :eos

          !parsed_regexp[1].quantifier
        end

        def new_method(node)
          node.method?(:!~) ? '!=' : '=='
        end
      end
    end
  end
end
