module Rubocop
  module Cop
    class SpaceAfterCommaEtc < Cop
      ERROR_MESSAGE = 'Space missing after %s.'

      def inspect(file, source, tokens, sexp)
        tokens.each_index { |ix|
          pos, name, text = tokens[ix]
          kind = if    name == :on_comma                then 'comma'
                 elsif name == :on_label || text == ':' then 'colon'
                 elsif name == :on_semicolon            then 'semicolon'
                 end
          if kind and not [:on_sp, :on_ignored_nl].include?(tokens[ix+1][1])
            index = pos[0] - 1
            add_offence(:convention, index, source[index],
                        ERROR_MESSAGE % kind)
          end
        }
      end
    end
  end
end
