# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::Lambda do
  subject(:cop) { described_class.new }

  it 'registers an offense for an old single-line lambda call' do
    inspect_source(cop, 'f = lambda { |x| x }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use the new lambda literal syntax `->(params) {...}`.'])
  end

  it 'registers an offense for an old single-line no-argument lambda call' do
    inspect_source(cop, 'f = lambda { x }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use the new lambda literal syntax `-> {...}`.'])
  end

  it 'accepts the new lambda literal with single-line body' do
    inspect_source(cop, ['lambda = ->(x) { x }',
                         'lambda.(1)'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for a new multi-line lambda call' do
    inspect_source(cop, ['f = ->(x) do',
                         '  x',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use the `lambda` method for multi-line lambdas.'])
  end

  it 'accepts the old lambda syntax with multi-line body' do
    inspect_source(cop, ['l = lambda do |x|',
                         '  x',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts the lambda call outside of block' do
    inspect_source(cop, 'l = lambda.test')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects an old single-line lambda call' do
    new_source = autocorrect_source(cop, 'f = lambda { |x| x }')
    expect(new_source).to eq('f = ->(x) { x }')
  end

  it 'auto-corrects an old single-line no-argument lambda call' do
    new_source = autocorrect_source(cop, 'f = lambda { x }')
    expect(new_source).to eq('f = -> { x }')
  end

  it 'auto-corrects a new multi-line lambda call' do
    new_source = autocorrect_source(cop, ['f = ->(x) do',
                                          '  x',
                                          'end'])
    expect(new_source).to eq(['f = lambda do |x|',
                              '  x',
                              'end'].join("\n"))
  end

  it 'auto-corrects a new multi-line no-argument lambda call' do
    new_source = autocorrect_source(cop, ['f = -> do',
                                          '  x',
                                          'end'])
    expect(new_source).to eq(['f = lambda do',
                              '  x',
                              'end'].join("\n"))
  end
end
