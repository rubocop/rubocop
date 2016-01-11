# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAfterColon do
  subject(:cop) { described_class.new }

  it 'registers an offense for colon without space after it' do
    # TODO: There is double reporting of the last colon (also from
    # SpaceAroundOperators).
    inspect_source(cop, 'x = w ? {a:3}:4')
    expect(cop.messages).to eq(['Space missing after colon.'] * 2)
    expect(cop.highlights).to eq([':'] * 2)
  end

  it 'accepts colons in symbols' do
    inspect_source(cop, 'x = :a')
    expect(cop.messages).to be_empty
  end

  it 'accepts colon in ternary followed by space' do
    inspect_source(cop, 'x = w ? a : b')
    expect(cop.messages).to be_empty
  end

  it 'accepts hash rockets' do
    inspect_source(cop, 'x = {"a"=>1}')
    expect(cop.messages).to be_empty
  end

  it 'accepts if' do
    inspect_source(cop, ['x = if w',
                         '      a',
                         '    end'])
    expect(cop.messages).to be_empty
  end

  if RUBY_VERSION >= '2.1'
    it 'accepts colons denoting required keyword argument' do
      inspect_source(cop, ['def initialize(table:, nodes:)',
                           'end'])
      expect(cop.messages).to be_empty
    end
  end

  it 'accepts colons in strings' do
    inspect_source(cop, "str << ':'")
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'x = w ? {a:3}:4')
    expect(new_source).to eq('x = w ? {a: 3}: 4')
  end
end
