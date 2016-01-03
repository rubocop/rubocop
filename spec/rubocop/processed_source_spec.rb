# encoding: utf-8

require 'spec_helper'

describe RuboCop::ProcessedSource do
  include FileHelper

  subject(:processed_source) { described_class.new(source, nil, path) }

  let(:source) { <<-END.strip_indent }
    # encoding: utf-8
    def some_method
      puts 'foo'
    end
    some_method
  END

  let(:path) { 'path/to/file.rb' }

  describe '.from_file', :isolated_environment do
    describe 'when the file exists' do
      before do
        create_file(path, 'foo')
      end

      let(:processed_source) { described_class.from_file(path) }

      it 'returns an instance of ProcessedSource' do
        expect(processed_source).to be_a(described_class)
      end

      it "sets the file path to the instance's #path" do
        expect(processed_source.path).to eq(path)
      end

      it 'aborts when parsing raises an error' do
        allow_any_instance_of(described_class)
          .to receive(:parse).and_raise(
            Encoding::CompatibilityError.new('incompatible character encodings')
          )
        allow(described_class).to receive(:abort)
          .with(/incompatible character encodings/).once

        described_class.from_file(path)
      end
    end

    it 'aborts when the file does not exist' do
      allow(described_class).to receive(:abort)
        .with(/No such file or directory/).once

      described_class.from_file('foo')
    end
  end

  describe '#path' do
    it 'is the path passed to .new' do
      expect(processed_source.path).to eq(path)
    end
  end

  describe '#buffer' do
    it 'is a source buffer' do
      expect(processed_source.buffer).to be_a(Parser::Source::Buffer)
    end
  end

  describe '#ast' do
    it 'is the root node of AST' do
      expect(processed_source.ast).to be_a(Astrolabe::Node)
    end
  end

  describe '#comments' do
    it 'is an array of comments' do
      expect(processed_source.comments).to be_a(Array)
      expect(processed_source.comments.first).to be_a(Parser::Source::Comment)
    end
  end

  describe '#tokens' do
    it 'has an array of tokens' do
      expect(processed_source.tokens).to be_a(Array)
      expect(processed_source.tokens.first).to be_a(RuboCop::Token)
    end
  end

  shared_context 'invalid encoding source' do
    let(:source) do
      [
        '# encoding: utf-8',
        "# \xf9"
      ].join("\n")
    end
  end

  describe '#parser_error' do
    context 'when the source was properly parsed' do
      it 'is nil' do
        expect(processed_source.parser_error).to be_nil
      end
    end

    context 'when the source lacks encoding comment and is really utf-8 ' \
            'encoded but has been read as US-ASCII' do
      let(:source) do
        # When files are read into RuboCop, the encoding of source code lacking
        # an encoding comment will default to the external encoding, which
        # could for example be US-ASCII if the LC_ALL environment variable is
        # set to "C".
        '号码 = 3'.force_encoding('US-ASCII')
      end

      it 'is nil' do
        # ProcessedSource#parse sets UTF-8 as default encoding, so no error.
        expect(processed_source.parser_error).to be_nil
      end
    end

    context 'when the source could not be parsed due to encoding error' do
      include_context 'invalid encoding source'

      it 'returns the error' do
        expect(processed_source.parser_error).to be_a(Exception)
        expect(processed_source.parser_error.message)
          .to include('invalid byte sequence')
      end
    end
  end

  describe '#lines' do
    it 'is an array' do
      expect(processed_source.lines).to be_a(Array)
    end

    it 'has same number of elements as line count' do
      expect(processed_source.lines.size).to eq(5)
    end

    it 'contains lines as string without linefeed' do
      first_line = processed_source.lines.first
      expect(first_line).to eq('# encoding: utf-8')
    end
  end

  describe '#[]' do
    context 'when an index is passed' do
      it 'returns the line' do
        expect(processed_source[3]).to eq('end')
      end
    end

    context 'when a range is passed' do
      it 'returns the array of lines' do
        expect(processed_source[3..4]).to eq(%w(end some_method))
      end
    end

    context 'when start index and length are passed' do
      it 'returns the array of lines' do
        expect(processed_source[3, 2]).to eq(%w(end some_method))
      end
    end
  end

  describe 'valid_syntax?' do
    subject { processed_source.valid_syntax? }

    context 'when the source is completely valid' do
      let(:source) { 'def valid_code; end' }

      it 'returns true' do
        expect(processed_source.diagnostics).to be_empty
        expect(processed_source).to be_valid_syntax
      end
    end

    context 'when the source is invalid' do
      let(:source) { 'def invalid_code; en' }

      it 'returns false' do
        expect(processed_source).not_to be_valid_syntax
      end
    end

    context 'when the source is valid but has some warning diagnostics' do
      let(:source) { 'do_something *array' }

      it 'returns true' do
        expect(processed_source.diagnostics).not_to be_empty
        expect(processed_source.diagnostics.first.level).to eq(:warning)
        expect(processed_source).to be_valid_syntax
      end
    end

    context 'when the source could not be parsed due to encoding error' do
      include_context 'invalid encoding source'

      it 'returns false' do
        expect(processed_source).not_to be_valid_syntax
      end
    end

    context 'when a line starts with an integer literal' do
      let(:source) { '1 + 1' }

      # regression test
      it 'tokenizes the source correctly' do
        expect(processed_source.tokens[0].text).to eq '1'
      end
    end
  end
end
