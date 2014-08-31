# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for braces in method calls with hash parameters.
      class BracesAroundHashParameters < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          _receiver, method_name, *args = *node

          # Discard attr writer methods.
          return if method_name.to_s.end_with?('=')
          # Discard operator methods.
          return if operator?(method_name)

          # We care only for the last argument.
          arg = args.last

          check(arg, args) if non_empty_hash?(arg)
        end

        private

        def check(arg, args)
          if style == :no_braces
            if !braces?(arg) || all_hashes?(args)
              correct_style_detected
            else
              add_offense(arg, :expression,
                          'Redundant curly braces around a hash parameter.') do
                opposite_style_detected
              end
            end
          elsif braces?(arg)
            correct_style_detected
          else
            add_offense(arg, :expression,
                        'Missing curly braces around a hash parameter.') do
              opposite_style_detected
            end
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            if style == :no_braces
              corrector.remove(node.loc.begin)
              corrector.remove(node.loc.end)
              remove_leading_whitespace(node, corrector)
              remove_trailing_comma_and_whitespace(node, corrector)
            elsif style == :braces
              corrector.insert_before(node.loc.expression, '{')
              corrector.insert_after(node.loc.expression, '}')
            end
          end
        end

        def remove_leading_whitespace(node, corrector)
          corrector.remove(
            Parser::Source::Range.new(
              node.loc.expression.source_buffer,
              node.loc.begin.end_pos,
              node.children.first.loc.expression.begin_pos
            )
          )
        end

        def remove_trailing_comma_and_whitespace(node, corrector)
          corrector.remove(
            Parser::Source::Range.new(
              node.loc.expression.source_buffer,
              node.children.last.loc.expression.end_pos,
              node.loc.end.begin_pos
            )
          )
        end

        def non_empty_hash?(arg)
          arg && arg.type == :hash && arg.children.any?
        end

        def braces?(arg)
          arg.loc.begin
        end

        def all_hashes?(args)
          args.length > 1 && args.all? { |a| a.type == :hash }
        end
      end
    end
  end
end
