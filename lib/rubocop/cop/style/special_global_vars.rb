# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of Perl-style global variables.
      class SpecialGlobalVars < Cop
        include ConfigurableEnforcedStyle

        MSG_BOTH = 'Prefer `%s` from the stdlib \'English\' module, ' \
        'or `%s` over `%s`.'.freeze
        MSG_ENGLISH = 'Prefer `%s` from the stdlib \'English\' module ' \
        'over `%s`.'.freeze
        MSG_REGULAR = 'Prefer `%s` over `%s`.'.freeze

        ENGLISH_VARS = { # rubocop:disable Style/MutableConstant
          :$: => [:$LOAD_PATH],
          :$" => [:$LOADED_FEATURES],
          :$0 => [:$PROGRAM_NAME],
          :$! => [:$ERROR_INFO],
          :$@ => [:$ERROR_POSITION],
          :$; => [:$FIELD_SEPARATOR, :$FS],
          :$, => [:$OUTPUT_FIELD_SEPARATOR, :$OFS],
          :$/ => [:$INPUT_RECORD_SEPARATOR, :$RS],
          :$\ => [:$OUTPUT_RECORD_SEPARATOR, :$ORS],
          :$. => [:$INPUT_LINE_NUMBER, :$NR],
          :$_ => [:$LAST_READ_LINE],
          :$> => [:$DEFAULT_OUTPUT],
          :$< => [:$DEFAULT_INPUT],
          :$$ => [:$PROCESS_ID, :$PID],
          :$? => [:$CHILD_STATUS],
          :$~ => [:$LAST_MATCH_INFO],
          :$= => [:$IGNORECASE],
          :$* => [:$ARGV, :ARGV],
          :$& => [:$MATCH],
          :$` => [:$PREMATCH],
          :$' => [:$POSTMATCH],
          :$+ => [:$LAST_PAREN_MATCH]
        }

        PERL_VARS =
          Hash[ENGLISH_VARS.flat_map { |k, vs| vs.map { |v| [v, [k]] } }]

        ENGLISH_VARS.merge!(
          Hash[ENGLISH_VARS.flat_map { |_, vs| vs.map { |v| [v, [v]] } }]
        )
        PERL_VARS.merge!(
          Hash[PERL_VARS.flat_map { |_, vs| vs.map { |v| [v, [v]] } }]
        )
        ENGLISH_VARS.each { |_, v| v.freeze }.freeze
        PERL_VARS.each { |_, v| v.freeze }.freeze

        # Anything *not* in this set is provided by the English library.
        NON_ENGLISH_VARS = Set.new([
                                     :$LOAD_PATH,
                                     :$LOADED_FEATURES,
                                     :$PROGRAM_NAME,
                                     :ARGV
                                   ]).freeze

        def on_gvar(node)
          global_var, = *node

          return unless (preferred = preferred_names(global_var))

          if preferred.include?(global_var)
            correct_style_detected
          else
            opposite_style_detected
            add_offense(node, :expression)
          end
        end

        def message(node)
          global_var, = *node

          if style == :use_english_names
            format_english_message(global_var)
          else
            format(MSG_REGULAR, preferred_names(global_var).first, global_var)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            global_var, = *node

            while node.parent && node.parent.begin_type? &&
                  node.parent.children.one?
              node = node.parent
            end

            corrector.replace(node.source_range, replacement(node, global_var))
          end
        end

        private

        def format_english_message(global_var)
          regular, english = ENGLISH_VARS[global_var].partition do |var|
            NON_ENGLISH_VARS.include? var
          end

          format_message(english, regular, global_var)
        end

        def format_message(english, regular, global_var)
          if !regular.empty? && !english.empty?
            format(MSG_BOTH, format_list(english), format_list(regular),
                   global_var)
          elsif !regular.empty?
            format(MSG_REGULAR, format_list(regular), global_var)
          elsif !english.empty?
            format(MSG_ENGLISH, format_list(english), global_var)
          else
            raise 'Bug in SpecialGlobalVars - global var w/o preferred vars!'
          end
        end

        # For now, we assume that lists are 2 items or less. Easy grammar!
        def format_list(items)
          items.join('` or `')
        end

        def replacement(node, global_var)
          parent_type = node.parent && node.parent.type
          preferred_name = preferred_names(global_var).first

          unless [:dstr, :xstr, :regexp].include?(parent_type)
            return preferred_name.to_s
          end

          if style == :use_english_names
            return english_name_replacement(preferred_name, node)
          end

          "##{preferred_name}"
        end

        def preferred_names(global)
          if style == :use_english_names
            ENGLISH_VARS[global]
          else
            PERL_VARS[global]
          end
        end

        def english_name_replacement(preferred_name, node)
          return "\#{#{preferred_name}}" if node.begin_type?

          "{#{preferred_name}}"
        end
      end
    end
  end
end
