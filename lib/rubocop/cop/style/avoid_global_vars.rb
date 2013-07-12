# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops looks for uses of global variables.
      # It does not report offences for built-in global variables.
      class AvoidGlobalVars < Cop
        MSG = 'Do not introduce global variables.'

        # predefined global variables their English aliases
        # http://www.zenspider.com/Languages/Ruby/QuickRef.html
        BUILT_IN_VARS = %w(
          $: $LOAD_PATH
          $" $LOADED_FEATURES
          $0 $PROGRAM_NAME
          $! $ERROR_INFO
          $@ $ERROR_POSITION
          $; $FS $FIELD_SEPARATOR
          $, $OFS $OUTPUT_FIELD_SEPARATOR
          $/ $RS $INPUT_RECORD_SEPARATOR
          $\\ $ORS $OUTPUT_RECORD_SEPARATOR
          $. $NR $INPUT_LINE_NUMBER
          $_ $LAST_READ_LINE
          $> $DEFAULT_OUTPUT
          $< $DEFAULT_INPUT
          $$ $PID $PROCESS_ID
          $? $CHILD_STATUS
          $~ $LAST_MATCH_INFO
          $= $IGNORECASE
          $* $ARGV
          $& $MATCH
          $` $PREMATCH
          $' $POSTMATCH
          $+ $LAST_PAREN_MATCH
          $stdin $stdout $stderr
          $DEBUG $FILENAME $VERBOSE $SAFE
          $-0 $-a $-d $-F $-i $-I $-l $-p $-v $-w
        ).map(&:to_sym)

        def on_gvar(node)
          check(node)
        end

        def on_gvasgn(node)
          check(node)
        end

        def check(node)
          global_var, = *node

          unless BUILT_IN_VARS.include?(global_var)
            add_offence(:convention,
                        node.loc.name,
                        MSG)
          end
        end
      end
    end
  end
end
