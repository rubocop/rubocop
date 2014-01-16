# encoding: utf-8

module Rubocop
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
              add_offence(arg, :expression,
                          'Redundant curly braces around a hash parameter.') do
                opposite_style_detected
              end
            end
          elsif braces?(arg)
            correct_style_detected
          else
            add_offence(arg, :expression,
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
              remove_trailing_comma(node, corrector)
            elsif style == :braces
              corrector.insert_before(node.loc.expression, '{')
              corrector.insert_after(node.loc.expression, '}')
            end
          end
        end

        def remove_trailing_comma(node, corrector)
          sb = node.loc.end.source_buffer
          pos_after_last_pair = node.children.last.loc.expression.end_pos
          range_after_last_pair =
            Parser::Source::Range.new(sb, pos_after_last_pair,
                                      node.loc.end.begin_pos)
          trailing_comma_offset = range_after_last_pair.source =~ /,/
          if trailing_comma_offset
            comma_begin = pos_after_last_pair + trailing_comma_offset
            corrector.remove(Parser::Source::Range.new(sb, comma_begin,
                                                       comma_begin + 1))
          end
        end

        def non_empty_hash?(arg)
          arg && arg.type == :hash && arg.children.any?
        end

        def braces?(arg)
          !arg.loc.begin.nil?
        end

        def all_hashes?(args)
          args.length > 1 && args.all? { |a| a.type == :hash }
        end
      end
    end
  end
end
