# encoding: utf-8

module Rubocop
  # This module holds the RuboCop version information.
  module Version
    STRING = '0.18.1'

    MSG = '%s (using Parser %s, running on %s %s %s)'

    module_function

    def version(debug = false)
      if debug
        sprintf(MSG, STRING, Parser::VERSION,
                RUBY_ENGINE, RUBY_VERSION, RUBY_PLATFORM)
      else
        STRING
      end
    end
  end
end
