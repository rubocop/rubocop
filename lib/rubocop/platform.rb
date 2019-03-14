# frozen_string_literal: true

module RuboCop
  # This module provides information on the platform that RuboCop is being run
  # on.
  module Platform
    def self.windows?
      RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/
    end
  end
end
