# frozen_string_literal: true

module RuboCop
  # This class parses the special `rubocop:disable` comments in a source
  # and provides a way to check if each cop is enabled at arbitrary line.
  class CommentConfig
    extend SimpleForwardable
    include DisableNext

    CONFIG_DISABLED_LINE_RANGE_MIN = -Float::INFINITY

    # This class provides an API compatible with RuboCop::DirectiveComment
    # to be used for cops that are disabled in the config file
    class ConfigDisabledCopDirectiveComment
      include RuboCop::Ext::Comment

      attr_reader :text, :loc, :line_number

      Loc = Struct.new(:expression)
      Expression = Struct.new(:line)

      def initialize(cop_name)
        @text = "# rubocop:disable #{cop_name}"
        @line_number = CONFIG_DISABLED_LINE_RANGE_MIN
        @loc = Loc.new(Expression.new(CONFIG_DISABLED_LINE_RANGE_MIN))
      end
    end

    attr_reader :processed_source

    def_delegators :@processed_source, :config, :registry

    def initialize(processed_source)
      @processed_source = processed_source
      @no_directives = !processed_source.raw_source.include?('rubocop')
      @stack = []
      @detached_next_directives = []
    end

    def cop_enabled_at_line?(cop, line_number)
      cop_enabled_at_lines?(cop, line_number, line_number)
    end

    # Whether the cop is enabled for all of the given line span. The cop
    # counts as disabled for the span when any of its disabled ranges
    # overlaps it, so that a directive on any line of a multi-line offense
    # suppresses the offense.
    def cop_enabled_at_lines?(cop, first_line, last_line)
      cop = cop.cop_name if cop.respond_to?(:cop_name)
      disabled_line_ranges = cop_disabled_line_ranges[cop]
      return true unless disabled_line_ranges

      disabled_line_ranges.none? do |range|
        range.end >= first_line && range.begin <= last_line
      end
    end

    def cop_opted_in?(cop)
      opt_in_cops.include?(cop.cop_name)
    end

    def cop_disabled_line_ranges
      @cop_disabled_line_ranges ||= analyze
    end

    def extra_enabled_comments
      disable_count = Hash.new(0)
      registry.disabled_names(config).each do |cop_name|
        disable_count[cop_name] += 1
      end
      extra_enabled_comments_with_names(extras: Hash.new { |h, k| h[k] = [] }, names: disable_count)
    end

    def comment_only_line?(line_number)
      non_comment_token_line_numbers.none?(line_number)
    end

    # The names of the cops that are opted in by an `enable` comment directive,
    # used to mobilize cops disabled in the config on demand.
    #
    # @api private
    # @return [Set<String>]
    def opt_in_cops
      @opt_in_cops ||= begin
        cops = Set.new
        each_directive do |directive|
          next unless directive.enabled?
          next if directive.all_cops?

          cops.merge(directive.raw_cop_names)
        end
        cops
      end
    end

    private

    def extra_enabled_comments_with_names(extras:, names:)
      each_directive do |directive|
        next unless comment_only_line?(directive.line_number)
        # Push/pop and next-statement directives close themselves, so they
        # play no part in the disable/enable pairing.
        next if directive.push? || directive.pop? || directive.disable_next?

        if directive.enabled_all?
          handle_enable_all(directive, names, extras)
        else
          handle_switch(directive, names, extras)
        end
      end

      extras
    end

    # rubocop:disable-next Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def analyze
      return {} if @no_directives

      analyses = Hash.new { |hash, key| hash[key] = CopAnalysis.new([], nil) }
      inject_disabled_cops_directives(analyses)

      each_directive do |directive|
        if directive.push?
          restore_point = analyses.transform_values(&:dup)
          @stack.push(restore_point)
          apply_push(analyses, resolve_push_cops(directive), directive)
        elsif directive.pop?
          pop_state(analyses, directive.line_number) if @stack.any?
        elsif directive.disable_next?
          apply_disable_next(analyses, directive)
        else
          directive.cop_names.each do |cop_name|
            cop_name = qualified_cop_name(cop_name)
            analyses[cop_name] = analyze_cop(analyses[cop_name], directive)
          end
        end
      end

      analyses.each_with_object({}) do |element, hash|
        cop_name, analysis = *element
        next if prevent_directive_disabling?(cop_name)

        hash[cop_name] = cop_line_ranges(analysis)
      end
    end

    def resolve_push_cops(directive)
      directive.push_args.transform_values do |names|
        names.flat_map { |name| expand_cop_name(name) }
      end
    end

    def expand_cop_name(name)
      registry = Cop::Registry.global
      cops = registry.department?(name) ? registry.names_for_department(name) : [name]
      cops.map { |c| qualified_cop_name(c) }
    end

    def apply_push(analyses, resolved_cops, directive)
      resolved_cops.each do |op, cops|
        cops.each { |cop| apply_cop_op(analyses, op, cop, directive) }
      end
    end

    def apply_cop_op(analyses, operation, cop, directive)
      analysis = analyses[cop]
      line = directive.line_number
      if operation == '-' && !analysis.start_line_number
        analyses[cop] = CopAnalysis.new(analysis.line_ranges, line, directive)
      elsif operation == '+' && analysis.start_line_number
        analyses[cop] = CopAnalysis.new(analysis.close(line), nil)
      end
    end

    def pop_state(analyses, line)
      restore_point = @stack.pop
      (restore_point.keys | analyses.keys).each do |cop|
        analyses[cop] = popped_analysis(analyses[cop], restore_point[cop], line)
      end
    end

    def popped_analysis(current, restored, line)
      ranges = current.close(line - 1)
      return CopAnalysis.new(ranges, nil) unless restored&.start_line_number

      CopAnalysis.new(ranges, line, restored.start_directive)
    end

    def inject_disabled_cops_directives(analyses)
      registry.disabled_names(config).each do |cop_name|
        analyses[cop_name] = analyze_cop(
          analyses[cop_name],
          DirectiveComment.new(ConfigDisabledCopDirectiveComment.new(cop_name))
        )
      end
    end

    def analyze_cop(analysis, directive)
      # Disabling cops after comments like `#=SomeDslDirective` does not related to single line
      if !comment_only_line?(directive.line_number) || directive.single_line?
        analyze_single_line(analysis, directive)
      elsif directive.disabled?
        analyze_disabled(analysis, directive)
      else
        analyze_rest(analysis, directive)
      end
    end

    def analyze_single_line(analysis, directive)
      return analysis unless directive.disabled?

      line = directive.line_number
      range = DirectiveRange.new(line, line, directive)
      CopAnalysis.new(analysis.line_ranges + [range], analysis.start_line_number,
                      analysis.start_directive)
    end

    def analyze_disabled(analysis, directive)
      CopAnalysis.new(analysis.close(directive.line_number), directive.line_number, directive)
    end

    def analyze_rest(analysis, directive)
      CopAnalysis.new(analysis.close(directive.line_number), nil)
    end

    def cop_line_ranges(analysis)
      analysis.close(Float::INFINITY)
    end

    def each_directive
      return if @no_directives

      processed_source.comments.each do |comment|
        directive = DirectiveComment.new(comment)
        yield directive if directive.cop_names
      end
    end

    def qualified_cop_name(cop_name)
      # A directive naming a cop under the wrong department is not honored -
      # the mistake is surfaced by `Lint/RedundantCopDisableDirective` (with a
      # did-you-mean hint) instead of a stderr warning that is easy to miss
      # and disappears entirely on cached runs.
      Cop::Registry.qualified_cop_name(cop_name.strip, processed_source.file_path,
                                       correct_namespace: false)
    end

    # `Style/DisableCopsWithinSourceCodeDirective` cannot be disabled via
    # directive comments when it is explicitly enabled with `Enabled: true`.
    # This prevents users from bypassing the cop by writing a disable
    # directive that targets this cop itself.
    def prevent_directive_disabling?(cop_name)
      cop_name == DirectiveComment::STYLE_DISABLE_COPS_DIRECTIVE_COP &&
        config.dig(cop_name, 'Enabled') == true
    end

    def non_comment_token_line_numbers
      @non_comment_token_line_numbers ||= begin
        non_comment_tokens = processed_source.tokens.reject(&:comment?)
        non_comment_tokens.map(&:line).uniq
      end
    end

    def handle_enable_all(directive, names, extras)
      enabled_cops = 0
      names.each do |name, counter|
        next unless counter.positive?

        names[name] -= 1
        enabled_cops += 1
      end

      extras[directive.comment] << 'all' if enabled_cops.zero?
    end

    # Collect cops that have been disabled or enabled by name in a directive comment
    # so that `Lint/RedundantCopEnableDirective` can register offenses correctly.
    def handle_switch(directive, names, extras)
      directive.cop_names.each do |name|
        if directive.disabled?
          names[name] += 1
        elsif names[name].positive?
          names[name] -= 1
        else
          extras[directive.comment] << name
        end
      end
    end
  end
end
