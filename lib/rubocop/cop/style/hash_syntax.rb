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

          if sym_indices
            pairs.each do |pair|
              if pair.loc.operator && pair.loc.operator.is?('=>')
                convention(pair,
                           pair.loc.expression.begin.join(pair.loc.operator),
                           MSG_19)
              end
            end
          end
        end

        def hash_rockets_check(node)
          pairs = *node

          pairs.each do |pair|
            if pair.loc.operator && pair.loc.operator.is?(':')
              convention(pair,
                         pair.loc.expression.begin.join(pair.loc.operator),
                         MSG_HASH_ROCKETS)
            end
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            if cop_config['EnforcedStyle'] == 'ruby19'
              replacement = node.loc.expression.source[1..-1]
                .sub(/\s*=>\s*/, ': ')
            else
              replacement = ':' + node.loc.expression.source
                .sub(/:\s*/, ' => ')
            end
            corrector.replace(node.loc.expression, replacement)
          end
        end

        private

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
