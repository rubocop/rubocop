# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter formats report data in clang style.
    # The precise location of the problem is shown together with the
    # relevant source code.
    class ClangStyleFormatter < SimpleTextFormatter
      def report_file(file, offences)
        offences.each do |o|
          output.printf("%s:%d:%d: %s: %s\n",
                        smart_path(file).color(:cyan), o.line, o.real_column,
                        colored_severity_code(o), message(o))

          location = o.location
          source_line = location.source_line

          # FIXME: Per the discussion below, we should not have to guard
          # against Parser::Source::Range#column_range raising an error
          # on multiline source ranges here -- followup needed.
          # https://github.com/bbatsov/rubocop/pull/549#issuecomment-25955658
          if !source_line.blank? && location.begin.line == location.end.line
            output.puts(source_line)
            output.puts(' ' * o.location.column +
                        '^' * o.location.column_range.count)
          end
        end
      end
    end
  end
end
