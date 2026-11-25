# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for uses of `Integer#times` that will never yield
      # (when the integer ``<= 0``) or that will only ever yield once
      # (`1.times`).
      #
      # @safety
      #   This cop is unsafe as `times` returns its receiver, which is
      #   *usually* OK, but might change behavior.
      #
      # @example
      #   # bad
      #   -5.times { do_something }
      #   0.times { do_something }
      #   1.times { do_something  }
      #   1.times { |i| do_something(i) }
      #
      #   # good
      #   do_something
      #   do_something(1)
      class UselessTimes < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Useless call to `%<count>i.times` detected.'
        RESTRICT_ON_SEND = %i[times].freeze

        # @!method times_call?(node)
        def_node_matcher :times_call?, <<~PATTERN
          (send (int $_) :times (block-pass (sym $_))?)
        PATTERN

        # @!method block_arg(node)
        def_node_matcher :block_arg, <<~PATTERN
          (block _ (args (arg $_)) ...)
        PATTERN

        # @!method argument_references(node, name)
        def_node_search :argument_references, '$(lvar %)'

        # @!method writes_argument?(node, name)
        def_node_search :writes_argument?, <<~PATTERN
          {(argument % ...) (lvasgn % ...) (match_var %) (match_with_lvasgn #named_capture?(%) _)}
        PATTERN

        def on_send(node)
          return unless (count, proc_name = times_call?(node))
          return if count > 1

          # Get the block node if applicable
          node = node.block_node if node.block_literal?

          add_offense(node, message: format(MSG, count: count)) do |corrector|
            next if !own_line?(node) || node.parent&.send_type?

            autocorrect(corrector, count, node, proc_name)
          end
        end

        private

        def autocorrect(corrector, count, node, proc_name)
          if never_process?(count, node)
            remove_node(corrector, node)
          elsif !proc_name.empty?
            autocorrect_block_pass(corrector, node, proc_name)
          elsif node.block_type?
            autocorrect_block(corrector, node)
          end
        end

        def never_process?(count, node)
          count < 1 || (node.block_type? && node.body.nil?)
        end

        def remove_node(corrector, node)
          return if code_after?(node)

          corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
        end

        def code_after?(node)
          last_line = processed_source.buffer.source_line(node.last_line)

          last_line[node.loc.last_column..].match?(/\A\s*[^\s#]/)
        end

        def autocorrect_block_pass(corrector, node, proc_name)
          corrector.replace(node, proc_name)
        end

        def autocorrect_block(corrector, node)
          block_arg = block_arg(node)
          return unless reducible_to_body?(node, block_arg)

          source = block_arg ? substituted_body(node.body, block_arg) : node.body.source
          return unless source

          corrector.replace(node, fix_indentation(source, node))
        end

        def substituted_body(body, name)
          references = argument_references(body, name).sort_by(&:source_range)
          return unless references.all? { |variable| replaceable_reference?(variable) }

          source = body.source
          references.reverse_each do |variable|
            offset = variable.source_range.begin_pos - body.source_range.begin_pos
            source[offset, variable.source_length] = '0'
          end
          source
        end

        def replaceable_reference?(variable)
          return false if variable.parent.pin_type? || variable.each_ancestor(:defined?).any?

          !variable.parent.pair_type? || !variable.parent.value_omission?
        end

        def reducible_to_body?(node, block_arg)
          # A block with multiple arguments can't be reduced to its body (the extra arguments
          # would become undefined references), and `next`/`break`/`redo` bound to the block
          # become orphaned (a syntax error) once the block is removed.
          return false if node.arguments.size > 1 || orphans_loop_control_keyword?(node)

          # A lone non-simple argument (destructuring `|(a, b)|` or a splat `|*a|`) can't be
          # substituted either, so reducing to the body would leave it referencing an
          # undefined variable.
          return false if node.arguments.one? && block_arg.nil?
          return false if needs_enclosing_block?(node.body)

          !block_arg || !writes_argument?(node.body, block_arg)
        end

        # A `rescue` or `ensure` clause is only valid inside the block, and the source of
        # the body doesn't cover the body of a heredoc that ends it.
        def needs_enclosing_block?(body)
          body.type?(:rescue, :ensure) || body.each_node(:any_str, :xstr).any?(&:heredoc?)
        end

        def orphans_loop_control_keyword?(node)
          node.body&.each_node(:next, :break, :redo)&.any? do |control|
            inner = control.each_ancestor.take_while { |ancestor| !ancestor.equal?(node) }
            inner.none? { |ancestor| ancestor.type?(:any_block, :while, :until, :for) }
          end
        end

        def named_capture?(regexp, name)
          regexp.to_regexp.names.include?(name.to_s)
        end

        def fix_indentation(source, node)
          shift = node.body.loc.column - node.loc.column
          shift_range = begins_its_line?(node.body.source_range) ? "0,#{shift}" : shift
          excess_indentation = /\A([ \t]{#{node.loc.column}})[ \t]{#{shift_range}}/
          source_lines = source.split("\n")

          source_lines[1..].each do |line|
            line.sub!(excess_indentation, '\1')
          end
          source_lines.join("\n")
        end

        def own_line?(node)
          # If there is anything else on the line other than whitespace,
          # don't try to autocorrect
          processed_source.buffer.source_line(node.loc.line)[0...node.loc.column] !~ /\S/
        end
      end
    end
  end
end
