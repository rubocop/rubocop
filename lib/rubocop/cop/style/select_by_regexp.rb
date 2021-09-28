# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for places where an subset of an array
      # is calculated based on a `Regexp` match, and suggests `grep` or
      # `grep_v` instead.
      #
      # NOTE: `grep` and `grep_v` were optimized when used without a block
      # in Ruby 3.0, but may be slower in previous versions.
      # See https://bugs.ruby-lang.org/issues/17030
      #
      # @safety
      #   Autocorrection is marked as unsafe because `MatchData` will
      #   not be created by `grep`, but may have previously been relied
      #   upon after the `match?` or `=~` call.
      #
      # @example
      #   # bad (select or find_all)
      #   array.select { |x| x.match? /regexp/ }
      #   array.select { |x| /regexp/.match?(x) }
      #   array.select { |x| x =~ /regexp/ }
      #   array.select { |x| /regexp/ =~ x }
      #
      #   # bad (reject)
      #   array.reject { |x| x.match? /regexp/ }
      #   array.reject { |x| /regexp/.match?(x) }
      #   array.reject { |x| x =~ /regexp/ }
      #   array.reject { |x| /regexp/ =~ x }
      #
      #   # good
      #   array.grep(regexp)
      #   array.grep_v(regexp)
      class SelectByRegexp < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Prefer `%<replacement>s` to `%<original_method>s` with a regexp match.'
        RESTRICT_ON_SEND = %i[select find_all reject].freeze
        REPLACEMENTS = { select: 'grep', find_all: 'grep', reject: 'grep_v' }.freeze
        REGEXP_METHODS = %i[match? =~].to_set.freeze

        # @!method regexp_match?(node)
        def_node_matcher :regexp_match?, <<~PATTERN
          {
            (block send (args (arg $_)) ${(send _ %REGEXP_METHODS _) match-with-lvasgn})
            (numblock send $1 ${(send _ %REGEXP_METHODS _) match-with-lvasgn})
          }
        PATTERN

        # @!method calls_lvar?(node, name)
        def_node_matcher :calls_lvar?, <<~PATTERN
          {
            (send (lvar %1) ...)
            (send ... (lvar %1))
            (match-with-lvasgn regexp (lvar %1))
          }
        PATTERN

        def on_send(node)
          return unless (block_node = node.block_node)
          return if block_node.body.begin_type?
          return unless (regexp_method_send_node = extract_send_node(block_node))

          regexp = find_regexp(regexp_method_send_node)
          register_offense(node, block_node, regexp)
        end

        private

        def register_offense(node, block_node, regexp)
          replacement = REPLACEMENTS[node.method_name.to_sym]
          message = format(MSG, replacement: replacement, original_method: node.method_name)

          add_offense(block_node, message: message) do |corrector|
            # Only correct if it can be determined what the regexp is
            if regexp
              range = range_between(node.loc.selector.begin_pos, block_node.loc.end.end_pos)
              corrector.replace(range, "#{replacement}(#{regexp.source})")
            end
          end
        end

        def extract_send_node(block_node)
          return unless (block_arg_name, regexp_method_send_node = regexp_match?(block_node))

          block_arg_name = :"_#{block_arg_name}" if block_node.numblock_type?
          return unless calls_lvar?(regexp_method_send_node, block_arg_name)

          regexp_method_send_node
        end

        def find_regexp(node)
          return node.child_nodes.first if node.match_with_lvasgn_type?

          if node.receiver.lvar_type?
            node.first_argument
          elsif node.first_argument.lvar_type?
            node.receiver
          end
        end
      end
    end
  end
end
