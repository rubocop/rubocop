# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks if empty lines exist around the bodies of `begin`
      # sections. This cop doesn't check empty lines at `begin` body
      # beginning/end and around method definition body.
      # `Layout/EmptyLinesAroundBeginBody` or `Layout/EmptyLinesAroundMethodBody`
      # can be used for this purpose.
      #
      # @example
      #
      #   # good
      #
      #   begin
      #     do_something
      #   rescue
      #     do_something2
      #   else
      #     do_something3
      #   ensure
      #     do_something4
      #   end
      #
      #   # good
      #
      #   def foo
      #     do_something
      #   rescue
      #     do_something2
      #   end
      #
      #   # bad
      #
      #   begin
      #     do_something
      #
      #   rescue
      #
      #     do_something2
      #
      #   else
      #
      #     do_something3
      #
      #   ensure
      #
      #     do_something4
      #   end
      #
      #   # bad
      #
      #   def foo
      #     do_something
      #
      #   rescue
      #
      #     do_something2
      #   end
      class EmptyLinesAroundExceptionHandlingKeywords < Base
        include EmptyLinesAroundBody
        extend AutoCorrector

        MSG = 'Extra empty line detected %<location>s the `%<keyword>s`.'

        def on_def(node)
          return if node.any_def_type? && node.endless?

          check_body(node.body, node.loc.line)
        end
        alias on_defs on_def
        alias on_block on_def
        alias on_numblock on_def
        alias on_itblock on_def

        def on_kwbegin(node)
          check_body(node.children.first, node.loc.line)
        end

        private

        def check_body(body, line_of_def_or_kwbegin)
          locations = keyword_locations(body)

          locations.each do |loc|
            line = loc.line
            next if line == line_of_def_or_kwbegin || last_body_and_end_on_same_line?(body)

            keyword = loc.source

            # below the keyword
            unless ending_left_to_block_body_cop?(body, line)
              check_line(style, line, message('after', keyword), &:empty?)
            end

            # above the keyword
            unless beginning_left_to_block_body_cop?(body, line)
              check_line(style, line - 2, message('before', keyword), &:empty?)
            end
          end
        end

        def last_body_and_end_on_same_line?(body)
          end_keyword_line = body.parent.loc.end.line
          return body.loc.last_line == end_keyword_line unless body.rescue_type?

          last_body_line = body.else? ? body.loc.else.line : body.resbody_branches.last.loc.line

          last_body_line == end_keyword_line
        end

        def message(location, keyword)
          format(MSG, location: location, keyword: keyword)
        end

        def style
          :no_empty_lines
        end

        def keyword_locations(node)
          return [] unless node

          case node.type
          when :rescue
            keyword_locations_in_rescue(node)
          when :ensure
            keyword_locations_in_ensure(node)
          else
            []
          end
        end

        def ending_left_to_block_body_cop?(body, keyword_line)
          return false unless block_body_with_empty_lines_style?(body)

          only_empty_lines_until_end?(body, keyword_line)
        end

        def block_body_with_empty_lines_style?(body)
          return false unless body.parent.any_block_type?

          cop_config = config.for_enabled_cop('Layout/EmptyLinesAroundBlockBody')
          cop_config['EnforcedStyle'] == 'empty_lines'
        end

        def beginning_left_to_block_body_cop?(body, keyword_line)
          return false unless block_body_with_empty_lines_style?(body)

          only_empty_lines_since_beginning?(body, keyword_line)
        end

        def keyword_locations_in_rescue(node)
          [node.loc.else, *node.resbody_branches.map { |body| body.loc.keyword }].compact
        end

        def keyword_locations_in_ensure(node)
          rescue_body_without_ensure = node.children.first
          [
            node.loc.keyword,
            *keyword_locations(rescue_body_without_ensure)
          ]
        end

        def only_empty_lines_until_end?(body, keyword_line)
          end_line = body.parent.loc.end.line
          next_line = (keyword_line + 1).upto(end_line).find do |line_number|
            !processed_source.lines[line_number - 1].strip.empty?
          end

          next_line == end_line
        end

        def only_empty_lines_since_beginning?(body, keyword_line)
          start_line = block_body_start_line(body.parent)
          previous_line = (keyword_line - 1).downto(start_line).find do |line_number|
            !processed_source.lines[line_number - 1].strip.empty?
          end

          previous_line == start_line
        end

        def block_body_start_line(block_node)
          return block_node.loc.begin.line unless block_node.arguments?

          [block_node.loc.begin.line, block_node.arguments.last_line].max
        end
      end
    end
  end
end
