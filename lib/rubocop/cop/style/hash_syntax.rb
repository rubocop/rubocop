# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks hash literal syntax.
      #
      # It can enforce either the use of the class hash rocket syntax or
      # the use of the newer Ruby 1.9 syntax (when applicable).
      #
      # A separate offense is registered for each problematic pair.
      class HashSyntax < Cop
        include ConfigurableEnforcedStyle

        MSG_19 = 'Use the new Ruby 1.9 hash syntax.'.freeze
        MSG_RUBY19_NO_MIXED_KEYS = "Don't mix styles in the same hash.".freeze
        MSG_HASH_ROCKETS = 'Use hash rockets syntax.'.freeze

        @force_hash_rockets = false

        def on_hash(node)
          if cop_config['UseHashRocketsWithSymbolValues']
            pairs = *node
            @force_hash_rockets = pairs.any? { |p| symbol_value?(p) }
          end

          if style == :hash_rockets || @force_hash_rockets
            hash_rockets_check(node)
          elsif style == :ruby19_no_mixed_keys
            ruby19_no_mixed_keys_check(node)
          else
            ruby19_check(node)
          end
        end

        def ruby19_check(node)
          pairs = *node

          check(pairs, '=>', MSG_19) if sym_indices?(pairs)
        end

        def hash_rockets_check(node)
          pairs = *node

          check(pairs, ':', MSG_HASH_ROCKETS)
        end

        def ruby19_no_mixed_keys_check(node)
          pairs = *node

          if @force_hash_rockets
            check(pairs, ':', MSG_HASH_ROCKETS)
          elsif sym_indices?(pairs)
            check(pairs, '=>', MSG_19)
          else
            check(pairs, ':', MSG_RUBY19_NO_MIXED_KEYS)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if style == :hash_rockets || @force_hash_rockets
              autocorrect_hash_rockets(corrector, node)
            elsif style == :ruby19_no_mixed_keys
              autocorrect_ruby19_no_mixed_keys(corrector, node)
            else
              autocorrect_ruby19(corrector, node)
            end
          end
        end

        def alternative_style
          case style
          when :hash_rockets then
            :ruby19
          when :ruby19, :ruby19_no_mixed_keys then
            :hash_rockets
          end
        end

        private

        def symbol_value?(pair)
          _key, value = *pair

          value.sym_type?
        end

        def sym_indices?(pairs)
          pairs.all? { |p| word_symbol_pair?(p) }
        end

        def word_symbol_pair?(pair)
          key, _value = *pair

          return false unless key.sym_type?

          valid_19_syntax_symbol?(key.source)
        end

        def valid_19_syntax_symbol?(sym_name)
          sym_name.sub!(/\A:/, '')

          # Most hash keys can be matched against a simple regex.
          return true if sym_name =~ /\A[_a-z]\w*[?!]?\z/i

          # For more complicated hash keys, let the parser validate the syntax.
          parse("{ #{sym_name}: :foo }").valid_syntax?
        end

        def check(pairs, delim, msg)
          pairs.each do |pair|
            if pair.loc.operator && pair.loc.operator.is?(delim)
              add_offense(pair,
                          pair.source_range.begin.join(pair.loc.operator),
                          msg) do
                opposite_style_detected
              end
            else
              correct_style_detected
            end
          end
        end

        def autocorrect_ruby19(corrector, node)
          key = node.children.first.source_range
          op = node.loc.operator

          range = Parser::Source::Range.new(key.source_buffer,
                                            key.begin_pos, op.end_pos)
          range = range_with_surrounding_space(range, :right)
          corrector.replace(range,
                            range.source.sub(/^:(.*\S)\s*=>\s*$/, '\1: '))
        end

        def autocorrect_hash_rockets(corrector, node)
          key = node.children.first.source_range
          op = node.loc.operator

          corrector.insert_after(key, ' => ')
          corrector.insert_before(key, ':')
          corrector.remove(range_with_surrounding_space(op))
        end

        def autocorrect_ruby19_no_mixed_keys(corrector, node)
          op = node.loc.operator

          if op.is?(':')
            autocorrect_hash_rockets(corrector, node)
          else
            autocorrect_ruby19(corrector, node)
          end
        end
      end
    end
  end
end
