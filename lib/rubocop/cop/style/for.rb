# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of the *for* keyword, or *each* method. The
      # preferred alternative is set in the EnforcedStyle configuration
      # parameter. An *each* call with a block on a single line is always
      # allowed, however.
      class For < Cop
        def on_for(node)
          if style == :each
            convention(node, :keyword, 'Prefer *each* over *for*.')
          end
        end

        def on_block(node)
          return if style == :each
          return if block_length(node) == 0

          method, _args, _body = *node
          if method.type == :send
            _receiver, method_name, *args = *method
            if method_name == :each && args.empty?
              end_pos = method.loc.expression.end_pos
              range = Parser::Source::Range.new(processed_source.buffer,
                                                end_pos - 'each'.length,
                                                end_pos)
              convention(range, range, 'Prefer *for* over *each*.')
            end
          end
        end

        private

        def style
          s = cop_config['EnforcedStyle']
          case s
          when 'for', 'each' then s.to_sym
          else fail "Unknown EnforcedStyle: #{s}"
          end
        end
      end
    end
  end
end
