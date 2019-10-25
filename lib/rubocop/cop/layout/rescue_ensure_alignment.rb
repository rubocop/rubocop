# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
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
        include RangeHelp

        MSG = '`%<kw_loc>s` at %<kw_loc_line>d, %<kw_loc_column>d is not ' \
              'aligned with `%<beginning>s` at ' \
              '%<begin_loc_line>d, %<begin_loc_column>d.'
        ANCESTOR_TYPES = %i[kwbegin def defs class module].freeze
        RUBY_2_5_ANCESTOR_TYPES = (ANCESTOR_TYPES + %i[block]).freeze
        ANCESTOR_TYPES_WITH_ACCESS_MODIFIERS = %i[def defs].freeze
        ALTERNATIVE_ACCESS_MODIFIERS = %i[public_class_method
                                          private_class_method].freeze

        def on_resbody(node)
          check(node) unless modifier?(node)
        end

        def on_ensure(node)
          check(node)
        end

        def autocorrect(node)
          whitespace = whitespace_range(node)
          # Some inline node is sitting before current node.
          return nil unless whitespace.source.strip.empty?

          alignment_node = alignment_node(node)
          return false if alignment_node.nil?

          new_column = alignment_node.loc.column
          ->(corrector) { corrector.replace(whitespace, ' ' * new_column) }
        end

        def investigate(processed_source)
          @modifier_locations =
            processed_source.tokens.each_with_object([]) do |token, locations|
              next unless token.rescue_modifier?

              locations << token.pos
            end
        end

        private

        # Check alignment of node with rescue or ensure modifiers.

        def check(node)
          alignment_node = alignment_node(node)
          return if alignment_node.nil?

          alignment_loc = alignment_node.loc.expression
          kw_loc        = node.loc.keyword

          return if
            alignment_loc.column == kw_loc.column ||
            alignment_loc.line   == kw_loc.line

          add_offense(
            node,
            location: kw_loc,
            message: format_message(alignment_node, alignment_loc, kw_loc)
          )
        end

        def format_message(alignment_node, alignment_loc, kw_loc)
          format(
            MSG,
            kw_loc: kw_loc.source,
            kw_loc_line: kw_loc.line,
            kw_loc_column: kw_loc.column,
            beginning: alignment_source(alignment_node, alignment_loc),
            begin_loc_line: alignment_loc.line,
            begin_loc_column: alignment_loc.column
          )
        end

        # rubocop:disable Metrics/AbcSize
        def alignment_source(node, starting_loc)
          ending_loc =
            case node.type
            when :block, :kwbegin
              node.loc.begin
            when :def, :defs, :class, :module,
                 :lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn
              node.loc.name
            when :masgn
              mlhs_node, = *node
              mlhs_node.loc.expression
            else
              # It is a wrapper with access modifier.
              node.child_nodes.first.loc.name
            end

          range_between(starting_loc.begin_pos, ending_loc.end_pos).source
        end
        # rubocop:enable Metrics/AbcSize

        # We will use ancestor or wrapper with access modifier.

        def alignment_node(node)
          ancestor_node = ancestor_node(node)

          return ancestor_node if ancestor_node.nil? ||
                                  ancestor_node.kwbegin_type?

          assignment_node = assignment_node(ancestor_node)
          return assignment_node if same_line?(ancestor_node, assignment_node)

          access_modifier_node = access_modifier_node(ancestor_node)
          return access_modifier_node unless access_modifier_node.nil?

          ancestor_node
        end

        def ancestor_node(node)
          ancestor_types =
            if target_ruby_version >= 2.5
              RUBY_2_5_ANCESTOR_TYPES
            else
              ANCESTOR_TYPES
            end

          node.each_ancestor(*ancestor_types).first
        end

        def assignment_node(node)
          assignment_node = node.ancestors.first
          return nil unless
            assignment_node&.assignment?

          assignment_node
        end

        def access_modifier_node(node)
          return nil unless
            ANCESTOR_TYPES_WITH_ACCESS_MODIFIERS.include?(node.type)

          access_modifier_node = node.ancestors.first
          return nil unless access_modifier?(access_modifier_node)

          access_modifier_node
        end

        def modifier?(node)
          return false unless @modifier_locations.respond_to?(:include?)

          @modifier_locations.include?(node.loc.keyword)
        end

        def whitespace_range(node)
          begin_pos      = node.loc.keyword.begin_pos
          current_column = node.loc.keyword.column

          range_between(begin_pos - current_column, begin_pos)
        end

        def access_modifier?(node)
          return true if node.respond_to?(:access_modifier?) &&
                         node.access_modifier?

          return true if node.respond_to?(:method_name) &&
                         ALTERNATIVE_ACCESS_MODIFIERS.include?(node.method_name)

          false
        end
      end
    end
  end
end
