# encoding: utf-8

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

  failure_message_when_negated do
    "expected block not to call exit(#{code})"
  end

  description do
    "expect block to call exit(#{code})"
  end
end

RSpec::Matchers.define :find_offenses_in do |code|
  match do |cop|
    inspect_source(cop, code)
    includes_highlight(cop) &&
      includes_message(cop) &&
      cop.offenses.any?
  end

  chain :with_highlight do |highlight|
    @highlight = highlight
  end

  chain :with_message do |message|
    @message = message
  end

  def includes_highlight(cop)
    return true unless @highlight

    cop.highlights.include?(@highlight)
  end

  def includes_message(cop)
    return true unless @message

    cop.offenses.map(&:message).include?(@message)
  end
end
