# frozen_string_literal: true

# NOTE: Prevents the cause from being obscured by `uninitialized constant StrictWarnings::StringIO`
# when there is a warning or syntax error in the product code.
require 'stringio'

# Ensure that RuboCop runs warning-free. This hooks into Ruby's `warn`
# method and raises when an unexpected warning is encountered.
module StrictWarnings
  class WarningError < StandardError; end

  # Warnings from 3rd-party gems, or other things that are unactionable
  SUPPRESSED_WARNINGS = Regexp.union(
    %r{lib/parser/builders/default.*Unknown escape},
    %r{lib/parser/builders/default.*character class has duplicated range},
    /Float.*out of range/, # also from the parser gem
    /`Process` does not respond to `fork` method/, # JRuby
    /File#readline accesses caller method's state and should not be aliased/, # JRuby, test stub
    /instance variable @.* not initialized/, # Ruby 2.7
    /`inspect_file` is deprecated\. Use `investigate` instead\./, # RuboCop's deprecated API in spec
    /`forces` is deprecated./, # RuboCop's deprecated API in spec
    /`support_autocorrect\?` is deprecated\./, # RuboCop's deprecated API in spec
    /`Cop\.registry` is deprecated\./ # RuboCop's deprecated API in spec
  )

  def warn(message, ...)
    return if SUPPRESSED_WARNINGS.match?(message)

    super
    # RuboCop uses `warn` to display some of its output and tests assert against
    # that. Assume that warnings are intentional when stderr is redirected.
    return if $stderr.is_a?(StringIO)
    # Ignore warnings from dev/rc ruby versions. Things are subject to change and
    # contributors should not be bothered by them with red CI.
    return if RUBY_PATCHLEVEL == -1

    raise WarningError, message
  end

  def self.enable!
    $VERBOSE = true
    Warning[:deprecated] = true
    Warning.singleton_class.prepend(self)
  end
end
