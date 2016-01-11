# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ClassCheck, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is is_a?' do
    let(:cop_config) { { 'EnforcedStyle' => 'is_a?' } }

    it 'registers an offense for kind_of?' do
      inspect_source(cop, 'x.kind_of? y')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['kind_of?'])
      expect(cop.messages)
        .to eq(['Prefer `Object#is_a?` over `Object#kind_of?`.'])
    end

    it 'auto-corrects kind_of? to is_a?' do
      corrected = autocorrect_source(cop, ['x.kind_of? y'])
      expect(corrected).to eq 'x.is_a? y'
    end
  end

  context 'when enforced style is kind_of?' do
    let(:cop_config) { { 'EnforcedStyle' => 'kind_of?' } }

    it 'registers an offense for is_a?' do
      inspect_source(cop, 'x.is_a? y')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['is_a?'])
      expect(cop.messages)
        .to eq(['Prefer `Object#kind_of?` over `Object#is_a?`.'])
    end

    it 'auto-corrects is_a? to kind_of?' do
      corrected = autocorrect_source(cop, ['x.is_a? y'])
      expect(corrected).to eq 'x.kind_of? y'
    end
  end
end
