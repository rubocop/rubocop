# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAroundEqualsInParameterDefault do
  subject(:cop) { described_class.new }

  it 'registers an offense for default value assignment without space' do
    inspect_source(cop, ['def f(x, y=0, z=1)', 'end'])
    expect(cop.messages).to eq(
      ['Surrounding space missing in default value assignment.'] * 2)
  end

  it 'registers an offense for assignment empty string without space' do
    inspect_source(cop, ['def f(x, y="", z=1)', 'end'])
    expect(cop.offenses.size).to eq(2)
  end

  it 'registers an offense for assignment of empty list without space' do
    inspect_source(cop, ['def f(x, y=[])', 'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts default value assignment with space' do
    inspect_source(cop, ['def f(x, y = 0, z = {})', 'end'])
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, ['def f(x, y=0, z=1)', 'end'])
    expect(new_source).to eq(['def f(x, y = 0, z = 1)', 'end'].join("\n"))
  end
end
