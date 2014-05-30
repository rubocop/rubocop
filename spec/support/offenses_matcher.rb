# encoding: utf-8

RSpec::Matchers.define :find_offenses_in do |code|
  match do |cop|
    inspect_source(cop, [code])

    if @highlight
      cop.highlights.include?(@highlight)
    else
      cop.offenses.any?
    end
  end

  chain :with_highlight do |highlight|
    @highlight = highlight
  end
end
