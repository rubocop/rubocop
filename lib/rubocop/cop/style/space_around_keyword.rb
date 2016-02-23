# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks the spacing around the keywords.
      #
      # @example
      #
      #   # bad
      #   something 'test'do|x|
      #   end
      #
      #   while(something)
      #   end
      #
      #   something = 123if test
      #
      #   # good
      #   something 'test' do |x|
      #   end
      #
      #   while (something)
      #   end
      #
      #   something = 123 if test
      class SpaceAroundKeyword < Cop
        MSG_BEFORE = 'Space before keyword `%s` is missing.'.freeze
        MSG_AFTER = 'Space after keyword `%s` is missing.'.freeze

        DO = 'do'.freeze
        ACCEPT_LEFT_PAREN =
          %w(break defined? next not rescue return super yield).freeze

        def on_and(node)
          check(node, [:operator].freeze) if node.keyword?
        end

        def on_block(node)
          check(node, [:begin, :end].freeze)
        end

        def on_break(node)
          check(node, [:keyword].freeze)
        end

        def on_case(node)
          check(node, [:keyword, :else].freeze)
        end

        def on_ensure(node)
          check(node, [:keyword].freeze)
        end

        def on_for(node)
          check(node, [:begin, :end].freeze)
        end

        def on_if(node)
          check(node, [:keyword, :else, :begin, :end].freeze, 'then'.freeze)
        end

        def on_kwbegin(node)
          check(node, [:begin, :end].freeze, nil)
        end

        def on_next(node)
          check(node, [:keyword].freeze)
        end

        def on_or(node)
          check(node, [:operator].freeze) if node.keyword?
        end

        def on_postexe(node)
          check(node, [:keyword].freeze)
        end

        def on_preexe(node)
          check(node, [:keyword].freeze)
        end

        def on_resbody(node)
          check(node, [:keyword].freeze)
        end

        def on_rescue(node)
          check(node, [:else].freeze)
        end

        def on_return(node)
          check(node, [:keyword].freeze)
        end

        def on_send(node)
          check(node, [:selector].freeze) if node.keyword_not?
        end

        def on_super(node)
          check(node, [:keyword].freeze)
        end

        def on_zsuper(node)
          check(node, [:keyword].freeze)
        end

        def on_until(node)
          check(node, [:begin, :end, :keyword].freeze)
        end

        def on_when(node)
          check(node, [:keyword].freeze)
        end

        def on_while(node)
          check(node, [:begin, :end, :keyword].freeze)
        end

        def on_yield(node)
          check(node, [:keyword].freeze)
        end

        def on_defined?(node)
          check(node, [:keyword].freeze)
        end

        private

        def check(node, locations, begin_keyword = DO)
          locations.each do |loc|
            next unless node.loc.respond_to?(loc)
            range = node.loc.public_send(loc)
            next unless range

            case loc
            when :begin then check_begin(node, range, begin_keyword)
            when :end then check_end(node, range, begin_keyword)
            else check_keyword(node, range)
            end
          end
        end

        def check_begin(node, range, begin_keyword)
          return if begin_keyword && !range.is?(begin_keyword)

          check_keyword(node, range)
        end

        def check_end(node, range, begin_keyword)
          return if begin_keyword == DO && !do?(node)

          offense(range, MSG_BEFORE) if space_before_missing?(range)
        end

        def do?(node)
          node.loc.begin && node.loc.begin.is?(DO)
        end

        def check_keyword(node, range)
          offense(range, MSG_BEFORE) if space_before_missing?(range) &&
                                        !preceded_by_operator?(node, range)
          offense(range, MSG_AFTER) if space_after_missing?(range)
        end

        def offense(range, msg)
          add_offense(range, range, msg % range.source)
        end

        def space_before_missing?(range)
          pos = range.begin_pos - 1
          return false if pos < 0
          range.source_buffer.source[pos] !~ /[\s\(\|\{\[;,\*\=]/
        end

        def space_after_missing?(range)
          pos = range.end_pos
          char = range.source_buffer.source[pos]
          return false unless char
          return false if accept_left_parenthesis?(range) && char == '('.freeze

          char !~ /[\s;,#\\\)\}\]\.]/
        end

        def accept_left_parenthesis?(range)
          ACCEPT_LEFT_PAREN.include?(range.source)
        end

        def preceded_by_operator?(node, _range)
          # regular dotted method calls bind more tightly than operators
          # so we need to climb up the AST past them
          while (ancestor = node.parent)
            return true if ancestor.and_type? || ancestor.or_type?
            return false unless ancestor.send_type?
            return true if operator?(ancestor.method_name)
            node = ancestor
          end
          false
        end

        def autocorrect(range)
          if space_before_missing?(range)
            ->(corrector) { corrector.insert_before(range, ' '.freeze) }
          else
            ->(corrector) { corrector.insert_after(range, ' '.freeze) }
          end
        end
      end
    end
  end
end
