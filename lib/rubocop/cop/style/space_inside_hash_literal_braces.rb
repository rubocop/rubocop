# encoding: utf-8

# rubocop:disable SymbolName

module Rubocop
  module Cop
    module Style
      # Checks that braces used for hash literals have or don't have
      # surrounding space depending on configuration.
      class SpaceInsideHashLiteralBraces < Cop
        include SurroundingSpace
        MSG = 'Space inside hash literal braces %s.'

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source
          tokens = processed_source.tokens

          on_node(:hash, processed_source.ast) do |hash|
            b_ix = index_of_first_token(hash)
            e_ix = index_of_last_token(hash)
            if tokens[b_ix].type == :tLBRACE # Hash literal with braces?
              check(tokens[b_ix], tokens[b_ix + 1])
              check(tokens[e_ix - 1], tokens[e_ix])
            end
          end
        end

        def check(t1, t2)
          types = [t1, t2].map(&:type)
          braces = [:tLBRACE, :tRCURLY]
          return if types == braces || (braces - types).size == 2
          # No offence if line break inside.
          return if t1.pos.line < t2.pos.line
          has_space = space_between?(t1, t2)
          is_offence, word = if cop_config['EnforcedStyleIsWithSpaces']
                               [!has_space, 'missing']
                             else
                               [has_space, 'detected']
                             end
          brace_token = t1.text == '{' ? t1 : t2
          convention(nil, brace_token.pos, sprintf(MSG, word)) if is_offence
        end
      end
    end
  end
end
