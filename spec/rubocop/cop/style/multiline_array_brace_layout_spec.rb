# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineArrayBraceLayout, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common' do
    it 'ignores implicit arrays' do
      inspect_source(cop, ['foo = a,',
                           'b'])

      expect(cop.offenses).to be_empty
    end

    it 'ignores single-line arrays' do
      inspect_source(cop, '[a, b, c]')

      expect(cop.offenses).to be_empty
    end

    it 'ignores empty arrays' do
      inspect_source(cop, '[]')

      expect(cop.offenses).to be_empty
    end

    include_examples 'multiline literal brace layout' do
      let(:open) { '[' }
      let(:close) { ']' }
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
end
