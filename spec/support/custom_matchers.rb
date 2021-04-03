# frozen_string_literal: true

RSpec::Matchers.define :exit_with_code do |code|
  supports_block_expectations

  actual = nil

  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end
    actual && actual == code
  end

  failure_message do
    "expected block to call exit(#{code}) but exit" +
      (actual.nil? ? ' not called' : "(#{actual}) was called")
  end

  failure_message_when_negated { "expected block not to call exit(#{code})" }

  description { "expect block to call exit(#{code})" }
end
