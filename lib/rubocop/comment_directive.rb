# frozen_string_literal: true

module RuboCop
  # This class represents a single a `rubocop:*` comment directive.
  class CommentDirective
    UNNEEDED_DISABLE = 'Lint/UnneededDisable'.freeze

    # The available keywords to come after `# rubocop:`.
    KEYWORDS = %i[disable enable todo end_todo].freeze

    KEYWORD_PATTERN = "(#{KEYWORDS.join('|')})\\b".freeze
    COP_NAME_PATTERN = '([A-Z]\w+/)?(?:[A-Z]\w+)'.freeze
    COP_NAMES_PATTERN = "(?:#{COP_NAME_PATTERN} , )*#{COP_NAME_PATTERN}".freeze
    COPS_PATTERN = "(all|#{COP_NAMES_PATTERN})".freeze

    COMMENT_DIRECTIVE_REGEXP = Regexp.new(
      "# rubocop : #{KEYWORD_PATTERN} #{COPS_PATTERN}".gsub(' ', '\s*')
    )

    # Initializes a new CommentDirective if the provided
    # Parser::Source::Comment contains a directive. Returns nil if it does
    # not.
    def self.from_comment(comment)
      return unless comment && comment.text =~ COMMENT_DIRECTIVE_REGEXP

      keyword, cops_string = Regexp.last_match.captures
      source_range = comment.loc.expression

      if cops_string == 'all'
        cop_names = :all
      else
        cop_names = cops_string.split(/\s*,\s*/)
        cop_names.map! do |name|
          Cop::Cop.qualified_cop_name(name, source_range.source_buffer.name)
        end
      end

      CommentDirective.new(keyword.to_sym, source_range, cop_names)
    end

    def initialize(keyword, source_range, cop_names)
      @keyword = keyword
      @source_range = source_range
      @all_cops = (cop_names == :all)
      @cop_names = all_cops? ? all_cop_names : cop_names
      freeze
    end

    attr_reader :keyword
    attr_reader :source_range
    attr_reader :cop_names

    def all_cops?
      @all_cops
    end

    def line
      source_range.line
    end

    def disable?
      keyword == :disable || keyword == :todo
    end

    def open_keyword
      case keyword
      when :disable, :enable then :disable
      when :todo, :end_todo then :todo
      end
    end

    private

    def all_cop_names
      Cop::Cop.registry.names - [UNNEEDED_DISABLE]
    end
  end
end
