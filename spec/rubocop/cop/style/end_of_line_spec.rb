# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EndOfLine, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'all configurations' do
    it 'accepts an empty file' do
      inspect_source_file(cop, '')
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples 'iso-8859-15' do |eol|
    it 'can inspect non-UTF-8 encoded source with proper encoding comment' do
      inspect_source_file(cop, ["# coding: ISO-8859-15#{eol}",
                                "# Euro symbol: \xa4#{eol}"])
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'when EnforcedStyle is native' do
    let(:cop_config) { { 'EnforcedStyle' => 'native' } }
    let(:messages) do
      ['Carriage return character ' \
        "#{RuboCop::Platform.windows? ? 'missing' : 'detected'}."]
    end

    it 'registers an offense for an incorrect EOL' do
      inspect_source_file(cop, ['x=0', '', "y=1\r"])
      expect(cop.messages).to eq(messages)
      expect(cop.offenses.map(&:line))
        .to eq([RuboCop::Platform.windows? ? 1 : 3])
    end
  end

  context 'when EnforcedStyle is crlf' do
    let(:cop_config) { { 'EnforcedStyle' => 'crlf' } }
    let(:messages) { ['Carriage return character missing.'] }
    include_examples 'all configurations'

    it 'registers an offense for CR+LF' do
      inspect_source_file(cop, ['x=0', '', "y=1\r"])
      expect(cop.messages).to eq(messages)
      expect(cop.offenses.map(&:line)).to eq([1])
    end

    it 'highlights the whole offending line' do
      inspect_source_file(cop, ['x=0', '', "y=1\r"])
      expect(cop.highlights).to eq(["x=0\n"])
    end

    it 'does not register offense for no CR at end of file' do
      inspect_source_file(cop, 'x=0')
      expect(cop.offenses).to be_empty
    end

    it 'does not register offenses after __END__' do
      inspect_source(cop, ["x=0\r",
                           '__END__',
                           'x=0'])
      expect(cop.offenses).to be_empty
    end

    context 'and there are many lines ending with LF' do
      it 'registers only one offense' do
        inspect_source_file(cop, ['x=0', '', 'y=1'].join("\n"))
        expect(cop.messages.size).to eq(1)
      end

      include_examples 'iso-8859-15', ''
    end

    context 'and the default external encoding is US_ASCII' do
      around do |example|
        orig_encoding = Encoding.default_external
        Encoding.default_external = Encoding::US_ASCII
        example.run
        Encoding.default_external = orig_encoding
      end

      it 'does not crash on UTF-8 encoded non-ascii characters' do
        source = ['# encoding: UTF-8',
                  'class Epd::ReportsController < EpdAreaController',
                  "  'terecht bij uw ROM-coördinator.'",
                  'end'].join("\r\n")
        inspect_source_file(cop, source)
        expect(cop.offenses).to be_empty
      end

      include_examples 'iso-8859-15', ''
    end

    context 'and source is a string' do
      it 'registers an offense' do
        inspect_source(cop, "x=0\ny=1")

        expect(cop.messages).to eq(['Carriage return character missing.'])
      end
    end
  end

  context 'when EnforcedStyle is lf' do
    let(:cop_config) { { 'EnforcedStyle' => 'lf' } }
    include_examples 'all configurations'

    it 'registers an offense for CR+LF' do
      inspect_source_file(cop, ['x=0', '', "y=1\r"])
      expect(cop.messages).to eq(['Carriage return character detected.'])
      expect(cop.offenses.map(&:line)).to eq([3])
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

    context 'and there are many lines ending with CR+LF' do
      it 'registers only one offense' do
        inspect_source_file(cop, ['x=0', '', 'y=1'].join("\r\n"))
        expect(cop.messages.size).to eq(1)
      end

      include_examples 'iso-8859-15', "\r"
    end

    context 'and the default external encoding is US_ASCII' do
      around do |example|
        orig_encoding = Encoding.default_external
        Encoding.default_external = Encoding::US_ASCII
        example.run
        Encoding.default_external = orig_encoding
      end

      it 'does not crash on UTF-8 encoded non-ascii characters' do
        source = ['# encoding: UTF-8',
                  'class Epd::ReportsController < EpdAreaController',
                  "  'terecht bij uw ROM-coördinator.'",
                  'end'].join("\n")
        inspect_source_file(cop, source)
        expect(cop.offenses).to be_empty
      end

      include_examples 'iso-8859-15', "\r"
    end

    context 'and source is a string' do
      it 'registers an offense' do
        inspect_source(cop, "x=0\r")

        expect(cop.messages).to eq(['Carriage return character detected.'])
      end
    end
  end
end
