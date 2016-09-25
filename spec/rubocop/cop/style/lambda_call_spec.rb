# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::LambdaCall, :config do
  subject(:cop) { described_class.new(config) }

  context 'when style is set to call' do
    let(:cop_config) { { 'EnforcedStyle' => 'call' } }

    it 'registers an offense for x.()' do
      inspect_source(cop,
                     'x.(a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'braces')
    end

    it 'registers an offense for correct + opposite' do
      inspect_source(cop,
                     ['x.call(a, b)',
                      'x.(a, b)'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts x.call()' do
      inspect_source(cop, 'x.call(a, b)')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects x.() to x.call()' do
      new_source = autocorrect_source(cop, ['a.(x)'])
      expect(new_source).to eq('a.call(x)')
    end
  end

  context 'when style is set to braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'braces' } }

    it 'registers an offense for x.call()' do
      inspect_source(cop,
                     'x.call(a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'call')
    end

    it 'registers an offense for opposite + correct' do
      inspect_source(cop,
                     ['x.call(a, b)',
                      'x.(a, b)'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts x.()' do
      inspect_source(cop, 'x.(a, b)')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects x.call() to x.()' do
      new_source = autocorrect_source(cop, ['a.call(x)'])
      expect(new_source).to eq('a.(x)')
    end
  end
end
