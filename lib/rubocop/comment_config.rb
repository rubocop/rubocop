# frozen_string_literal: true

module RuboCop
  # Responsible for parsing rubocop:<command> directives and providing information extracted from
  # those directives.
  #
  # Currently supported directives:
  #
  # * rubocop:disable <CopName>/rubocop:enable <CopName>, used via #cop_enabled_at_line?
  # * rubocop:set <CopName>{Settings}/rubocop:reset <CopName>, used via #cop_config_at_line
  #
  class CommentConfig
    REDUNDANT_DISABLE = 'Lint/RedundantCopDisableDirective'

    COP_NAME_PATTERN = '(?<cop>([A-Z]\w+/)?([A-Z]\w+))'
    COP_SETTING_PATTERN = '(?<settings>{[^}]+})'
    COP_PATTERN = "#{COP_NAME_PATTERN}#{COP_SETTING_PATTERN}?"
    COPS_LIST_PATTERN = "(#{COP_PATTERN} , )*#{COP_PATTERN}"
    COPS_PATTERN = "(?<cops>all|#{COPS_LIST_PATTERN})"

    COMMENT_DIRECTIVE_REGEXP = Regexp.new(
      ('\A # rubocop : (?<directive>[a-z]+)\b ' + COPS_PATTERN)
        .gsub(' ', '\s*')
    )

    # rubocop:set Metrics/MethodLength{Max: 20}, Metrics/BlockLength{Max: 40}

    Directive = Struct.new(:path, :comment, :directive, :cop, :single_line, :settings) do
      KNOWN_DIRECTIVES = %w[enable disable todo set reset].freeze

      def initialize(path, comment, directive, cop_string, single_line)
        cop, settings = cop_string.match(COP_PATTERN).values_at(:cop, :settings)
        unless KNOWN_DIRECTIVES.include?(directive)
          raise ArgumentError, "Unrecognized directive rubocop:#{directive}"
        end

        cop_name = Cop::Cop.qualified_cop_name(cop.strip, path)

        if directive == 'set'
          raise ArgumentError, 'rubocop:set requires arguments' unless settings

          super(path, comment, directive, cop_name, single_line, YAML.safe_load(settings))
        else
          raise ArgumentError, "Unexpected directive arguments: #{cop_string}" if settings

          super(path, comment, directive, cop_name, single_line)
        end
      end

      alias_method :single_line?, :single_line

      def disable?
        %w[disable todo].include?(directive)
      end

      def enable?
        directive == 'enable'
      end

      def disable_enable?
        disable? || enable?
      end

      def set?
        directive == 'set'
      end

      def reset?
        directive == 'reset'
      end

      def set_reset?
        set? || reset?
      end

      def all?
        comment.text.match(COMMENT_DIRECTIVE_REGEXP)[:cops] == 'all'
      end

      def line
        comment.loc.expression.line
      end
    end

    attr_reader :processed_source

    def initialize(processed_source)
      @processed_source = processed_source
    end

    def cop_enabled_at_line?(cop, line_number)
      cop = cop.cop_name if cop.respond_to?(:cop_name)
      disabled_line_ranges = cop_disabled_line_ranges[cop] or return true

      disabled_line_ranges.none? { |range| range.include?(line_number) }
    end

    def cop_config_at_line(cop, line_number)
      cop = cop.cop_name if cop.respond_to?(:cop_name)
      cop_configs = cop_configs_by_line_range[cop] or return

      cop_configs.reverse.find { |range,| range.cover?(line_number) }&.last
    end

    def cop_disabled_line_ranges
      @cop_disabled_line_ranges ||= analyze_disables
    end

    def cop_configs_by_line_range
      @cop_configs_by_line_range ||= analyze_configs
    end

    def extra_enabled_comments # rubocop:set Metrics/AbcSize{Max: 26}
      disabled = all_cop_names.to_h { |name| [name, false] }

      directives
        .select(&:disable_enable?).reject(&:single_line?)
        .chunk { |d| d.enable? && d.all? }
        .each_with_object([]) do |(enable_all, dirs), redundant|
          # if this group of directives is exploded from
          # `# rubocop:enable all` comment, it should be handled
          # as one statement
          if enable_all
            redundant << [dirs.first.comment, 'all'] if disabled.values.none?
            disabled.transform_values! { false }
          else
            dirs.each do |dir|
              redundant << [dir.comment, dir.cop] if dir.enable? && !disabled[dir.cop]
              disabled[dir.cop] = dir.disable?
            end
          end
        end
    end

    private

    def directives
      @directives ||= processed_source
                      .comments
                      .flat_map { |comment| extract_directives(comment) }
    end

    # produces hash {cop name => Array<Range>}
    def analyze_disables
      return {} if processed_source.comments.nil?

      directives
        .select(&:disable_enable?)
        .group_by(&:cop)
        .transform_values { |dirs| disabled_ranges(dirs) }
    end

    # produces hash {cop name => Array<(range, config hash)>}
    def analyze_configs
      return {} if processed_source.comments.nil?

      directives
        .select(&:set_reset?)
        .group_by(&:cop)
        .transform_values { |dirs| cop_settings(dirs) }
    end

    def extract_directives(comment) # rubocop:set Metrics/AbcSize{Max: 16}
      match = comment.text.match(COMMENT_DIRECTIVE_REGEXP) or return []

      directive, cops_string = match.values_at(:directive, :cops)

      cop_names =
        cops_string == 'all' ? all_cop_names : cops_string.split(/,\s*/)

      single_line = non_comment_token_line_numbers.include?(comment.loc.expression.line)
      path = processed_source.file_path

      cop_names.map { |name| Directive.new(path, comment, directive, name, single_line) }
    end

    # rubocop:set Metrics/AbcSize{Max: 26}, Metrics/CyclomaticComplexity{Max: 10}
    # rubocop:set Metrics/PerceivedComplexity{Max: 11}
    def disabled_ranges(directives)
      ranges = []
      disabled_at = nil

      directives.each do |directive|
        if directive.single_line? && directive.disable?
          ranges << (directive.line..directive.line)
        elsif directive.disable?
          disabled_at ||= directive.line
        elsif directive.enable? && disabled_at
          ranges << (disabled_at..directive.line)
          disabled_at = nil
        end
      end
      ranges << (disabled_at..Float::INFINITY) if disabled_at

      ranges
    end

    def cop_settings(directives)
      ranges = []
      current_config = nil
      started_at = nil

      directives.each do |directive|
        if directive.single_line? && directive.set?
          ranges << [started_at...directive.line, current_config] if started_at
          ranges << [directive.line..directive.line, directive.settings]
          # Restart it from the next line, if it was started
          started_at = directive.line + 1 if started_at
        elsif directive.set?
          ranges << [started_at...directive.line, current_config] if started_at
          started_at = directive.line
          current_config = directive.settings
        elsif directive.reset? && started_at
          ranges << [started_at..directive.line, current_config]
          started_at = nil
        end
      end
      ranges << [started_at..processed_source.lines.count, current_config] if started_at

      ranges
    end

    # rubocop:reset

    # Generic information

    def qualified_cop_name(cop_name)
      Cop::Cop.qualified_cop_name(cop_name.strip, processed_source.file_path)
    end

    def non_comment_token_line_numbers
      @non_comment_token_line_numbers ||=
        processed_source.tokens.reject(&:comment?).map(&:line).uniq
    end

    def all_cop_names
      @all_cop_names ||= Cop::Cop.registry.names - [REDUNDANT_DISABLE]
    end
  end
end
