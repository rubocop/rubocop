# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineMethodDefinitionBraceLayout do
  subject(:cop) { described_class.new }

  it 'ignores implicit defs' do
    inspect_source(cop, ['def foo a: 1,',
                         'b: 2',
                         'end'])

    expect(cop.offenses).to be_empty
  end

  it 'ignores single-line defs' do
    inspect_source(cop, ['def foo(a,b)',
                         'end'])

    expect(cop.offenses).to be_empty
  end

  it 'ignores defs without params' do
    inspect_source(cop, ['def foo',
                         'end'])

    expect(cop.offenses).to be_empty
  end

  context 'opening brace on same line as first parameter' do
    it 'allows closing brace on same line as last parameter' do
      inspect_source(cop, ['def foo(a,',
                           'b)',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'allows closing brace on same line as last multiline parameter' do
      inspect_source(cop, ['def foo(a,',
                           'b: {',
                           'foo: bar',
                           '})',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'detects closing brace on different line from last parameter' do
      inspect_source(cop, ['def foo(a,',
                           'b',
                           ')',
                           'end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["(a,\nb\n)"])
      expect(cop.messages).to eq([described_class::SAME_LINE_MESSAGE])
    end

    it 'autocorrects closing brace on different line from last parameter' do
      new_source = autocorrect_source(cop, ['def foo(a,',
                                            'b',
                                            ')',
                                            'end'])

      expect(new_source).to eq("def foo(a,\nb)\nend")
    end
  end

  context 'opening brace on separate line from first parameter' do
    it 'allows closing brace on separate line from last parameter' do
      inspect_source(cop, ['def foo(',
                           'a,',
                           'b',
                           ')',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'allows closing brace on separate line from last multiline parameter' do
      inspect_source(cop, ['def foo(',
                           'a,',
                           'b: {',
                           'foo: bar',
                           '}',
                           ')',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'detects closing brace on same line as last parameter' do
      inspect_source(cop, ['def foo(',
                           'a,',
                           'b)',
                           'end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(["(\na,\nb)"])
      expect(cop.messages).to eq([described_class::NEW_LINE_MESSAGE])
    end

    it 'autocorrects closing brace on different line from last parameter' do
      new_source = autocorrect_source(cop, ['def foo(',
                                            'a,',
                                            'b)',
                                            'end'])

      expect(new_source).to eq("def foo(\na,\nb\n)\nend")
    end
  end
end
