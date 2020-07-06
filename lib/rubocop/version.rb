# frozen_string_literal: true

module RuboCop
  # This module holds the RuboCop version information.
  module Version
    STRING = '0.87.0'

    MSG = '%<version>s (using Parser %<parser_version>s, '\
          'rubocop-ast %<rubocop_ast_version>s, ' \
          'running on %<ruby_engine>s %<ruby_version>s %<ruby_platform>s)'

    def self.version(debug = false)
      if debug
        format(MSG, version: STRING, parser_version: Parser::VERSION,
                    rubocop_ast_version: RuboCop::AST::Version::STRING,
                    ruby_engine: RUBY_ENGINE, ruby_version: RUBY_VERSION,
                    ruby_platform: RUBY_PLATFORM)
      else
        STRING
      end
    end
  end
end
