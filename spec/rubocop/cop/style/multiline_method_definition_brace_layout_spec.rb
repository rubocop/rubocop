# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineMethodDefinitionBraceLayout, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit defs' do
    inspect_source(cop, ['def foo a: 1,',
                         'b: 2',
                         'end'])

    expect(cop.offenses).to be_empty
  end

  it 'ignores single-line defs' do
    inspect_source(cop, ['def foo(a,b)',
                         'end'])

    expect(cop.offenses).to be_empty
  end

  it 'ignores defs without params' do
    inspect_source(cop, ['def foo',
                         'end'])

    expect(cop.offenses).to be_empty
  end

  include_examples 'multiline literal brace layout' do
    let(:prefix) { 'def foo' }
    let(:suffix) { 'end' }
    let(:open) { '(' }
    let(:close) { ')' }
    let(:multi_prefix) { 'b: ' }
  end
end
