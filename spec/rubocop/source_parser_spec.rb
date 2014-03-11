# encoding: utf-8

require 'spec_helper'

describe Rubocop::SourceParser, :isolated_environment do
  include FileHelper

  describe '.parse_file' do
    let(:file) { 'example.rb' }

    let(:source) do
      [
        '# encoding: utf-8',
        '',
        'def some_method',
        "  puts 'foo'",
        'end',
        '',
        'some_method'
      ]
    end

    before do
      create_file(file, source)
    end

    let(:processed_source) do
      described_class.parse_file(file)
    end

    it 'returns ProcessedSource' do
      expect(processed_source).to be_a(Rubocop::ProcessedSource)
    end

    describe 'the returned processed source' do
      it 'has the root node of AST' do
        expect(processed_source.ast).to be_a(Parser::AST::Node)
      end

      it 'has an array of comments' do
        expect(processed_source.comments).to be_a(Array)
        expect(processed_source.comments.first)
          .to be_a(Parser::Source::Comment)
      end

      it 'has an array of tokens' do
        expect(processed_source.tokens).to be_a(Array)
        expect(processed_source.tokens.first).to be_a(Rubocop::Token)
      end

      it 'has a source buffer' do
        expect(processed_source.buffer).to be_a(Parser::Source::Buffer)
      end

      context 'when the source is valid' do
        it 'does not have diagnostics' do
          expect(processed_source.diagnostics).to be_a(Array)
          expect(processed_source.diagnostics).to be_empty
        end
      end

      context 'when the source has invalid syntax' do
        let(:source) do
          [
            '# encoding: utf-8',
            '',
            'def some_method',
            "  puts 'foo'",
            'end',
            '',
            'some_method',
            '',
            '?invalid_syntax'
          ]
        end

        it 'has an array of diagnostics' do
          expect(processed_source.diagnostics).to be_a(Array)
          expect(processed_source.diagnostics.first)
            .to be_a(Parser::Diagnostic)
        end
      end
    end
  end
end
