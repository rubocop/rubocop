# encoding: utf-8

module Rubocop
  module Cop
    class AvoidPerlisms < Cop
      PREFERRED_VARS = {
        '$:' => '$LOAD_PATH',
        '$"' => '$LOADED_FEATURES',
        '$0' => '$PROGRAM_NAME',
        '$!' => '$ERROR_INFO from English library',
        '$@' => '$ERROR_POSITION from English library',
        '$;' => '$FS or $FIELD_SEPARATOR from English library',
        '$,' => '$OFS or $OUTPUT_FIELD_SEPARATOR from English library',
        '$/' => '$RS or $INPUT_RECORD_SEPARATOR from English library',
        '$\\' => '$ORS or $OUTPUT_RECORD_SEPARATOR from English library',
        '$.' => '$NR or $INPUT_LINE_NUMBER from English library',
        '$_' => '$LAST_READ_LINE from English library',
        '$>' => '$DEFAULT_OUTPUT from English library',
        '$<' => '$DEFAULT_INPUT from English library',
        '$$' => '$PID or $PROCESS_ID from English library',
        '$?' => '$CHILD_STATUS from English library',
        '$~' => '$LAST_MATCH_INFO from English library',
        '$=' => '$IGNORECASE from English library',
        '$*' => '$ARGV from English library or ARGV constant',
        '$&' => '$MATCH from English library',
        '$`' => '$PREMATCH from English library',
        '$\'' => '$POSTMATCH from English library',
        '$+' => '$LAST_PAREN_MATCH from English library'
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
