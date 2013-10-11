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
          @corrections << lambda do |corrector|
            expr = node.loc.expression
            corrector.replace(expr, replacement(expr.source))
          end
        end

        private

        def check(pairs, delim, msg)
          pairs.each do |pair|
            if pair.loc.operator && pair.loc.operator.is?(delim)
              convention(pair,
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

        def replacement(source)
          if cop_config['EnforcedStyle'] == 'ruby19'
            source[1..-1].sub(/\s*=>\s*/, ': ')
          else
            ':' + source.sub(/:\s*/, ' => ')
          end
        end
      end
    end
  end
end
