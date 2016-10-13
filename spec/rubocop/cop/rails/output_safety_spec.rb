# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::OutputSafety do
  subject(:cop) { described_class.new }

  it 'registers an offense for html_safe methods with a receiver and no ' \
     'arguments' do
    source = ['foo.html_safe',
              '"foo".html_safe']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'accepts html_safe methods without a receiver' do
    source = 'html_safe'
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts html_safe methods with arguments' do
    source = ['foo.html_safe one',
              '"foo".html_safe two']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for raw methods without a receiver' do
    source = ['raw(foo)',
              'raw "foo"']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'accepts raw methods with a receiver' do
    source = ['foo.raw(foo)',
              '"foo".raw "foo"']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts raw methods without arguments' do
    source = 'raw'
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts raw methods with more than one arguments' do
    source = 'raw one, two'
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts comments' do
    source = ['# foo.html_safe',
              '# raw foo']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end
end
