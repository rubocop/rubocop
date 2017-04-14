# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks if empty lines exist around the bodies of `begin`
      # sections. This cop doesn't check empty lines at `begin` body
      # beginning/end and around method definition body.
      # `Style/EmptyLinesAroundBeginBody` or `Style/EmptyLinesAroundMethodBody`
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
      class EmptyLinesAroundExceptionHandlingKeywords < Cop
        include EmptyLinesAroundBody
        include OnMethodDef

        MSG = 'Extra empty line detected %s the `%s`.'.freeze

        def on_method_def(_node, _method_name, _args, body)
          check_body(body)
        end

        def on_kwbegin(node)
          body, = *node
          check_body(body)
        end

        private

        def check_body(node)
          locations = keyword_locations(node)
          locations.each do |loc|
            line = loc.line
            keyword = loc.source
            # below the keyword
            check_line(style, line, format(MSG, 'after', keyword), &:empty?)
            # above the keyword
            check_line(style,
                       line - 2,
                       format(MSG, 'before', keyword),
                       &:empty?)
          end
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

        def keyword_locations_in_rescue(node)
          _begin_body, *resbodies, _else_body = *node
          [
            node.loc.else,
            *resbodies.map { |body| body.loc.keyword }
          ].compact
        end

        def keyword_locations_in_ensure(node)
          ensure_body, = *node
          [
            node.loc.keyword,
            *keyword_locations(ensure_body)
          ]
        end
      end
    end
  end
end
