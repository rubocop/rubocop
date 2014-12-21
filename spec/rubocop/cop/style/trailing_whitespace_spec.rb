# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::TrailingWhitespace do
  subject(:cop) { described_class.new }

  it 'registers an offense for a line ending with space' do
    source = 'x = 0 '
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a line ending with tab' do
    inspect_source(cop, "x = 0\t")
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a line without trailing whitespace' do
    inspect_source(cop, ['x = 0',
                         ''])
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(cop, ['x = 0 ',
                                          "x = 0\t"])
    expect(new_source).to eq(['x = 0',
                              'x = 0'].join("\n"))
  end
end
