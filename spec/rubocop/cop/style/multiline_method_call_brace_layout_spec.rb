# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineMethodCallBraceLayout, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit calls' do
    inspect_source(cop, ['foo 1,',
                         '2'])

    expect(cop.offenses).to be_empty
  end

  it 'ignores single-line calls' do
    inspect_source(cop, 'foo(1,2)')

    expect(cop.offenses).to be_empty
  end

  it 'ignores calls without arguments' do
    inspect_source(cop, 'puts')

    expect(cop.offenses).to be_empty
  end

  it 'ignores calls with an empty brace' do
    inspect_source(cop, 'puts()')

    expect(cop.offenses).to be_empty
  end

  it 'ignores calls with a multiline empty brace ' do
    inspect_source(cop, ['puts(',
                         ')'])

    expect(cop.offenses).to be_empty
  end

  include_examples 'multiline literal brace layout' do
    let(:open) { 'foo(' }
    let(:close) { ')' }
  end

  include_examples 'multiline literal brace layout trailing comma' do
    let(:open) { 'foo(' }
    let(:close) { ')' }
  end

  context 'when EnforcedStyle is new_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'new_line' } }

    it 'still ignores single-line calls' do
      inspect_source(cop, 'puts("Hello world!")')
      expect(cop.offenses).to be_empty
    end

    it 'ignores single-line calls with multi-line receiver' do
      inspect_source(cop, ['[',
                           '].join(" ")'])
      expect(cop.offenses).to be_empty
    end

    it 'ignores single-line calls with multi-line receiver with leading dot' do
      inspect_source(cop, ['[',
                           ']',
                           '.join(" ")'])
      expect(cop.offenses).to be_empty
    end
  end
end
