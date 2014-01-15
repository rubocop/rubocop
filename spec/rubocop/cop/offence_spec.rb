# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Offence do
  let(:location) do
    source_buffer = Parser::Source::Buffer.new('test', 1)
    source_buffer.source = "a\n"
    Parser::Source::Range.new(source_buffer, 0, 1)
  end
  subject(:offence) do
    described_class.new(:convention, location, 'message', 'CopName', true)
  end

  it 'has a few required attributes' do
    expect(offence.severity).to eq(:convention)
    expect(offence.line).to eq(1)
    expect(offence.message).to eq('message')
    expect(offence.cop_name).to eq('CopName')
    expect(offence.corrected?).to be_true
  end

  it 'overrides #to_s' do
    expect(offence.to_s).to eq('C:  1:  1: message')
  end

  it 'does not blow up if a message contains %' do
    offence = described_class.new(:convention, location, 'message % test',
                                  'CopName')

    expect(offence.to_s).to eq('C:  1:  1: message % test')
  end

  it 'redefines == to compare offences based on their contents' do
    o1 = described_class.new(:convention, location, 'message', 'CopName')
    o2 = described_class.new(:convention, location, 'message', 'CopName')

    expect(o1 == o2).to be_true
  end

  it 'is frozen' do
    expect(offence).to be_frozen
  end

  [:severity, :location, :line, :column, :message, :cop_name].each do |a|
    describe "##{a}" do
      it 'is frozen' do
        expect(offence.send(a)).to be_frozen
      end
    end
  end

  context 'when unknown severity is passed' do
    it 'raises error' do
      expect do
        described_class.new(:foobar, location, 'message', 'CopName')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#severity_level' do
    subject(:severity_level) do
      described_class.new(severity, location, 'message', 'CopName')
        .severity_level
    end

    context 'when severity is :refactor' do
      let(:severity) { :refactor }
      it 'is 1' do
        expect(severity_level).to eq(1)
      end
    end

    context 'when severity is :fatal' do
      let(:severity) { :fatal }
      it 'is 5' do
        expect(severity_level).to eq(5)
      end
    end
  end

  describe '#<=>' do
    def offence(hash = {})
      attrs = {
        sev:  :convention,
        line: 5,
        col:  5,
        mes:  'message',
        cop:  'CopName'
      }.merge(hash)

      described_class.new(
        attrs[:sev],
        location(attrs[:line], attrs[:col],
                 %w(aaaaaa bbbbbb cccccc dddddd eeeeee ffffff)),
        attrs[:mes],
        attrs[:cop]
      )
    end

    def location(line, column, source)
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = source.join("\n")
      begin_pos = source[0...(line - 1)].reduce(0) do |a, e|
        a + e.length + "\n".length
      end + column
      Parser::Source::Range.new(source_buffer, begin_pos, begin_pos + 1)
    end

    # We want a nice table layout, so we allow space inside empty hashes.
    # rubocop:disable SpaceInsideHashLiteralBraces
    [
      [{                           }, {                           }, 0],

      [{ line: 6                   }, { line: 5                   }, 1],

      [{ line: 5, col: 6           }, { line: 5, col: 5           }, 1],
      [{ line: 6, col: 4           }, { line: 5, col: 5           }, 1],

      [{                  cop: 'B' }, {                  cop: 'A' }, 1],
      [{ line: 6,         cop: 'A' }, { line: 5,         cop: 'B' }, 1],
      [{          col: 6, cop: 'A' }, {          col: 5, cop: 'B' }, 1]
    ].each do |one, other, expectation|
      context "when receiver has #{one} and other has #{other}" do
        it "returns #{expectation}" do
          an_offence = offence(one)
          other_offence = offence(other)
          expect(an_offence <=> other_offence).to eq(expectation)
        end
      end
    end
  end
end
