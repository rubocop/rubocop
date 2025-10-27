# frozen_string_literal: true

module RuboCop
  # This class wraps the `Parser::Source::Comment` object that represents a
  # special `rubocop:disable` and `rubocop:enable` comment and exposes what
  # cops it contains.
  class DirectiveComment
    # @api private
    LINT_DEPARTMENT = 'Lint'
    # @api private
    LINT_REDUNDANT_DIRECTIVE_COP = "#{LINT_DEPARTMENT}/RedundantCopDisableDirective"
    # @api private
    LINT_SYNTAX_COP = "#{LINT_DEPARTMENT}/Syntax"
    # @api private
    COP_NAME_PATTERN = '([A-Za-z]\w+/)*(?:[A-Za-z]\w+)'
    # @api private
    COP_NAMES_PATTERN = "(?:#{COP_NAME_PATTERN} , )*#{COP_NAME_PATTERN}"
    # @api private
    COPS_PATTERN = "(all|#{COP_NAMES_PATTERN})"
    # @api private
    AVAILABLE_MODES = %w[disable enable todo push pop].freeze
    # @api private
    DIRECTIVE_MARKER_PATTERN = '# rubocop : '
    # @api private
    DIRECTIVE_MARKER_REGEXP = Regexp.new(DIRECTIVE_MARKER_PATTERN.gsub(' ', '\s*'))
    # @api private
    DIRECTIVE_HEADER_PATTERN = "#{DIRECTIVE_MARKER_PATTERN}((?:#{AVAILABLE_MODES.join('|')}))\\b"
    # @api private
    # Pattern for push with optional sub-mode and cops: "Cop1, Cop2"
    PUSH_DIRECTIVE_PATTERN = "#{DIRECTIVE_MARKER_PATTERN}(push)(?:\\s+(disable|enable)\\s+#{COPS_PATTERN})?" # rubocop:disable Layout/LineLength
    # @api private
    # Pattern for pop (no cops allowed): "# rubocop:pop"
    POP_DIRECTIVE_PATTERN = "#{DIRECTIVE_MARKER_PATTERN}(pop)\\s*(?:--.*)?\\s*$"
    # @api private
    DIRECTIVE_COMMENT_REGEXP = Regexp.new(
      "#{DIRECTIVE_HEADER_PATTERN} #{COPS_PATTERN}"
        .gsub(' ', '\s*')
    )
    # @api private
    PUSH_DIRECTIVE_REGEXP = Regexp.new(PUSH_DIRECTIVE_PATTERN.gsub(' ', '\s*'))
    # @api private
    POP_DIRECTIVE_REGEXP = Regexp.new(POP_DIRECTIVE_PATTERN.gsub(' ', '\s*'))
    # @api private
    TRAILING_COMMENT_MARKER = '--'
    # @api private
    MALFORMED_DIRECTIVE_WITHOUT_COP_NAME_REGEXP = Regexp.new(
      "\\A#{DIRECTIVE_HEADER_PATTERN}\\s*\\z".gsub(' ', '\s*')
    )

    def self.before_comment(line)
      line.split(DIRECTIVE_COMMENT_REGEXP).first
    end

    attr_reader :comment, :cop_registry, :mode, :cops, :sub_mode

    def initialize(comment, cop_registry = Cop::Registry.global) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @comment = comment
      @cop_registry = cop_registry
      @match_data = comment.text.match(POP_DIRECTIVE_REGEXP) ||
                    comment.text.match(PUSH_DIRECTIVE_REGEXP) ||
                    comment.text.match(DIRECTIVE_COMMENT_REGEXP)

      if comment.text.match(POP_DIRECTIVE_REGEXP)
        @mode = 'pop'
        @cops = @sub_mode = nil
      elsif comment.text.match(PUSH_DIRECTIVE_REGEXP)
        @mode = 'push'
        @sub_mode, @cops = @match_data.captures[1, 2]
      else
        @mode, @cops = match_captures
        @sub_mode = nil
      end
    end

    # Checks if the comment starts with `# rubocop:` marker
    def start_with_marker?
      comment.text.start_with?(DIRECTIVE_MARKER_REGEXP)
    end

    # Checks if the comment is malformed as a `# rubocop:` directive
    def malformed?
      return true if !start_with_marker? || @match_data.nil?

      tail = @match_data.post_match.lstrip
      !(tail.empty? || tail.start_with?(TRAILING_COMMENT_MARKER))
    end

    # Checks if the directive comment is missing a cop name
    def missing_cop_name?
      MALFORMED_DIRECTIVE_WITHOUT_COP_NAME_REGEXP.match?(comment.text)
    end

    # Checks if this directive relates to single line
    def single_line?
      !comment.text.start_with?(DIRECTIVE_COMMENT_REGEXP)
    end

    # Checks if this directive contains all the given cop names
    def match?(cop_names)
      parsed_cop_names.uniq.sort == cop_names.uniq.sort
    end

    def range
      match = comment.text.match(DIRECTIVE_COMMENT_REGEXP)
      begin_pos = comment.source_range.begin_pos
      Parser::Source::Range.new(
        comment.source_range.source_buffer, begin_pos + match.begin(0), begin_pos + match.end(0)
      )
    end

    # Returns match captures to directive comment pattern
    def match_captures
      @match_captures ||= @match_data&.captures
    end

    # Checks if this directive is a push directive
    def push?
      mode == 'push'
    end

    # Checks if this directive is a pop directive
    def pop?
      mode == 'pop'
    end

    # Checks if this directive disables cops
    def disabled?
      return sub_mode == 'disable' if push?

      %w[disable todo].include?(mode)
    end

    # Checks if this directive enables cops
    def enabled?
      return sub_mode == 'enable' if push?

      mode == 'enable'
    end

    # Checks if this directive enables all cops
    def enabled_all?
      !disabled? && all_cops?
    end

    # Checks if this directive disables all cops
    def disabled_all?
      disabled? && all_cops?
    end

    # Checks if all cops specified in this directive
    def all_cops?
      cops == 'all'
    end

    # Returns array of specified in this directive cop names
    def cop_names
      return [] if pop?

      @cop_names ||= all_cops? ? all_cop_names : parsed_cop_names
    end

    # Returns an array of cops for this directive comment, without resolving departments
    def raw_cop_names
      @raw_cop_names ||= (cops || '').split(/,\s*/)
    end

    # Returns array of specified in this directive department names
    # when all department disabled
    def department_names
      raw_cop_names.select { |cop| department?(cop) }
    end

    # Checks if directive departments include cop
    def in_directive_department?(cop)
      department_names.any? { |department| cop.start_with?(department) }
    end

    # Checks if cop department has already used in directive comment
    def overridden_by_department?(cop)
      in_directive_department?(cop) && raw_cop_names.include?(cop)
    end

    def directive_count
      raw_cop_names.count
    end

    # Returns line number for directive
    def line_number
      comment.source_range.line
    end

    private

    def parsed_cop_names
      cops = raw_cop_names.map do |name|
        department?(name) ? cop_names_for_department(name) : name
      end.flatten
      cops - [LINT_SYNTAX_COP]
    end

    def department?(name)
      cop_registry.department?(name)
    end

    def all_cop_names
      exclude_lint_department_cops(cop_registry.names)
    end

    def cop_names_for_department(department)
      names = cop_registry.names_for_department(department)
      department == LINT_DEPARTMENT ? exclude_lint_department_cops(names) : names
    end

    def exclude_lint_department_cops(cops)
      cops - [LINT_REDUNDANT_DIRECTIVE_COP, LINT_SYNTAX_COP]
    end
  end
end
