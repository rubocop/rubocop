# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use `next` to skip iteration instead of a condition at the end.
      #
      # @example
      #   # bad
      #   [1, 2].each do |a|
      #     if a == 1 do
      #       puts a
      #     end
      #   end
      #
      #   # good
      #   [1, 2].each do |a|
      #     next unless a == 1
      #     puts a
      #   end
      class Next < Cop
        include IfNode
        include ConfigurableEnforcedStyle
        include MinBodyLength

        MSG = 'Use `next` to skip iteration.'.freeze
        EXIT_TYPES = [:break, :return].freeze
        EACH_ = 'each_'.freeze
        ENUMERATORS = [:collect, :collect_concat, :detect, :downto, :each,
                       :find, :find_all, :find_index, :inject, :loop, :map!,
                       :map, :reduce, :reject, :reject!, :reverse_each, :select,
                       :select!, :times, :upto].freeze

        def investigate(_processed_source)
          # When correcting nested offenses, we need to keep track of how much
          # we have adjusted the indentation of each line
          @reindented_lines = Hash.new(0)
        end

        def on_block(node)
          block_owner, _, body = *node
          return unless block_owner.send_type?
          return unless body && ends_with_condition?(body)

          _, method_name = *block_owner
          return unless enumerator?(method_name)

          offense_node = offense_node(body)
          add_offense(offense_node, offense_location(offense_node), MSG)
        end

        def on_while(node)
          _, body = *node
          return unless body && ends_with_condition?(body)

          offense_node = offense_node(body)
          add_offense(offense_node, offense_location(offense_node), MSG)
        end
        alias on_until on_while

        def on_for(node)
          _, _, body = *node
          return unless body && ends_with_condition?(body)

          offense_node = offense_node(body)
          add_offense(offense_node, offense_location(offense_node), MSG)
        end

        private

        def enumerator?(method_name)
          ENUMERATORS.include?(method_name) ||
            method_name.to_s.start_with?(EACH_)
        end

        def ends_with_condition?(body)
          return true if simple_if_without_break?(body)

          body.begin_type? && simple_if_without_break?(body.children.last)
        end

        def simple_if_without_break?(node)
          return false unless node.if_type?
          return false if ternary?(node)
          return false if if_else?(node)
          return false if style == :skip_modifier_ifs && modifier_if?(node)
          return false if !modifier_if?(node) && !min_body_length?(node)

          # The `if` node must have only `if` body since we excluded `if` with
          # `else` above.
          _conditional, if_body, _else_body = *node
          return true unless if_body

          !EXIT_TYPES.include?(if_body.type)
        end

        def offense_node(body)
          *_, condition = *body
          (condition && condition.if_type?) ? condition : body
        end

        def offense_location(offense_node)
          condition_expression, = *offense_node
          offense_begin_pos = offense_node.source_range.begin
          offense_begin_pos.join(condition_expression.source_range)
        end

        def autocorrect(node)
          lambda do |corrector|
            if modifier_if?(node)
              autocorrect_modifier(corrector, node)
            else
              autocorrect_block(corrector, node)
            end
          end
        end

        def autocorrect_modifier(corrector, node)
          cond, if_body, else_body = *node
          body = if_body || else_body

          replacement = "next #{opposite_kw(if_body)} #{cond.source}\n" \
                        "#{' ' * node.source_range.column}#{body.source}"

          corrector.replace(node.source_range, replacement)
        end

        def autocorrect_block(corrector, node)
          cond, if_body, = *node

          next_code = "next #{opposite_kw(if_body)} #{cond.source}"
          corrector.insert_before(node.source_range, next_code)

          corrector.remove(cond_range(node, cond))
          corrector.remove(end_range(node))

          # end_range starts with the final newline of the if body
          reindent_lines = (node.source_range.line + 1)...node.loc.end.line
          reindent_lines = reindent_lines.to_a - heredoc_lines(node)
          reindent(reindent_lines, cond, corrector)
        end

        def opposite_kw(if_body)
          if_body.nil? ? 'if' : 'unless'
        end

        def cond_range(node, cond)
          end_pos = if node.loc.begin
                      node.loc.begin.end_pos # after "then"
                    else
                      cond.source_range.end_pos
                    end
          Parser::Source::Range.new(node.source_range.source_buffer,
                                    node.source_range.begin_pos,
                                    end_pos)
        end

        def end_range(node)
          source_buffer = node.source_range.source_buffer
          end_pos = node.loc.end.end_pos
          begin_pos = node.loc.end.begin_pos - node.source_range.column
          begin_pos -= 1 if end_followed_by_whitespace_only?(source_buffer,
                                                             end_pos)

          Parser::Source::Range.new(source_buffer, begin_pos, end_pos)
        end

        def end_followed_by_whitespace_only?(source_buffer, end_pos)
          source_buffer.source[end_pos..-1] =~ /\A\s*$/
        end

        # Adjust indentation of `lines` to match `node`
        def reindent(lines, node, corrector)
          range  = node.source_range
          buffer = range.source_buffer

          target_indent = range.source_line =~ /\S/

          # Skip blank lines
          lines.reject! { |lineno| buffer.source_line(lineno) =~ /\A\s*\z/ }
          return if lines.empty?

          actual_indent = lines.map do |lineno|
            buffer.source_line(lineno) =~ /\S/
          end.min

          delta = actual_indent - target_indent
          lines.each do |lineno|
            adjustment = delta
            adjustment += @reindented_lines[lineno]
            @reindented_lines[lineno] = adjustment

            if adjustment > 0
              corrector.remove_leading(buffer.line_range(lineno), adjustment)
            elsif adjustment < 0
              corrector.insert_before(buffer.line_range(lineno),
                                      ' ' * -adjustment)
            end
          end
        end

        def heredoc_lines(node)
          node.each_node(:dstr)
              .select { |n| n.loc.respond_to?(:heredoc_body) }
              .map { |n| n.loc.heredoc_body }
              .flat_map { |b| (b.line...b.last_line).to_a }
        end
      end
    end
  end
end
