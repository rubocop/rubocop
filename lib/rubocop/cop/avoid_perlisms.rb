module Rubocop
  module Cop
    class AvoidPerlisms < Cop
      PREFERRED_VARS = {
        '$:' => '$LOAD_PATH',
        '$"' => '$LOADED_FEATURES',
        '$0' => '$PROGRAM_NAME',
        '$1' => 'MatchData',
        '$2' => 'MatchData',
        '$3' => 'MatchData',
        '$4' => 'MatchData',
        '$5' => 'MatchData',
        '$6' => 'MatchData',
        '$7' => 'MatchData',
        '$8' => 'MatchData',
        '$9' => 'MatchData',
        '$!' => '$ERROR_INFO',
        '$@' => '$ERROR_POSITION',
        '$;' => '$FIELD_SEPARATOR',
        '$,' => '$OUTPUT_FIELD_SEPARATOR',
        '$/' => '$INPUT_RECORD_SEPARATOR',
        '$\\' => 'OUTPUT_RECORD_SEPARATOR',
        '$.' => '$INPUT_LINE_NUMBER',
        '$_' => '$LAST_READ_LINE',
        '$>' => '$DEFAULT_OUTPUT',
        '$<' => '$DEFAULT_INPUT',
        '$$' => '$PROCESS_ID',
        '$?' => '$CHILD_STATUS',
        '$~' => '$LAST_MATCH_INFO',
        '$=' => '$IGNORECASE',
        '$*' => '$ARGV',
        '$&' => '$MATCH',
        '$`' => '$PREMATCH',
        '$\'' => 'POSTMATCH',
        '$+' => '$LAST_PAREN_MATCH'
      }

      def inspect(file, source, tokens, sexp)
        each(:@gvar, sexp) do |s|
          global_var = s[1]

          if PREFERRED_VARS[global_var]
            add_offence(
              :convention,
              s[2].lineno,
              "Prefer #{PREFERRED_VARS[global_var]} over #{global_var}."
            )
          end
        end
      end
    end
  end
end
