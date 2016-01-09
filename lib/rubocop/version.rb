# encoding: utf-8

module RuboCop
  # This module holds the RuboCop version information.
  module Version
    STRING = '0.35.1'.freeze

    MSG = '%s (using Parser %s, running on %s %s %s)'.freeze

    module_function

    def version(debug = false)
      if debug
        format(MSG, STRING, Parser::VERSION,
               RUBY_ENGINE, RUBY_VERSION, RUBY_PLATFORM)
      else
        STRING
      end
    end
  end
end
