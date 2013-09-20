# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of Perl-style global variables.
      class SpecialGlobalVars < Cop
        MSG = 'Prefer %s over %s.'

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
        }.symbolize_keys

        def on_gvar(node)
          global_var, = *node

          convention(node, :expression) if PREFERRED_VARS[global_var]
        end

        def message(node)
          global_var, = *node
          MSG.format(PREFERRED_VARS[global_var], global_var)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            global_var, = *node

            corrector.replace(node.loc.expression,
                              PREFERRED_VARS[global_var])
          end
        end
      end
    end
  end
end
