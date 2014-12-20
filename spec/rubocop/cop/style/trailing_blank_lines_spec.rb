# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::TrailingBlankLines, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is final_newline' do
    let(:cop_config) { { 'EnforcedStyle' => 'final_newline' } }

    it 'accepts final newline' do
      inspect_source(cop, ['x = 0', ''])
      expect(cop.offenses).to be_empty
    end

    it 'accepts an empty file' do
      inspect_source(cop, '')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for multiple trailing blank lines' do
      inspect_source(cop, ['x = 0', '', '', '', ''])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['3 trailing blank lines detected.'])
    end

    it 'registers an offense for no final newline' do
      inspect_source(cop, 'x = 0')
      expect(cop.messages).to eq(['Final newline missing.'])
    end

    it 'auto-corrects unwanted blank lines' do
      new_source = autocorrect_source(cop, ['x = 0', '', '', '', ''])
      expect(new_source).to eq(['x = 0', ''].join("\n"))
    end

    it 'auto-corrects even if some lines have space' do
      new_source = autocorrect_source(cop, ['x = 0', '', '  ', '', ''])
      expect(new_source).to eq(['x = 0', ''].join("\n"))
    end
  end

  context 'when EnforcedStyle is final_blank_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'final_blank_line' } }

    it 'registers an offense for final newline' do
      inspect_source(cop, ['x = 0', ''])
      expect(cop.messages).to eq(['Trailing blank line missing.'])
    end

    it 'registers an offense for multiple trailing blank lines' do
      inspect_source(cop, ['x = 0', '', '', '', ''])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['3 trailing blank lines instead of 1 detected.'])
    end

    it 'registers an offense for no final newline' do
      inspect_source(cop, 'x = 0')
      expect(cop.messages).to eq(['Final newline missing.'])
    end

    it 'accepts final blank line' do
      inspect_source(cop, ['x = 0', '', ''])
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects unwanted blank lines' do
      new_source = autocorrect_source(cop, ['x = 0', '', '', '', ''])
      expect(new_source).to eq(['x = 0', '', ''].join("\n"))
    end

    it 'auto-corrects missing blank line' do
      new_source = autocorrect_source(cop, ['x = 0', ''])
      expect(new_source).to eq(['x = 0', '', ''].join("\n"))
    end

    it 'auto-corrects missing newline' do
      new_source = autocorrect_source(cop, ['x = 0'])
      expect(new_source).to eq(['x = 0', '', ''].join("\n"))
    end
  end
end
