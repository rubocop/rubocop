# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EndOfLine do
  subject(:cop) { described_class.new }

  it 'accepts an empty file' do
    inspect_source_file(cop, '')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for CR+LF' do
    inspect_source_file(cop, ['x=0', '', "y=1\r"])
    expect(cop.messages).to eq(['Carriage return character detected.'])
  end

  it 'highlights the whole offending line' do
    inspect_source_file(cop, ['x=0', '', "y=1\r"])
    expect(cop.highlights).to eq(["y=1\r"])
  end

  it 'registers an offense for CR at end of file' do
    inspect_source_file(cop, "x=0\r")
    expect(cop.messages).to eq(['Carriage return character detected.'])
  end

  it 'does not register offenses after __END__' do
    inspect_source(cop, ['x=0',
                         '__END__',
                         "x=0\r"])
    expect(cop.offenses).to be_empty
  end

  shared_examples 'iso-8859-15' do
    it 'can inspect non-UTF-8 encoded source with proper encoding comment' do
      inspect_source_file(cop, ['# coding: ISO-8859-15\r',
                                "# Euro symbol: \xa4\r"])
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'when there are many lines ending with CR+LF' do
    it 'registers only one offense' do
      inspect_source_file(cop, ['x=0', '', 'y=1'].join("\r\n"))
      expect(cop.messages.size).to eq(1)
    end

    include_examples 'iso-8859-15'
  end

  context 'when the default external encoding is US_ASCII' do
    let(:orig_encoding) { Encoding.default_external }
    before(:each) { Encoding.default_external = Encoding::US_ASCII }
    after(:each) { Encoding.default_external = orig_encoding }

    it 'does not crash on UTF-8 encoded non-ascii characters' do
      inspect_source_file(cop,
                          ['# encoding: UTF-8',
                           'class Epd::ReportsController < EpdAreaController',
                           "  'terecht bij uw ROM-coördinator.'",
                           'end'].join("\n"))
      expect(cop.offenses).to be_empty
    end

    include_examples 'iso-8859-15'
  end

  context 'when source is a string' do
    it 'registers an offense' do
      inspect_source(cop, "x=0\r")

      expect(cop.messages).to eq(['Carriage return character detected.'])
    end
  end
end
