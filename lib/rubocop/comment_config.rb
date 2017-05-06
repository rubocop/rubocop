# frozen_string_literal: true

module RuboCop
  # This class parses the special `rubocop:disable` comments in a source
  # and provides a way to check if each cop is enabled at arbitrary line.
  class CommentConfig
    attr_reader :processed_source

    def initialize(processed_source)
      @processed_source = processed_source
    end

    def cop_enabled_at_line?(cop, line_number)
      cop = cop.cop_name if cop.respond_to?(:cop_name)
      disabled_line_ranges = cop_disabled_line_ranges[cop]
      return true unless disabled_line_ranges

      disabled_line_ranges.none? { |range| range.include?(line_number) }
    end

    def cop_disabled_line_ranges
      @cop_disabled_line_ranges ||= analyze
    end

    private

    CopAnalysis = Struct.new(:disabled_ranges, :unclosed_directive)

    def analyze
      analyses = Hash.new { |hash, key| hash[key] = CopAnalysis.new([], nil) }

      each_directive do |directive|
        directive.cop_names.each do |cop_name|
          analyze_cop(analyses[cop_name], directive)
        end
      end

      analyses.each_with_object({}) do |element, hash|
        cop_name, analysis = *element
        hash[cop_name] = cop_line_ranges(analysis)
      end
    end

    def analyze_cop(analysis, directive)
      if single_line_directive?(directive)
        analyze_single_line(analysis, directive)
      elsif directive.disable?
        open_directive!(analysis, directive)
      else
        close_unclosed_directive!(analysis, directive)
      end
    end

    def analyze_single_line(analysis, directive)
      return unless directive.disable?
      analysis.disabled_ranges << CommentConfigRange.new(directive, directive)
    end

    def open_directive!(analysis, directive)
      # If a directive is already open on this line (i.e. a cop is already
      # disabled), then close it before we start a new range.
      # Lint::UnneededDisable#each_already_disabled relies on this behavior.
      close_unclosed_directive!(analysis, directive)

      analysis.unclosed_directive = directive
    end

    def close_unclosed_directive!(analysis, end_directive)
      return unless analysis.unclosed_directive

      range = CommentConfigRange.new(analysis.unclosed_directive, end_directive)
      analysis.disabled_ranges << range
      analysis.unclosed_directive = nil
    end

    def cop_line_ranges(analysis)
      close_unclosed_directive!(analysis, nil)
      analysis.disabled_ranges
    end

    def each_directive
      return if processed_source.comments.nil?

      processed_source.comments.each do |comment|
        directive = CommentDirective.from_comment(comment)
        yield directive if directive
      end
    end

    def single_line_directive?(directive)
      non_comment_token_line_numbers.include?(directive.line)
    end

    def non_comment_token_line_numbers
      @non_comment_token_line_numbers ||= begin
        non_comment_tokens = processed_source.tokens.reject do |token|
          token.type == :tCOMMENT
        end

        non_comment_tokens.map { |token| token.pos.line }.uniq
      end
    end
  end
end
