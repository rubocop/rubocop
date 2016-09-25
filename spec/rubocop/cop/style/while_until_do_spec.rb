# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::WhileUntilDo do
  subject(:cop) { described_class.new }

  it 'registers an offense for do in multiline while' do
    inspect_source(cop, ['while cond do',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for do in multiline until' do
    inspect_source(cop, ['until cond do',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts do in single-line while' do
    inspect_source(cop, 'while cond do something end')
    expect(cop.offenses).to be_empty
  end

  it 'accepts do in single-line until' do
    inspect_source(cop, 'until cond do something end')
    expect(cop.offenses).to be_empty
  end

  it 'it accepts multi-line while without do' do
    inspect_source(cop, ['while cond',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'it accepts multi-line until without do' do
    inspect_source(cop, ['until cond',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects the usage of "do" in multiline while' do
    new_source = autocorrect_source(cop, ['while cond do',
                                          'end'])
    expect(new_source).to eq(['while cond',
                              'end'].join("\n"))
  end

  it 'auto-corrects the usage of "do" in multiline until' do
    new_source = autocorrect_source(cop, ['until cond do',
                                          'end'])
    expect(new_source).to eq(['until cond',
                              'end'].join("\n"))
  end
end
