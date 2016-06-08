# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineMethodCallBraceLayout, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common' do
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

    include_examples 'multiline literal brace layout' do
      let(:open) { 'foo(' }
      let(:close) { ')' }
    end
  end

  context 'Symmetrical braces style' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    it_behaves_like 'common'
  end

  context 'Braces on a new line style' do
    let(:cop_config) { { 'EnforcedStyle' => 'new_line' } }

    it_behaves_like 'common'
  end

  context 'Braces on the same line style' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    it_behaves_like 'common'
  end

  include_examples 'multiline literal brace layout trailing comma' do
    let(:open) { 'foo(' }
    let(:close) { ')' }
  end

  context 'when EnforcedStyle is new_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    it 'still ignores single-line calls' do
      inspect_source(cop, 'puts("Hello world!")')
      expect(cop.offenses).to be_empty
    end
  end
end
