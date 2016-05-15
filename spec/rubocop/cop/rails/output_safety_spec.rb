# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::OutputSafety do
  subject(:cop) { described_class.new }

  it 'records an offense for html_safe methods with a receiver' do
    source = ['foo.html_safe',
              '"foo".html_safe']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not record an offense for html_safe methods without a receiver' do
    source = ['html_safe foo',
              'html_safe "foo"']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'records an offense for raw methods without a receiver' do
    source = ['raw(foo)',
              'raw "foo"']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not record an offense for raw methods with a receiver' do
    source = ['foo.raw',
              '"foo".raw']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'does not record an offense for comments' do
    source = ['# foo.html_safe',
              '# raw foo']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end
end
