# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether the rescue and ensure keywords are aligned
      # properly.
      #
      # @example
      #
      #   # bad
      #   begin
      #     something
      #     rescue
      #     puts 'error'
      #   end
      #
      #   # good
      #   begin
      #     something
      #   rescue
      #     puts 'error'
      #   end
      class RescueEnsureAlignment < Cop
        MSG = '`%s` at %d, %d is not aligned with `end` at %d, %d.'.freeze

        def on_resbody(node)
          check(node) unless modifier?(node)
        end

        def on_ensure(node)
          check(node)
        end

        def investigate(processed_source)
          @modifier_locations =
            processed_source.tokens.each_with_object([]) do |token, locations|
              next unless token.type == :kRESCUE_MOD
              locations << token.pos
            end
        end

        def autocorrect(node)
          whitespace = whitespace_range(node)
          return false unless whitespace.source.strip.empty?

          new_column = ancestor_node(node).loc.end.column
          ->(corrector) { corrector.replace(whitespace, ' ' * new_column) }
        end

        private

        def check(node)
          end_loc = ancestor_node(node).loc.end
          kw_loc = node.loc.keyword

          return if end_loc.column == kw_loc.column
          return if end_loc.line == kw_loc.line

          add_offense(node, kw_loc, format_message(kw_loc, end_loc))
        end

        def format_message(kw_loc, end_loc)
          format(MSG, kw_loc.source, kw_loc.line, kw_loc.column, end_loc.line,
                 end_loc.column)
        end

        def modifier?(node)
          return false unless @modifier_locations.respond_to?(:include?)
          @modifier_locations.include?(node.loc.keyword)
        end

        def whitespace_range(node)
          begin_pos = node.loc.keyword.begin_pos
          current_column = node.loc.keyword.column

          range_between(begin_pos - current_column, begin_pos)
        end

        def ancestor_node(node)
          node.each_ancestor(:kwbegin, :def, :defs, :class, :module).first
        end
      end
    end
  end
end
