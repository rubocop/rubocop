# encoding: utf-8

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
  end

  it 'registers an offense for a block when method in body is unary -/=' do
    inspect_source(cop, 'something.map { |x| -x }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Pass `&:-@` as an argument to `map` instead of a block.'])
  end

  it 'accepts method receiving another argument beside the block' do
    inspect_source(cop, 'File.open(file) { |f| f.readlines }')

    expect(cop.offenses).to be_empty
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

  it 'autocorrects alias with symbols as proc' do
    corrected = autocorrect_source(cop, ['coll.map { |s| s.upcase }'])
    expect(corrected).to eq 'coll.map(&:upcase)'
  end

  it 'autocorrects multiple aliases with symbols as proc' do
    corrected = autocorrect_source(cop, ['coll.map { |s| s.upcase }' \
                                         '.map { |s| s.downcase }'])
    expect(corrected).to eq 'coll.map(&:upcase).map(&:downcase)'
  end

  it 'does not crash with a bare method call' do
    run = -> { inspect_source(cop, 'coll.map { |s| bare_method }') }
    expect(&run).not_to raise_error
  end
end
