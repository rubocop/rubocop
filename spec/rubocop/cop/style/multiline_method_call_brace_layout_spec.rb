# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineMethodCallBraceLayout do
  subject(:cop) { described_class.new }

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

  context 'opening brace on same line as first argument' do
    it 'allows closing brace on same line as last argument' do
      inspect_source(cop, ['foo(1,',
                           '2)'])

      expect(cop.offenses).to be_empty
    end

    it 'allows closing brace on same line as last multiline argument' do
      inspect_source(cop, ['foo(1,',
                           'b: {',
                           'foo: 2',
                           '})'])

      expect(cop.offenses).to be_empty
    end

    it 'detects closing brace on different line from last argument' do
      inspect_source(cop, ['foo(1,',
                           '2',
                           ')'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["foo(1,\n2\n)"])
      expect(cop.messages).to eq([described_class::SAME_LINE_MESSAGE])
    end

    it 'autocorrects closing brace on different line from last argument' do
      new_source = autocorrect_source(cop, ['foo(1,',
                                            '2',
                                            ')'])

      expect(new_source).to eq("foo(1,\n2)")
    end
  end

  context 'opening brace on separate line from first argument' do
    it 'allows closing brace on separate line from last argument' do
      inspect_source(cop, ['foo(',
                           '1,',
                           '2',
                           ')'])

      expect(cop.offenses).to be_empty
    end

    it 'allows closing brace on separate line from last multiline argument' do
      inspect_source(cop, ['foo(',
                           '1,',
                           'b: {',
                           'bar: 2',
                           '}',
                           ')'])

      expect(cop.offenses).to be_empty
    end

    it 'detects closing brace on same line as last argument' do
      inspect_source(cop, ['foo(',
                           '1,',
                           '2)'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["foo(\n1,\n2)"])
      expect(cop.messages).to eq([described_class::NEW_LINE_MESSAGE])
    end

    it 'autocorrects closing brace on different line from last argument' do
      new_source = autocorrect_source(cop, ['foo(',
                                            '1,',
                                            '2)'])

      expect(new_source).to eq("foo(\n1,\n2\n)")
    end
  end
end
