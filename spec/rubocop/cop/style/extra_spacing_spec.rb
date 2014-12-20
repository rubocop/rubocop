# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::ExtraSpacing do
  subject(:cop) { described_class.new }

  it 'registers an offense for double extra spacing on variable assignment' do
    inspect_source(cop, 'm    = "hello"')
    expect(cop.offenses.size).to eq(1)
  end

  it 'ignores whitespace at the beginning of the line' do
    inspect_source(cop, '  m = "hello"')
    expect(cop.offenses.size).to eq(0)
  end

  it 'ignores whitespace inside a string' do
    inspect_source(cop, 'm = "hello   this"')
    expect(cop.offenses.size).to eq(0)
  end

  it 'does not permit you to line up assignments' do
    inspect_source(cop, [
      'website = "example.org"',
      'name    = "Jill"'
    ])
    expect(cop.offenses.size).to eq(1)
  end

  it 'gives the correct line' do
    inspect_source(cop, [
      'website = "example.org"',
      'name    = "Jill"'
    ])
    expect(cop.offenses.first.location.line).to eq(2)
  end

  it 'registers an offense on class inheritance' do
    inspect_source(cop, [
      'class A   < String',
      'end'
    ])
    expect(cop.offenses.size).to eq(1)
  end

  it 'auto-corrects a line indented with mixed whitespace' do
    new_source = autocorrect_source(cop, [
      'website = "example.org"',
      'name    = "Jill"'
    ])
    expect(new_source).to eq([
      'website = "example.org"',
      'name = "Jill"'
    ].join("\n"))
  end

  it 'auto-corrects the class inheritance' do
    new_source = autocorrect_source(cop, [
      'class A   < String',
      'end'
    ])
    expect(new_source).to eq([
      'class A < String',
      'end'
    ].join("\n"))
  end
end
