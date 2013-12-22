# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of the *for* keyword, or *each* method. The
      # preferred alternative is set in the EnforcedStyle configuration
      # parameter. An *each* call with a block on a single line is always
      # allowed, however.
      class For < Cop
        include ConfigurableEnforcedStyle

        def on_for(node)
          if style == :each
            add_offence(node, :keyword, 'Prefer *each* over *for*.') do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def on_block(node)
          return if block_length(node) == 0

          method, _args, _body = *node
          return unless method.type == :send

          _receiver, method_name, *args = *method
          return unless method_name == :each && args.empty?

          if style == :for
            end_pos = method.loc.expression.end_pos
            range = Parser::Source::Range.new(processed_source.buffer,
                                              end_pos - 'each'.length,
                                              end_pos)
            add_offence(range, range, 'Prefer *for* over *each*.') do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end
      end
    end
  end
end
