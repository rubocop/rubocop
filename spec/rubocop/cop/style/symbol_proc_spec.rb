# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SymbolProc, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'IgnoredMethods' => %w(respond_to) } }

  it 'registers an offense for a block with parameterless method call on ' \
     'param' do
    inspect_source(cop, 'coll.map { |e| e.upcase }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Pass `&:upcase` as an argument to `map` instead of a block.'])
    expect(cop.highlights).to eq(['{ |e| e.upcase }'])
  end

  it 'registers an offense for a block when method in body is unary -/=' do
    inspect_source(cop, 'something.map { |x| -x }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Pass `&:-@` as an argument to `map` instead of a block.'])
  end

  it 'accepts block with more than 1 arguments' do
    inspect_source(cop, 'something { |x, y| x.method }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts lambda with 1 argument' do
    inspect_source(cop, '->(x) { x.method }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts proc with 1 argument' do
    inspect_source(cop, 'proc { |x| x.method }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts Proc.new with 1 argument' do
    inspect_source(cop, 'Proc.new { |x| x.method }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts ignored method' do
    inspect_source(cop, 'respond_to { |format| format.xml }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts block with no arguments' do
    inspect_source(cop, 'something { x.method }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts empty block body' do
    inspect_source(cop, 'something { |x| }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts block with more than 1 expression in body' do
    inspect_source(cop, 'something { |x| x.method; something_else }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts block when method in body is not called on block arg' do
    inspect_source(cop, 'something { |x| y.method }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts block with a block argument ' do
    inspect_source(cop, 'something { |&x| x.call }')

    expect(cop.offenses).to be_empty
  end

  it 'accepts block with splat params' do
    inspect_source(cop, 'something { |*x| x.first }')

    expect(cop.offenses).to be_empty
  end

  context 'when the method has arguments' do
    let(:source) { 'method(one, 2) { |x| x.test }' }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.messages)
        .to eq(['Pass `&:test` as an argument to `method` instead of a block.'])
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq 'method(one, 2, &:test)'
    end
  end

  it 'autocorrects alias with symbols as proc' do
    corrected = autocorrect_source(cop, ['coll.map { |s| s.upcase }'])
    expect(corrected).to eq 'coll.map(&:upcase)'
  end

  it 'autocorrects multiple aliases with symbols as proc' do
    corrected = autocorrect_source(cop, ['coll.map { |s| s.upcase }' \
                                         '.map { |s| s.downcase }'])
    expect(corrected).to eq 'coll.map(&:upcase).map(&:downcase)'
  end

  it 'auto-corrects correctly when there are no arguments in parentheses' do
    corrected = autocorrect_source(cop, ['coll.map(   ) { |s| s.upcase }'])
    expect(corrected).to eq 'coll.map(&:upcase)'
  end

  it 'does not crash with a bare method call' do
    run = -> { inspect_source(cop, 'coll.map { |s| bare_method }') }
    expect(&run).not_to raise_error
  end

  context 'when `super` has arguments' do
    let(:source) { 'super(one, two) { |x| x.test }' }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.messages)
        .to eq(['Pass `&:test` as an argument to `super` instead of a block.'])
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq 'super(one, two, &:test)'
    end
  end

  context 'when `super` has no arguments' do
    let(:source) { 'super { |x| x.test }' }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.messages)
        .to eq(['Pass `&:test` as an argument to `super` instead of a block.'])
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq 'super(&:test)'
    end
  end

  it 'auto-corrects correctly when args have a trailing comma' do
    corrected = autocorrect_source(cop, ['mail(',
                                         "  to: 'foo',",
                                         "  subject: 'bar',",
                                         ') { |format| format.text }'])
    expect(corrected).to eq(['mail(',
                             "  to: 'foo',",
                             "  subject: 'bar', &:text",
                             ')'].join("\n"))
  end
end
