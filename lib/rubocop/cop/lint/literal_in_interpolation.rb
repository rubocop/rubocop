# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for interpolated literals.
      #
      # NOTE: Array literals interpolated in regexps are not handled by this cop, but
      # by `Lint/ArrayLiteralInRegexp` instead.
      #
      # @example
      #
      #   # bad
      #   "result is #{10}"
      #
      #   # good
      #   "result is 10"
      class LiteralInInterpolation < Base
        include Interpolation
        include RangeHelp
        include PercentLiteral
        extend AutoCorrector

        MSG = 'Literal interpolation detected.'
        COMPOSITE = %i[array hash pair irange erange].freeze

        def on_interpolation(begin_node)
          final_node = begin_node.children.last
          return unless offending?(final_node)
          return unless (expanded_value = correctable_value(begin_node, final_node))

          add_offense(final_node) do |corrector|
            next if final_node.dstr_type? # nested, fixed in next iteration
            next if follows_literal_interpolation?(begin_node)

            corrector.replace(final_node.parent, replacement(final_node, expanded_value))
          end
        end

        private

        def offending?(node)
          node &&
            !special_keyword?(node) &&
            prints_as_self?(node) &&
            # Special case for `Layout/TrailingWhitespace`
            !(space_literal?(node) && ends_heredoc_line?(node)) &&
            # Handled by `Lint/ArrayLiteralInRegexp`
            !array_in_regexp?(node)
        end

        def special_keyword?(node)
          # handle strings like __FILE__
          (node.str_type? && !node.loc?(:begin)) || node.source_range.is?('__LINE__')
        end

        def array_in_regexp?(node)
          grandparent = node.parent.parent
          node.array_type? && grandparent.regexp_type?
        end

        def correctable_value(begin_node, final_node)
          value = autocorrected_value(final_node)
          value = handle_special_regexp_chars(begin_node, value)
          return if starts_interpolation_after_hash_sign?(begin_node, value)

          value = escape_trailing_hash_sign(begin_node, value)

          # %W and %I split the content into words before expansion
          # treating each interpolation as a word component, so
          # interpolation should not be removed if the expanded value
          # contains a space character.
          return if in_array_percent_literal?(begin_node) && /\s|\A\z/.match?(value)

          value
        end

        # rubocop:disable-next Metrics/MethodLength, Metrics/CyclomaticComplexity
        def autocorrected_value(node)
          case node.type
          when :int
            node.children.last.to_i.to_s
          when :float
            node.children.last.to_f.to_s
          when :str
            autocorrected_value_for_string(node)
          when :sym
            autocorrected_value_for_symbol(node)
          when :array
            autocorrected_value_for_array(node)
          when :hash
            autocorrected_value_for_hash(node)
          when :nil
            ''
          else
            node.source.gsub('"', '\"')
          end
        end

        def handle_special_regexp_chars(begin_node, value)
          parent_node = begin_node.parent

          return value unless parent_node.regexp_type? && parent_node.slash_literal? && value['/']

          # When a literal string containing a forward slash preceded by backslashes
          # is interpolated inside a regexp, the number of resultant backslashes in the
          # compiled Regexp is `(2(n+1) / 4)+1`, where `n` is the number of backslashes
          # inside the interpolation.
          # ie. 0-2 backslashes is compiled to 1, 3-6 is compiled to 3, etc.
          # This maintains that same behavior in order to ensure the Regexp behavior
          # does not change upon removing the interpolation.
          value.gsub(%r{(\\*)/}) do
            backslashes = Regexp.last_match[1]
            backslash_count = backslashes.length
            needed_backslashes = (2 * ((backslash_count + 1) / 4)) + 1

            "#{'\\' * needed_backslashes}/"
          end
        end

        def starts_interpolation_after_hash_sign?(begin_node, value)
          source = processed_source.buffer.source
          range = begin_node.source_range
          # Removing an empty value puts the `#` right before what follows the interpolation.
          following = "#{value}#{source[range.end_pos]}"
          return false unless following.start_with?('{', '@', '$')
          return false unless source[range.begin_pos - 1] == '#'

          unescaped_hash_sign?(source[0...range.begin_pos])
        end

        def autocorrected_value_for_string(node)
          return node.source.delete_prefix('"').delete_suffix('"') unless node.value.valid_encoding?

          escape_string_content(node.children.last)
        end

        def escape_string_content(string)
          string.gsub(/[\\"]|#(?=[@{$])/, '\\\\\&')
        end

        def autocorrected_value_for_symbol(node)
          end_pos =
            node.loc.end ? node.loc.end.begin_pos : node.source_range.end_pos

          range_between(node.loc.begin.end_pos, end_pos).source.gsub('"', '\"')
        end

        def autocorrected_value_in_hash_for_symbol(node)
          escape_string_content(node.value.inspect)
        end

        def autocorrected_value_for_array(node)
          return node.source.gsub('"', '\"') unless node.percent_literal?

          contents_range(node).source.split.to_s.gsub('"', '\"')
        end

        def autocorrected_value_for_hash(node)
          hash_string = node.children.map do |child|
            key = autocorrected_value_in_hash(child.key)
            value = autocorrected_value_in_hash(child.value)
            "#{key}=>#{value}"
          end.join(', ')

          "{#{hash_string}}"
        end

        # rubocop:disable-next Metrics/MethodLength, Metrics/AbcSize
        def autocorrected_value_in_hash(node)
          case node.type
          when :int
            node.children.last.to_i.to_s
          when :float
            node.children.last.to_f.to_s
          when :str
            escape_string_content(node.value.inspect)
          when :sym
            autocorrected_value_in_hash_for_symbol(node)
          when :array
            autocorrected_value_for_array(node)
          when :hash
            autocorrected_value_for_hash(node)
          else
            node.source.gsub('"', '\"')
          end
        end

        # Does node print its own source when converted to a string?
        def prints_as_self?(node)
          node.basic_literal? ||
            (COMPOSITE.include?(node.type) && node.children.all? { |child| prints_as_self?(child) })
        end

        def space_literal?(node)
          # `String#blank?` misses Unicode spaces such as U+3000 that
          # `Layout/TrailingWhitespace` treats as trailing whitespace.
          node.str_type? && node.value.valid_encoding? && node.value.match?(/\A[[:space:]]*\z/)
        end

        def ends_heredoc_line?(node)
          grandparent = node.parent.parent
          return false unless grandparent&.dstr_type? && grandparent.heredoc?

          line = processed_source.lines[node.last_line - 1]

          line.size == node.parent.source_range.last_column
        end

        def in_array_percent_literal?(node)
          parent = node.parent
          return false unless parent.type?(:dstr, :dsym)

          grandparent = parent.parent
          grandparent&.array_type? && grandparent.percent_literal?
        end

        def escape_trailing_hash_sign(begin_node, value)
          following = processed_source.buffer.source[begin_node.source_range.end_pos]
          return value unless %w[{ @ $].include?(following) && unescaped_hash_sign?(value)

          "#{value.delete_suffix('#')}\\#"
        end

        def unescaped_hash_sign?(text)
          text.end_with?('#') && text.delete_suffix('#')[/\\*\z/].length.even?
        end

        # Each interpolation is checked against the original source, so correcting it in the
        # same pass as a preceding one that leaves a `#` (or nothing) could join that `#` and
        # a `{` from this one. It's left for the next iteration instead.
        def follows_literal_interpolation?(begin_node)
          previous = begin_node.left_sibling
          return false unless previous&.begin_type? && offending?(previous.children.last)

          value = correctable_value(previous, previous.children.last)
          value && (value.empty? || value.end_with?('#'))
        end

        def replacement(node, expanded_value)
          return expanded_value unless node.str_type? && !node.value.valid_encoding?

          node.source.delete_prefix('"').delete_suffix('"')
        end
      end
    end
  end
end
