# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineAssignmentLayout, :config do
  subject(:cop) { described_class.new(config) }
  let(:enforced_style) { 'new_line' }
  let(:supported_types) { %w(if) }

  let(:cop_config) do
    {
      'EnforcedStyle' => enforced_style,
      'SupportedTypes' => supported_types
    }
  end

  context 'new_line style' do
    let(:enforced_style) { 'new_line' }

    it 'registers an offense when the rhs is on the same line' do
      inspect_source(cop, ['blarg = if true',
                           'end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["blarg = if true\nend"])
      expect(cop.messages).to eq([described_class::NEW_LINE_OFFENSE])
    end

    it 'auto-corrects offenses' do
      new_source = autocorrect_source(cop, ['blarg = if true',
                                            'end'])

      expect(new_source).to eq("blarg =\n if true\nend")
    end

    it 'ignores arrays' do
      inspect_source(cop, ['a, b = 4,',
                           '5'])

      expect(cop.offenses).to be_empty
    end

    context 'configured supported types' do
      let(:supported_types) { %w(array) }

      it 'allows supported types to be configured' do
        inspect_source(cop, ['a, b = 4,',
                             '5'])

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq(["a, b = 4,\n5"])
        expect(cop.messages).to eq([described_class::NEW_LINE_OFFENSE])
      end
    end

    it 'allows multi-line assignments on separate lines' do
      inspect_source(cop, ['blarg=',
                           'if true',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for masgn with multi-line lhs' do
      inspect_source(cop, ['a,',
                           'b = if foo',
                           'end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["a,\nb = if foo\nend"])
      expect(cop.messages).to eq([described_class::NEW_LINE_OFFENSE])
    end
  end

  context 'same_line style' do
    let(:enforced_style) { 'same_line' }

    it 'registers an offense when the rhs is a different line' do
      inspect_source(cop, ['blarg =',
                           'if true',
                           'end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["blarg =\nif true\nend"])
      expect(cop.messages).to eq([described_class::SAME_LINE_OFFENSE])
    end

    it 'auto-corrects offenses' do
      new_source = autocorrect_source(cop, ['blarg =',
                                            'if true',
                                            'end'])

      expect(new_source).to eq("blarg = if true\nend")
    end

    it 'ignores arrays' do
      inspect_source(cop, ['a, b =',
                           '4,',
                           '5'])

      expect(cop.offenses).to be_empty
    end

    context 'configured supported types' do
      let(:supported_types) { %w(array) }

      it 'allows supported types to be configured' do
        inspect_source(cop, ['a, b =',
                             '4,',
                             '5'])

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq(["a, b =\n4,\n5"])
        expect(cop.messages).to eq([described_class::SAME_LINE_OFFENSE])
      end
    end

    it 'allows multi-line assignments on the same line' do
      inspect_source(cop, ['blarg= if true',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for masgn with multi-line lhs' do
      inspect_source(cop, ['a,',
                           'b =',
                           'if foo',
                           'end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["a,\nb =\nif foo\nend"])
      expect(cop.messages).to eq([described_class::SAME_LINE_OFFENSE])
    end
  end
end
