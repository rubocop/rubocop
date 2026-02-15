# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for redundant `keyword_init: true` option on `Struct.new`.
      #
      # Since Ruby 3.2, `Struct.new` uses keyword arguments by default
      # (keyword_init defaults to true), making explicit `keyword_init: true`
      # redundant.
      #
      # @safety
      #   This cop is unsafe for Ruby 3.1 and older where `keyword_init: true`
      #   is required for keyword argument initialization.
      #
      # @example
      #
      #   # bad
      #   Struct.new(:name, :age, keyword_init: true)
      #
      #   # good
      #   Struct.new(:name, :age)
      #
      #   # good (opts out of keyword arguments)
      #   Struct.new(:name, :age, keyword_init: false)
      #
      class RedundantStructKeywordInit < Base
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 3.2

        MSG = 'Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).'
        RESTRICT_ON_SEND = %i[new].freeze

        # @!method struct_with_keyword_init_true?(node)
        def_node_matcher :struct_with_keyword_init_true?, <<~PATTERN
          (send
            (const {nil? cbase} :Struct) :new
            ...
            (hash <(pair (sym :keyword_init) true) ...>)
          )
        PATTERN

        # @!method keyword_init_pair(node)
        def_node_search :keyword_init_pair, <<~PATTERN
          (pair (sym :keyword_init) true)
        PATTERN

        def on_send(node)
          return unless struct_with_keyword_init_true?(node)

          keyword_init_pair(node) do |pair_node|
            add_offense(pair_node) do |corrector|
              autocorrect(corrector, node, pair_node)
            end
          end
        end
        alias on_csend on_send

        private

        def autocorrect(corrector, send_node, pair_node)
          hash_node = pair_node.parent
          pairs = hash_node.pairs

          if pairs.size == 1
            # If this is the only pair in the hash, remove the entire hash argument
            remove_hash_argument(corrector, send_node, hash_node)
          else
            # If there are other pairs, just remove this pair
            remove_pair_from_hash(corrector, pair_node, pairs)
          end
        end

        def remove_hash_argument(corrector, send_node, hash_node)
          # Find the comma before the hash argument
          range_to_remove = if (comma_range = find_comma_before(send_node, hash_node))
                              comma_range.join(hash_node.source_range)
                            else
                              hash_node.source_range
                            end

          corrector.remove(range_to_remove)
        end

        def remove_pair_from_hash(corrector, pair_node, all_pairs)
          index = all_pairs.index(pair_node)

          range_to_remove = if index.zero? && all_pairs.size > 1
                              # Remove first pair including the trailing comma
                              pair_node.source_range.join(all_pairs[1].source_range.begin)
                            else
                              # Remove the pair including the leading comma/space
                              all_pairs[index - 1].source_range.end.join(pair_node.source_range)
                            end

          corrector.remove(range_to_remove)
        end

        def find_comma_before(send_node, hash_node)
          # Find the argument before the hash
          args = send_node.arguments
          hash_index = args.index(hash_node)
          return nil if hash_index.nil? || hash_index.zero?

          prev_arg = args[hash_index - 1]
          range_between(prev_arg.source_range.end_pos, hash_node.source_range.begin_pos)
        end

        def range_between(start_pos, end_pos)
          Parser::Source::Range.new(processed_source.buffer, start_pos, end_pos)
        end
      end
    end
  end
end
