# encoding: utf-8

require 'spec_helper'

describe Rubocop::ProcessedSource do
  subject(:processed_source) do
    described_class.new(
      buffer,
      double('ast'),
      double('comments'),
      double('tokens'),
      diagnostics
    )
  end

  let(:diagnostics) { double('diagnostics') }

  let(:source) do
    [
      'def some_method',
      "  puts 'foo'",
      'end',
      'some_method'
    ].join("\n")
  end

  let(:buffer) do
    buffer = Parser::Source::Buffer.new('(string)', 1)
    buffer.source = source
    buffer
  end

  describe '#lines' do
    it 'is an array' do
      expect(processed_source.lines).to be_a(Array)
    end

    it 'has same number of elements as line count' do
      expect(processed_source.lines.size).to eq(4)
    end

    it 'contains lines as string without linefeed' do
      first_line = processed_source.lines.first
      expect(first_line).to eq('def some_method')
    end
  end

  describe '#[]' do
    context 'when an index is passed' do
      it 'returns the line' do
        expect(processed_source[2]).to eq('end')
      end
    end

    context 'when a range is passed' do
      it 'returns the array of lines' do
        expect(processed_source[2..3]).to eq(%w(end some_method))
      end
    end

    context 'when start index and length are passed' do
      it 'returns the array of lines' do
        expect(processed_source[2, 2]).to eq(%w(end some_method))
      end
    end
  end

  describe 'valid_syntax?' do
    def create_diagnostics(level)
      Parser::Diagnostic.new(level, :odd_hash, [], double('location'))
    end

    let(:diagnostics) do
      [create_diagnostics(level)]
    end

    context 'when the source has diagnostic with error level' do
      let(:level) { :error }

      it 'returns false' do
        expect(processed_source.valid_syntax?).to be_false
      end
    end

    context 'when the source has diagnostic with fatal level' do
      let(:level) { :fatal }

      it 'returns false' do
        expect(processed_source.valid_syntax?).to be_false
      end
    end

    context 'when the source has diagnostic with warning level' do
      let(:level) { :warning }

      it 'returns true' do
        expect(processed_source.valid_syntax?).to be_true
      end
    end

    context 'when the source has diagnostics with error and warning level' do
      let(:diagnostics) do
        [
          create_diagnostics(:error),
          create_diagnostics(:warning)
        ]
      end

      it 'returns false' do
        expect(processed_source.valid_syntax?).to be_false
      end
    end
  end
end
