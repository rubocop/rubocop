# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of Perl-style global variables.
      class SpecialGlobalVars < Cop
        MSG_BOTH = 'Prefer %s from the English library, or %s over %s.'
        MSG_ENGLISH = 'Prefer %s from the English library over %s.'
        MSG_REGULAR = 'Prefer %s over %s.'

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

        # Anything *not* in this set is provided by the English library.
        NON_ENGLISH_VARS = Set.new([
          '$LOAD_PATH',
          '$LOADED_FEATURES',
          '$PROGRAM_NAME',
          'ARGV'
        ])

        def on_gvar(node)
          global_var, = *node

          add_offence(node, :expression) if PREFERRED_VARS[global_var]
        end

        def message(node)
          global_var, = *node

          regular, english = PREFERRED_VARS[global_var].partition do |var|
            NON_ENGLISH_VARS.include? var
          end

          # For now, we assume that lists are 2 items or less.  Easy grammar!
          regular_msg = regular.join(' or ')
          english_msg = english.join(' or ')

          if regular.length > 0 && english.length > 0
            MSG_BOTH.format(english_msg, regular_msg, global_var)
          elsif regular.length > 0
            MSG_REGULAR.format(regular_msg, global_var)
          elsif english.length > 0
            MSG_ENGLISH.format(english_msg, global_var)
          else
            fail 'Bug in SpecialGlobalVars - global var w/o preferred vars!'
          end
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
