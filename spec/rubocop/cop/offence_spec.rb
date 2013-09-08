# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Offence do
      let(:location) do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source_buffer.source = "a\n"
        Parser::Source::Range.new(source_buffer, 0, 1)
      end
      subject(:offence) do
        Offence.new(:convention, location, 'message', 'CopName')
      end

      it 'has a few required attributes' do
        expect(offence.severity).to eq(:convention)
        expect(offence.line).to eq(1)
        expect(offence.message).to eq('message')
        expect(offence.cop_name).to eq('CopName')
      end

      it 'overrides #to_s' do
        expect(offence.to_s).to eq('C:  1:  1: message')
      end

      it 'does not blow up if a message contains %' do
        offence = Offence.new(:convention, location, 'message % test',
                              'CopName')

        expect(offence.to_s).to eq('C:  1:  1: message % test')
      end

      it 'redefines == to compare offences based on their contents' do
        o1 = Offence.new(:convention, location, 'message', 'CopName')
        o2 = Offence.new(:convention, location, 'message', 'CopName')

        expect(o1 == o2).to be_true
      end

      it 'is frozen' do
        expect(offence).to be_frozen
      end

      describe '.from_diagnostic' do
        subject(:offence) { Offence.from_diagnostic(diagnostic) }
        let(:diagnostic) { Parser::Diagnostic.new(level, message, location) }
        let(:level) { :warning }
        let(:message) { 'This is a message' }
        let(:location) { double('location').as_null_object }

        it 'returns an offence' do
          expect(offence).to be_a(Offence)
        end

        it "sets diagnostic's level to offence's severity" do
          expect(offence.severity).to eq(level)
        end

        it "sets diagnostic's message to offence's message" do
          expect(offence.message).to eq(message)
        end

        it "sets diagnostic's location to offence's location" do
          expect(offence.location).to eq(location)
        end

        it 'sets Sytanx as cop name' do
          expect(offence.cop_name).to eq('Syntax')
        end
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
            Offence.new(:foobar, location, 'message', 'CopName')
          end.to raise_error(ArgumentError)
        end
      end

      describe '#severity_level' do
        subject(:severity_level) do
          Offence.new(severity, location, 'message', 'CopName').severity_level
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

          Offence.new(
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

        [
          [{                           }, {                           }, 0],

          [{ line: 6                   }, { line: 5                   }, 1],

          [{ line: 5, col: 6           }, { line: 5, col: 5           }, 1],
          [{ line: 6, col: 4           }, { line: 5, col: 5           }, 1],

          [{                  cop: 'B' }, {                  cop: 'A' }, 1],
          [{ line: 6,         cop: 'A' }, { line: 5,         cop: 'B' }, 1],
          [{          col: 6, cop: 'A' }, {          col: 5, cop: 'B' }, 1],
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
  end
end
