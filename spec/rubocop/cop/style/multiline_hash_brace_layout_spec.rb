# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineHashBraceLayout do
  subject(:cop) { described_class.new }

  it 'ignores implicit hashes' do
    inspect_source(cop, ['foo(a: 1,',
                         'b: 2)'])

    expect(cop.offenses).to be_empty
  end

  it 'ignores single-line hashes' do
    inspect_source(cop, '{a: 1, b: 2}')

    expect(cop.offenses).to be_empty
  end

  it 'ignores empty hashes' do
    inspect_source(cop, '{}')

    expect(cop.offenses).to be_empty
  end

  context 'opening brace on same line as first element' do
    it 'allows closing brace on same line as last element' do
      inspect_source(cop, ['{a: 1,',
                           'b: 2}'])

      expect(cop.offenses).to be_empty
    end

    it 'allows closing brace on same line as last multiline element' do
      inspect_source(cop, ['{a: 1,',
                           'b: {',
                           'foo: bar',
                           '}}'])

      expect(cop.offenses).to be_empty
    end

    it 'detects closing brace on different line from last element' do
      inspect_source(cop, ['{a: 1,',
                           'b: 2',
                           '}'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["{a: 1,\nb: 2\n}"])
      expect(cop.messages).to eq([described_class::SAME_LINE_MESSAGE])
    end

    it 'autocorrects closing brace on different line from last element' do
      new_source = autocorrect_source(cop, ['{a: 1,',
                                            'b: 2',
                                            '}'])

      expect(new_source).to eq("{a: 1,\nb: 2}")
    end
  end

  context 'opening brace on separate line from first element' do
    it 'allows closing brace on separate line from last element' do
      inspect_source(cop, ['{',
                           'a: 1,',
                           'b: 2',
                           '}'])

      expect(cop.offenses).to be_empty
    end

    it 'allows closing brace on separate line from last multiline element' do
      inspect_source(cop, ['{',
                           'a: 1,',
                           'b: {',
                           'foo: bar',
                           '}',
                           '}'])

      expect(cop.offenses).to be_empty
    end

    it 'detects closing brace on same line as last element' do
      inspect_source(cop, ['{',
                           'a: 1,',
                           'b: 2}'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["{\na: 1,\nb: 2}"])
      expect(cop.messages).to eq([described_class::NEW_LINE_MESSAGE])
    end

    it 'autocorrects closing brace on different line from last element' do
      new_source = autocorrect_source(cop, ['{',
                                            'a: 1,',
                                            'b: 2}'])

      expect(new_source).to eq("{\na: 1,\nb: 2\n}")
    end
  end
end
