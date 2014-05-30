# encoding: utf-8

RSpec::Matchers.define :find_offenses_in do |code|
  match do |cop|
    inspect_source(cop, [code])
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
