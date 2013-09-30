# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::CommentAnnotation, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    { 'Keywords' => %w(TODO FIXME OPTIMIZE HACK REVIEW) }
  end

  it 'registers an offence for a missing colon' do
    inspect_source(cop, ['# TODO make better'])
    expect(cop.offences.size).to eq(1)
  end

  context 'with configured keyword' do
    let(:cop_config) { { 'Keywords' => %w(ISSUE) } }

    it 'registers an offence for a missing colon after the word' do
      inspect_source(cop, ['# ISSUE wrong order'])
      expect(cop.offences.size).to eq(1)
    end
  end

  context 'when used with the clang formatter' do
    let(:formatter) { Rubocop::Formatter::ClangStyleFormatter.new(output) }
    let(:output) { StringIO.new }

    it 'marks the annotation keyword' do
      inspect_source(cop, ['# TODO:make better'])
      formatter.report_file('t', cop.offences)
      expect(output.string).to eq(["t:1:3: C: #{described_class::MSG}",
                                   '# TODO:make better',
                                   '  ^^^^^',
                                   ''].join("\n"))
    end
  end

  it 'registers an offence for lower case' do
    inspect_source(cop, ['# fixme: does not work'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for capitalized annotation keyword' do
    inspect_source(cop, ['# Optimize: does not work'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for upper case with colon but no note' do
    inspect_source(cop, ['# HACK:'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts upper case keyword with colon, space and note' do
    inspect_source(cop, ['# REVIEW: not sure about this'])
    expect(cop.offences).to be_empty
  end

  it 'accepts upper case keyword alone' do
    inspect_source(cop, ['# OPTIMIZE'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a comment that is obviously a code example' do
    inspect_source(cop, ['# Todo.destroy(1)'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a keyword that is just the beginning of a sentence' do
    inspect_source(cop,
                   ["# Optimize if you want. I wouldn't recommend it.",
                    '# Hack is a fun game.'])
    expect(cop.offences).to be_empty
  end

  context 'when a keyword is not in the configuration' do
    let(:cop_config) do
      { 'Keywords' => %w(FIXME OPTIMIZE HACK REVIEW) }
    end

    it 'accepts the word without colon' do
      inspect_source(cop, ['# TODO make better'])
      expect(cop.offences).to be_empty
    end
  end
end
