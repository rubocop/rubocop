# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks that node matcher definitions are tagged with a YARD `@!method`
      # directive so that editors are able to find the dynamically defined
      # method.
      #
      # @example
      #  # bad
      #  def_node_matcher :foo?, <<~PATTERN
      #    ...
      #  PATTERN
      #
      #  # good
      #  # @!method foo?(node)
      #  def_node_matcher :foo?, <<~PATTERN
      #    ...
      #  PATTERN
      #
      class NodeMatcherDirective < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Precede `%<method>s` with a `@!method` YARD directive.'
        MSG_WRONG_NAME = '`@!method` YARD directive has invalid method name, ' \
                         'use `%<expected>s` instead of `%<actual>s`.'
        MSG_TOO_MANY = 'Multiple `@!method` YARD directives found for this matcher.'

        RESTRICT_ON_SEND = %i[def_node_matcher def_node_search].to_set.freeze
        REGEXP = /^\s*#\s*@!method\s+(?<method_name>[a-z0-9_]+[?!]?)(?:\((?<args>.*)\))?/.freeze

        # @!method pattern_matcher?(node)
        def_node_matcher :pattern_matcher?, <<~PATTERN
          (send _ %RESTRICT_ON_SEND {str sym} {str dstr})
        PATTERN

        def on_send(node)
          return if node.arguments.none?
          return unless valid_method_name?(node)

          actual_name = node.arguments.first.value
          directives = method_directives(node)
          return too_many_directives(node) if directives.size > 1

          directive = directives.first
          return if directive_correct?(directive, actual_name)

          register_offense(node, directive, actual_name)
        end

        private

        def valid_method_name?(node)
          node.arguments.first.str_type? || node.arguments.first.sym_type?
        end

        def method_directives(node)
          comments = processed_source.ast_with_comments[node]

          comments.map do |comment|
            match = comment.text.match(REGEXP)
            next unless match

            { node: comment, method_name: match[:method_name], args: match[:args] }
          end.compact
        end

        def too_many_directives(node)
          add_offense(node, message: MSG_TOO_MANY)
        end

        def directive_correct?(directive, actual_name)
          directive && directive[:method_name] == actual_name.to_s
        end

        def register_offense(node, directive, actual_name)
          message = formatted_message(directive, actual_name, node.method_name)

          add_offense(node, message: message) do |corrector|
            if directive
              correct_directive(corrector, directive, actual_name)
            else
              insert_directive(corrector, node, actual_name)
            end
          end
        end

        def formatted_message(directive, actual_name, method_name)
          if directive
            format(MSG_WRONG_NAME, expected: actual_name, actual: directive[:method_name])
          else
            format(MSG, method: method_name)
          end
        end

        def insert_directive(corrector, node, actual_name)
          # If the pattern matcher uses arguments (`%1`, `%2`, etc.), include them in the directive
          arguments = pattern_arguments(node.arguments[1].source)

          range = range_with_surrounding_space(node.loc.expression, side: :left, newlines: false)
          indentation = range.source.match(/^\s*/)[0]
          directive = "#{indentation}# @!method #{actual_name}(#{arguments.join(', ')})\n"
          directive = "\n#{directive}" if add_newline?(node)

          corrector.insert_before(range, directive)
        end

        def pattern_arguments(pattern)
          arguments = %w[node]
          max_pattern_var = pattern.scan(/(?<=%)\d+/).map(&:to_i).max
          max_pattern_var&.times { |i| arguments << "arg#{i + 1}" }
          arguments
        end

        def add_newline?(node)
          # Determine if a blank line should be inserted before the new directive
          # in order to spread out pattern matchers
          return if node.sibling_index&.zero?
          return unless node.parent

          prev_sibling = node.parent.child_nodes[node.sibling_index - 1]
          return unless prev_sibling && pattern_matcher?(prev_sibling)

          node.loc.line == last_line(prev_sibling) + 1
        end

        def last_line(node)
          if node.last_argument.heredoc?
            node.last_argument.loc.heredoc_end.line
          else
            node.loc.last_line
          end
        end

        def correct_directive(corrector, directive, actual_name)
          correct = "@!method #{actual_name}"
          regexp = /@!method\s+#{Regexp.escape(directive[:method_name])}/

          replacement = directive[:node].text.gsub(regexp, correct)
          corrector.replace(directive[:node], replacement)
        end
      end
    end
  end
end
