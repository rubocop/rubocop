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

  describe '.cop_disabled_lines_in' do
    let(:source) do
      [
        '# encoding: utf-8',
        '',
        '# rubocop:disable MethodLength',
        'def some_method',
        "  puts 'foo'",
        'end',
        '# rubocop:enable MethodLength',
        '',
        '# rubocop:disable all',
        'some_method',
        '# rubocop:enable all',
        '',
        "code = 'This is evil.'",
        'eval(code) # rubocop:disable Eval',
        "puts 'This is not evil.'"
      ]
    end

    let(:disabled_lines) { described_class.cop_disabled_lines_in(source) }

    it 'has keys for disabled cops' do
      expect(disabled_lines).to have_key('MethodLength')
      expect(disabled_lines).to have_key('Eval')
    end

    it 'supports disabling multiple lines with a pair of directive' do
      method_length_disabled_lines = disabled_lines['MethodLength']
      expected_part = (3..6).to_a
      expect(method_length_disabled_lines & expected_part)
        .to eq(expected_part)
    end

    it 'supports disabling single line with a direcive at end of line' do
      eval_disabled_lines = disabled_lines['Eval']
      expect(eval_disabled_lines).to include(14)
      expect(eval_disabled_lines).not_to include(15)
    end

    it 'supports disabling all cops with keyword all' do
      all_cop_names = Rubocop::Cop::Cop.all.map(&:cop_name).sort
      expect(disabled_lines.keys.sort).to eq(all_cop_names)

      expected_part = (9..10).to_a

      disabled_lines.each_value do |each_cop_disabled_lines|
        expect(each_cop_disabled_lines & expected_part)
          .to eq(expected_part)
      end
    end
  end
end
