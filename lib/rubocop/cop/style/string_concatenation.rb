# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for places where string concatenation
      # can be replaced with string interpolation.
      #
      # The cop can autocorrect simple cases but will skip autocorrecting
      # more complex cases where the resulting code would be harder to read.
      # In those cases, it might be useful to extract statements to local
      # variables or methods which you can then interpolate in a string.
      #
      # NOTE: When concatenation between two strings is broken over multiple
      # lines, this cop does not register an offense; instead,
      # `Style/LineEndConcatenation` will pick up the offense if enabled.
      #
      # Two modes are supported:
      # 1. `aggressive` style checks and corrects all occurrences of `+` where
      # either the left or right side of `+` or `<<` is a string literal.
      # 2. `conservative` style on the other hand, checks and corrects only if
      # left side (receiver of `+` or `<<` method call) is a string literal.
      # This is useful when the receiver is some expression that returns string like `Pathname`
      # instead of a string literal.
      #
      # @safety
      #   This cop is unsafe in `aggressive` mode, as it cannot be guaranteed that
      #   the receiver is actually a string, which can result in a false positive.
      #
      # @example Mode: aggressive (default)
      #   # bad
      #   email_with_name = user.name + ' <' + user.email + '>'
      #   Pathname.new('/') + 'test'
      #
      #   # good
      #   email_with_name = "#{user.name} <#{user.email}>"
      #   email_with_name = format('%s <%s>', user.name, user.email)
      #   "#{Pathname.new('/')}test"
      #
      #   # accepted, line-end concatenation
      #   name = 'First' +
      #     'Last'
      #
      # @example Mode: conservative
      #   # bad
      #   'Hello' + user.name
      #
      #   # good
      #   "Hello #{user.name}"
      #   user.name + '!!'
      #   Pathname.new('/') + 'test'
      #
      class StringConcatenation < Base
        include Util
        include RangeHelp
        extend AutoCorrector

        MSG = 'Prefer string interpolation to string concatenation.'
        RESTRICT_ON_SEND = %i[+ <<].freeze

        # @!method string_concatenation?(node)
        def_node_matcher :string_concatenation?, <<~PATTERN
          {
            (send str_type? [#concatenation_method? $_] _)
            (send _ [#concatenation_method? $_] str_type?)
          }
        PATTERN

        def on_new_investigation
          @corrected_nodes = nil
        end

        def on_send(node)
          return unless string_concatenation?(node)
          return if line_end_concatenation?(node)

          topmost_concat_node = find_topmost_concat_node(node)
          parts = collect_parts(topmost_concat_node)
          return if mode == :conservative && !parts.first.str_type?

          register_offense(topmost_concat_node, parts)
        end

        private

        def register_offense(topmost_concat_node, parts)
          add_offense(topmost_concat_node) do |corrector|
            correctable_parts = parts.none? { |part| uncorrectable?(part) }
            if correctable_parts && !corrected_ancestor?(topmost_concat_node)
              corrector.replace(topmost_concat_node, replacement(parts))

              @corrected_nodes ||= Set.new.compare_by_identity
              @corrected_nodes.add(topmost_concat_node)
            end
          end
        end

        def line_end_concatenation?(node)
          # If the concatenation happens at the end of the line,
          # and both the receiver and argument are strings, allow
          # `Style/LineEndConcatenation` to handle it instead.
          node.receiver.str_type? &&
            node.first_argument.str_type? &&
            node.multiline? &&
            node.source =~ /(\+|<{2})\s*\n/
        end

        def find_topmost_concat_node(node)
          current = node
          while (parent = current.parent) && concat_node?(parent)
            current = parent
          end
          current
        end

        def collect_parts(node, parts = [])
          return unless node

          if concat_node?(node)
            collect_parts(node.receiver, parts)
            collect_parts(node.first_argument, parts)
          else
            parts << node
          end
        end

        def concat_node?(node)
          plus_node?(node) || shovel_node?(node)
        end

        def plus_node?(node)
          node.send_type? && node.method?(:+)
        end

        def shovel_node?(node)
          node.send_type? && node.method?(:<<)
        end

        def uncorrectable?(part)
          part.multiline? || heredoc?(part) || part.each_descendant(:block).any?
        end

        def heredoc?(node)
          return false unless node.str_type? || node.dstr_type?

          node.heredoc?
        end

        def corrected_ancestor?(node)
          node.each_ancestor(:send).any? { |ancestor| @corrected_nodes&.include?(ancestor) }
        end

        def replacement(parts)
          interpolated_parts =
            parts.map do |part|
              case part.type
              when :str
                value = part.value
                single_quoted?(part) ? value.gsub(/(\\|")/, '\\\\\&') : value.inspect[1..-2]
              when :dstr
                contents_range(part).source
              else
                "\#{#{part.source}}"
              end
            end

          "\"#{handle_quotes(interpolated_parts).join}\""
        end

        def handle_quotes(parts)
          parts.map do |part|
            part == '"' ? '\"' : part
          end
        end

        def single_quoted?(str_node)
          str_node.source.start_with?("'")
        end

        def mode
          cop_config['Mode'].to_sym
        end

        def concatenation_method?(name)
          RESTRICT_ON_SEND.include?(name)
        end
      end
    end
  end
end
