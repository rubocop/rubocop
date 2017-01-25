# frozen_string_literal: true

module RuboCop
  # This module provides information on the platform that RuboCop is being run
  # on.
  module Platform
    module_function

    def windows?
      RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
    end
  end
end
