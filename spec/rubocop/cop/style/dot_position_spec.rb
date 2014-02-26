# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::DotPosition, :config do
  subject(:cop) { described_class.new(config) }

  context 'Leading dots style' do
    let(:cop_config) { { 'EnforcedStyle' => 'leading' } }

    it 'registers an offense for trailing dot in multi-line call' do
      inspect_source(cop, ['something.',
                           '  method_name'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'trailing')
    end

    it 'registers an offense for correct + opposite' do
      inspect_source(cop, ['something',
                           '  .method_name',
                           'something.',
                           '  method_name'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts leading do in multi-line method call' do
      inspect_source(cop, ['something',
                           '  .method_name'])
      expect(cop.offenses).to be_empty
    end

    it 'does not err on method call with no dots' do
      inspect_source(cop, ['puts something'])
      expect(cop.offenses).to be_empty
    end

    it 'does not err on method call without a method name' do
      inspect_source(cop, ['l.', '(1)'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not err on method call on same line' do
      inspect_source(cop, ['something.method_name'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'Trailing dots style' do
    let(:cop_config) { { 'EnforcedStyle' => 'trailing' } }

    it 'registers an offense for leading dot in multi-line call' do
      inspect_source(cop, ['something',
                           '  .method_name'])
      expect(cop.messages)
        .to eq(['Place the . on the previous line, together with the method ' \
                'call receiver.'])
      expect(cop.highlights).to eq(['.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'leading')
    end

    it 'accepts trailing dot in multi-line method call' do
      inspect_source(cop, ['something.',
                           '  method_name'])
      expect(cop.offenses).to be_empty
    end

    it 'does not err on method call with no dots' do
      inspect_source(cop, ['puts something'])
      expect(cop.offenses).to be_empty
    end

    it 'does not err on method call without a method name' do
      inspect_source(cop, ['l', '.(1)'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not err on method call on same line' do
      inspect_source(cop, ['something.method_name'])
      expect(cop.offenses).to be_empty
    end

    it 'does not get confused by several lines of chained methods' do
      inspect_source(cop, ['File.new(something).',
                           'readlines.map.',
                           'compact.join("\n")'])
      expect(cop.offenses).to be_empty
    end
  end
end
