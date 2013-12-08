# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks hash literal syntax.
      #
      # It can enforce either the use of the class hash rocket syntax or
      # the use of the newer Ruby 1.9 syntax (when applicable).
      #
      # A separate offence is registered for each problematic pair.
      class HashSyntax < Cop
        MSG_19 = 'Use the new Ruby 1.9 hash syntax.'
        MSG_HASH_ROCKETS = 'Always use hash rockets in hashes.'

        def on_hash(node)
          case cop_config['EnforcedStyle']
          when 'ruby19' then ruby19_check(node)
          when 'hash_rockets' then hash_rockets_check(node)
          else fail 'Unknown HashSyntax style'
          end
        end

        def ruby19_check(node)
          pairs = *node

          sym_indices = pairs.all? { |p| word_symbol_pair?(p) }

          check(pairs, '=>', MSG_19) if sym_indices
        end

        def hash_rockets_check(node)
          pairs = *node

          check(pairs, ':', MSG_HASH_ROCKETS)
        end

        def autocorrect(node)
          key = node.children.first.loc.expression
          op = node.loc.operator
          if cop_config['EnforcedStyle'] == 'ruby19' &&
              !space_before_operator?(op, key) &&
              config.for_cop('SpaceAroundOperators')['Enabled']
            # Don't do the correction if there is no space before '=>'. The
            # combined corrections of this cop and SpaceAroundOperators could
            # produce code with illegal syntax.
            fail CorrectionNotPossible
          end

          @corrections << lambda do |corrector|
            if cop_config['EnforcedStyle'] == 'ruby19'
              corrector.insert_after(key, ' ')
              corrector.replace(key, key.source.sub(/^:(.*)/, '\1:'))
            else
              corrector.insert_after(key, ' => ')
              corrector.insert_before(key, ':')
            end
            corrector.remove(range_with_surrounding_space(op))
          end
        end

        private

        def space_before_operator?(op, key)
          op.begin_pos - key.begin_pos - key.source.length > 0
        end

        def check(pairs, delim, msg)
          pairs.each do |pair|
            if pair.loc.operator && pair.loc.operator.is?(delim)
              add_offence(pair,
                          pair.loc.expression.begin.join(pair.loc.operator),
                          msg)
            end
          end
        end

        def word_symbol_pair?(pair)
          key, _value = *pair

          if key.type == :sym
            sym_name = key.to_a[0]

            sym_name =~ /\A[A-Za-z_]\w*\z/
          else
            false
          end
        end
      end
    end
  end
end
