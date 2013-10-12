# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of Perl-style global variables.
      class SpecialGlobalVars < Cop
        MSG = 'Prefer %s from English library over %s.'

        PREFERRED_VARS = {
          '$:' => ['$LOAD_PATH'],
          '$"' => ['$LOADED_FEATURES'],
          '$0' => ['$PROGRAM_NAME'],
          '$!' => ['$ERROR_INFO'],
          '$@' => ['$ERROR_POSITION'],
          '$;' => ['$FIELD_SEPARATOR', '$FS'],
          '$,' => ['$OUTPUT_FIELD_SEPARATOR', '$OFS'],
          '$/' => ['$INPUT_RECORD_SEPARATOR', '$RS'],
          '$\\' => ['$OUTPUT_RECORD_SEPARATOR', '$ORS'],
          '$.' => ['$INPUT_LINE_NUMBER', '$NR'],
          '$_' => ['$LAST_READ_LINE'],
          '$>' => ['$DEFAULT_OUTPUT'],
          '$<' => ['$DEFAULT_INPUT'],
          '$$' => ['$PROCESS_ID', '$PID'],
          '$?' => ['$CHILD_STATUS'],
          '$~' => ['$LAST_MATCH_INFO'],
          '$=' => ['$IGNORECASE'],
          '$*' => ['$ARGV', 'ARGV'],
          '$&' => ['$MATCH'],
          '$`' => ['$PREMATCH'],
          '$\'' => ['$POSTMATCH'],
          '$+' => ['$LAST_PAREN_MATCH']
        }.symbolize_keys

        def on_gvar(node)
          global_var, = *node

          convention(node, :expression) if PREFERRED_VARS[global_var]
        end

        def message(node)
          global_var, = *node
          MSG.format(PREFERRED_VARS[global_var].join(' or '), global_var)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            global_var, = *node

            corrector.replace(node.loc.expression,
                              PREFERRED_VARS[global_var].first)
          end
        end
      end
    end
  end
end
