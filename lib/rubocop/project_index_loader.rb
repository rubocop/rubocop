# frozen_string_literal: true

module RuboCop
  # Defensive loader for the optional `rubydex` gem.
  #
  # When `AllCops/UseProjectIndex` is enabled in the user's configuration, RuboCop builds
  # a project-wide index using `Rubydex::Graph` and exposes it to cops that opt in.
  # The gem is intentionally not a runtime dependency; if it is not installed,
  # or if the running Ruby is older than what `rubydex` supports, RuboCop falls back to
  # its standard file-local behavior.
  module ProjectIndexLoader
    MINIMUM_RUBY_VERSION = '3.2'

    module_function

    # Returns whether the `rubydex` gem can be loaded. The result is memoized
    # for the lifetime of the process.
    def available?
      return @available if defined?(@available)

      @available = supported_ruby? && try_require
    end

    def supported_ruby?
      RUBY_VERSION >= MINIMUM_RUBY_VERSION
    end

    def warn_unavailable
      return if @warned

      @warned = true

      if supported_ruby?
        warn Rainbow(<<~MSG).yellow
          `AllCops/UseProjectIndex` is enabled but the `rubydex` gem is not installed.
          Analyses that use the project index will be skipped. Add `gem 'rubydex'` to your Gemfile.
        MSG
      else
        warn Rainbow(<<~MSG).yellow
          `AllCops/UseProjectIndex` is enabled but `rubydex` requires Ruby #{MINIMUM_RUBY_VERSION} or later (current: #{RUBY_VERSION}).
          Analyses that use the project index will be skipped.
        MSG
      end
    end

    def try_require
      require 'rubydex'
      true
    rescue LoadError
      false
    end

    # Builds and resolves a `Rubydex::Graph` for the given file paths. Returns the resolved graph,
    # or `nil` if the build fails. This is the only place in RuboCop that depends on the concrete
    # `Rubydex::Graph` API, so callers (e.g. `Runner`) do not need to know which Rubydex classes
    # or methods are involved.
    def build_index(paths)
      graph = Rubydex::Graph.new
      graph.index_all(paths.map(&:to_s))
      graph.resolve
      graph
    rescue StandardError => e
      warn Rainbow("rubydex index build failed: #{e.message}. Continuing without it.").yellow
    end
  end
end
