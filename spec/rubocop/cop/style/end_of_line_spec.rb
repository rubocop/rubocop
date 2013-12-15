# encoding: utf-8

require 'spec_helper'
require 'tempfile'

describe Rubocop::Cop::Style::EndOfLine do
  subject(:cop) { described_class.new }

  it 'registers an offence for CR+LF' do
    inspect_source_file(cop, ['x=0', '', "y=1\r"])
    expect(cop.messages).to eq(['Carriage return character detected.'])
  end

  it 'highlights the whole offendng line' do
    inspect_source_file(cop, ['x=0', '', "y=1\r"])
    expect(cop.highlights).to eq(["y=1\r"])
  end

  it 'registers an offence for CR at end of file' do
    inspect_source_file(cop, ["x=0\r"])
    expect(cop.messages).to eq(['Carriage return character detected.'])
  end

  context 'when there are many lines ending with CR+LF' do
    it 'registers only one offence' do
      inspect_source_file(cop, ['x=0', '', 'y=1'].join("\r\n"))
      expect(cop.messages.size).to eq(1)
    end
  end

  context 'when the default external encoding is US_ASCII' do
    before(:each) do
      @orig_encoding = Encoding.default_external
      Encoding.default_external = Encoding::US_ASCII
    end
    after(:each) { Encoding.default_external = @orig_encoding }

    it 'does not crash on UTF-8 encoded non-ascii characters' do
      inspect_source_file(cop,
                          ['# encoding: UTF-8',
                           'class Epd::ReportsController < EpdAreaController',
                           "  'terecht bij uw ROM-coördinator.'",
                           'end'].join("\n"))
      expect(cop.offences).to be_empty
    end
  end
end
