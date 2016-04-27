# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::InfiniteLoop do
  subject(:cop) { described_class.new }

  %w(1 2.0 [1] {}).each do |lit|
    it "registers an offense for a while loop with #{lit} as condition" do
      inspect_source(cop,
                     ["while #{lit}",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  %w(false nil).each do |lit|
    it "registers an offense for a until loop with #{lit} as condition" do
      inspect_source(cop,
                     ["until #{lit}",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'accepts Kernel#loop' do
    inspect_source(cop,
                   'loop { break if something }')

    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects the usage of "while/until" with do' do
    new_source = autocorrect_source(cop, ['while true do',
                                          'end'])
    expect(new_source).to eq("loop do\nend")
  end

  it 'auto-corrects the usage of "while/until" without do' do
    new_source = autocorrect_source(cop, ['while 1',
                                          'end'])
    expect(new_source).to eq("loop do\nend")
  end
end
