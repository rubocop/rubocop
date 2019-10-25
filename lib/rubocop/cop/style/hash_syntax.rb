# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks hash literal syntax.
      #
      # It can enforce either the use of the class hash rocket syntax or
      # the use of the newer Ruby 1.9 syntax (when applicable).
      #
      # A separate offense is registered for each problematic pair.
      #
      # The supported styles are:
      #
      # * ruby19 - forces use of the 1.9 syntax (e.g. `{a: 1}`) when hashes have
      #   all symbols for keys
      # * hash_rockets - forces use of hash rockets for all hashes
      # * no_mixed_keys - simply checks for hashes with mixed syntaxes
      # * ruby19_no_mixed_keys - forces use of ruby 1.9 syntax and forbids mixed
      #   syntax hashes
      #
      # @example EnforcedStyle: ruby19 (default)
      #   # bad
      #   {:a => 2}
      #   {b: 1, :c => 2}
      #
      #   # good
      #   {a: 2, b: 1}
      #   {:c => 2, 'd' => 2} # acceptable since 'd' isn't a symbol
      #   {d: 1, 'e' => 2} # technically not forbidden
      #
      # @example EnforcedStyle: hash_rockets
      #   # bad
      #   {a: 1, b: 2}
      #   {c: 1, 'd' => 5}
      #
      #   # good
      #   {:a => 1, :b => 2}
      #
      # @example EnforcedStyle: no_mixed_keys
      #   # bad
      #   {:a => 1, b: 2}
      #   {c: 1, 'd' => 2}
      #
      #   # good
      #   {:a => 1, :b => 2}
      #   {c: 1, d: 2}
      #
      # @example EnforcedStyle: ruby19_no_mixed_keys
      #   # bad
      #   {:a => 1, :b => 2}
      #   {c: 2, 'd' => 3} # should just use hash rockets
      #
      #   # good
      #   {a: 1, b: 2}
      #   {:c => 3, 'd' => 4}
      class HashSyntax < Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG_19 = 'Use the new Ruby 1.9 hash syntax.'
        MSG_NO_MIXED_KEYS = "Don't mix styles in the same hash."
        MSG_HASH_ROCKETS = 'Use hash rockets syntax.'

        def on_hash(node)
          pairs = node.pairs

          return if pairs.empty?

          if style == :hash_rockets || force_hash_rockets?(pairs)
            hash_rockets_check(pairs)
          elsif style == :ruby19_no_mixed_keys
            ruby19_no_mixed_keys_check(pairs)
          elsif style == :no_mixed_keys
            no_mixed_keys_check(pairs)
          else
            ruby19_check(pairs)
          end
        end

        def ruby19_check(pairs)
          check(pairs, '=>', MSG_19) if sym_indices?(pairs)
        end

        def hash_rockets_check(pairs)
          check(pairs, ':', MSG_HASH_ROCKETS)
        end

        def ruby19_no_mixed_keys_check(pairs)
          if force_hash_rockets?(pairs)
            check(pairs, ':', MSG_HASH_ROCKETS)
          elsif sym_indices?(pairs)
            check(pairs, '=>', MSG_19)
          else
            check(pairs, ':', MSG_NO_MIXED_KEYS)
          end
        end

        def no_mixed_keys_check(pairs)
          if !sym_indices?(pairs)
            check(pairs, ':', MSG_NO_MIXED_KEYS)
          else
            check(pairs, pairs.first.inverse_delimiter, MSG_NO_MIXED_KEYS)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if style == :hash_rockets || force_hash_rockets?(node.parent.pairs)
              autocorrect_hash_rockets(corrector, node)
            elsif style == :ruby19_no_mixed_keys || style == :no_mixed_keys
              autocorrect_no_mixed_keys(corrector, node)
            else
              autocorrect_ruby19(corrector, node)
            end
          end
        end

        def alternative_style
          case style
          when :hash_rockets
            :ruby19
          when :ruby19, :ruby19_no_mixed_keys
            :hash_rockets
          end
        end

        private

        def sym_indices?(pairs)
          pairs.all? { |p| word_symbol_pair?(p) }
        end

        def word_symbol_pair?(pair)
          return false unless pair.key.sym_type? || pair.key.dsym_type?

          acceptable_19_syntax_symbol?(pair.key.source)
        end

        def acceptable_19_syntax_symbol?(sym_name)
          sym_name.sub!(/\A:/, '')

          if cop_config['PreferHashRocketsForNonAlnumEndingSymbols']
            # Prefer { :production? => false } over { production?: false } and
            # similarly for other non-alnum final characters (except quotes,
            # to prefer { "x y": 1 } over { :"x y" => 1 }).
            return false unless sym_name =~ /[\p{Alnum}"']\z/
          end

          # Most hash keys can be matched against a simple regex.
          return true if sym_name =~ /\A[_a-z]\w*[?!]?\z/i

          # For more complicated hash keys, let the parser validate the syntax.
          parse("{ #{sym_name}: :foo }").valid_syntax?
        end

        def check(pairs, delim, msg)
          pairs.each do |pair|
            if pair.delimiter == delim
              location = pair.source_range.begin.join(pair.loc.operator)
              add_offense(pair, location: location, message: msg) do
                opposite_style_detected
              end
            else
              correct_style_detected
            end
          end
        end

        def autocorrect_ruby19(corrector, pair_node)
          key = pair_node.key.source_range
          op = pair_node.loc.operator

          range = key.join(op)
          range = range_with_surrounding_space(range: range, side: :right)

          space = argument_without_space?(pair_node.parent) ? ' ' : ''

          corrector.replace(
            range,
            range.source.sub(/^:(.*\S)\s*=>\s*$/, space.to_s + '\1: ')
          )
        end

        def argument_without_space?(node)
          node.argument? &&
            node.loc.expression.begin_pos == node.parent.loc.selector.end_pos
        end

        def autocorrect_hash_rockets(corrector, pair_node)
          key = pair_node.key.source_range
          op = pair_node.loc.operator

          corrector.insert_after(key, pair_node.inverse_delimiter(true))
          corrector.insert_before(key, ':')
          corrector.remove(range_with_surrounding_space(range: op))
        end

        def autocorrect_no_mixed_keys(corrector, pair_node)
          if pair_node.colon?
            autocorrect_hash_rockets(corrector, pair_node)
          else
            autocorrect_ruby19(corrector, pair_node)
          end
        end

        def force_hash_rockets?(pairs)
          cop_config['UseHashRocketsWithSymbolValues'] &&
            pairs.map(&:value).any?(&:sym_type?)
        end
      end
    end
  end
end
