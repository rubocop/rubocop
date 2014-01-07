# encoding: utf-8
# rubocop:disable LineLength

require 'spec_helper'

describe Rubocop::Cop::Commissioner do
  describe '#investigate' do
    let(:cop) { double(Rubocop::Cop, offences: []).as_null_object }

    it 'returns all offences found by the cops' do
      allow(cop).to receive(:offences).and_return([1])

      commissioner = described_class.new([cop])
      source = []
      processed_source = parse_source(source)

      expect(commissioner.investigate(processed_source)).to eq [1]
    end

    context 'when a cop has no interest in the file' do
      it 'returns all offences except the ones of the cop' do
        cops = []
        cops << double('cop A', offences: %w(foo), relevant_file?: true)
        cops << double('cop B', offences: %w(bar), relevant_file?: false)
        cops << double('cop C', offences: %w(baz), relevant_file?: true)
        cops.each(&:as_null_object)

        commissioner = described_class.new(cops)
        source = []
        processed_source = parse_source(source)

        expect(commissioner.investigate(processed_source)).to eq %w(foo baz)
      end
    end

    it 'traverses the AST and invoke cops specific callbacks' do
      expect(cop).to receive(:on_def)

      commissioner = described_class.new([cop])
      source = ['def method', '1', 'end']
      processed_source = parse_source(source)

      commissioner.investigate(processed_source)
    end

    it 'passes the input params to all cops that implement their own #investigate method' do
      source = []
      processed_source = parse_source(source)
      expect(cop).to receive(:investigate).with(processed_source)

      commissioner = described_class.new([cop])

      commissioner.investigate(processed_source)
    end

    it 'stores all errors raised by the cops' do
      allow(cop).to receive(:on_def) { fail RuntimeError }

      commissioner = described_class.new([cop])
      source = ['def method', '1', 'end']
      processed_source = parse_source(source)

      commissioner.investigate(processed_source)

      expect(commissioner.errors[cop].size).to eq(1)
      expect(commissioner.errors[cop][0]).to be_instance_of(RuntimeError)
    end

    context 'when passed :raise_error option' do
      it 're-raises the exception received while processing' do
        allow(cop).to receive(:on_def) { fail RuntimeError }

        commissioner = described_class.new([cop], raise_error: true)
        source = ['def method', '1', 'end']
        processed_source = parse_source(source)

        expect do
          commissioner.investigate(processed_source)
        end.to raise_error(RuntimeError)
      end
    end
  end
end
