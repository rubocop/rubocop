# encoding: utf-8

module RuboCop
  # This class parses the special `rubocop:disable` comments in a source
  # and provides a way to check if each cop is enabled at arbitrary line.
  class CommentConfig
    UNNEEDED_DISABLE = 'Lint/UnneededDisable'.freeze
    COMMENT_DIRECTIVE_REGEXP = Regexp.new(
      '\A# rubocop : ((?:dis|en)able)\b ((?:[\w/]+,? )+)'.gsub(' ', '\s*')
    )

    attr_reader :processed_source

    def initialize(processed_source)
      @processed_source = processed_source
    end

    def cop_enabled_at_line?(cop, line_number)
      cop = cop.cop_name if cop.respond_to?(:cop_name)
      disabled_line_ranges = cop_disabled_line_ranges[cop]
      disabled_line_ranges.none? { |range| range.include?(line_number) }
    end

    def cop_disabled_line_ranges
      @cop_disabled_line_ranges ||= analyze
    end

    private

    def analyze
      disabled_line_ranges = Hash.new { |hash, key| hash[key] = [] }
      disablement_start_line_numbers = {}

      each_mentioned_cop do |cop_name, disabled, line, single_line|
        if single_line
          disabled_line_ranges[cop_name] << (line..line) if disabled
        elsif disabled
          if disablement_start_line_numbers[cop_name]
            # Cop already disabled on this line, so we end the current disabled
            # range before we start a new range.
            start_line = disablement_start_line_numbers.delete(cop_name)
            disabled_line_ranges[cop_name] << (start_line..line)
          end
          disablement_start_line_numbers[cop_name] = line
        else
          start_line = disablement_start_line_numbers.delete(cop_name)
          disabled_line_ranges[cop_name] << (start_line..line) if start_line
        end
      end

      disablement_start_line_numbers.each do |cop_name, start_line|
        disabled_line_ranges[cop_name] << (start_line..Float::INFINITY)
      end

      disabled_line_ranges
    end

    def each_mentioned_cop
      return if processed_source.comments.nil?

      processed_source.comments.each do |comment|
        match = comment.text.match(COMMENT_DIRECTIVE_REGEXP)
        next unless match

        switch, cops_string = match.captures

        cop_names =
          cops_string == 'all' ? all_cop_names : cops_string.split(/,\s*/)

        disabled = (switch == 'disable')
        comment_line_number = comment.loc.expression.line
        single_line = !comment_only_line?(comment_line_number)

        cop_names.each do |cop_name|
          cop_name = Cop::Cop.qualified_cop_name(cop_name.strip,
                                                 processed_source.buffer.name)
          yield cop_name, disabled, comment_line_number, single_line
        end
      end
    end

    def all_cop_names
      @all_cop_names ||= Cop::Cop.all.map(&:cop_name).reject do |cop_name|
        cop_name == UNNEEDED_DISABLE
      end
    end

    def comment_only_line?(line_number)
      non_comment_token_line_numbers.none? do |non_comment_line_number|
        non_comment_line_number == line_number
      end
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
