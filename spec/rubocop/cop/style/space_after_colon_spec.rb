# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAfterColon do
  subject(:cop) { described_class.new }

  it 'registers an offense for colon without space after it' do
    inspect_source(cop, '{a:3}')
    expect(cop.messages).to eq(['Space missing after colon.'])
    expect(cop.highlights).to eq([':'])
  end

  it 'accepts colons in symbols' do
    inspect_source(cop, 'x = :a')
    expect(cop.messages).to be_empty
  end

  it 'accepts colon in ternary followed by space' do
    inspect_source(cop, 'x = w ? a : b')
    expect(cop.messages).to be_empty
  end

  it 'accepts hashes with a space after colons' do
    inspect_source(cop, '{a: 3}')
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

  it 'accepts colons in strings' do
    inspect_source(cop, "str << ':'")
    expect(cop.messages).to be_empty
  end

  it 'accepts required keyword arguments' do
    inspect_source(cop, ['def f(x:, y:)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  if RUBY_VERSION >= '2.1'
    it 'accepts colons denoting required keyword argument' do
      inspect_source(cop, ['def initialize(table:, nodes:)',
                           'end'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offence if an keyword optional argument has no space' do
      inspect_source(cop, ['def m(var:1, other_var: 2)',
                           'end'])
      expect(cop.messages).to eq(['Space missing after colon.'])
    end
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'def f(a:, b:2); {a:3}; end')
    expect(new_source).to eq('def f(a:, b: 2); {a: 3}; end')
  end
end
