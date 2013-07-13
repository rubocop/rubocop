# encoding: utf-8

require 'spec_helper'

module Rubocop
  describe SourceParser, :isolated_environment do
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

      it 'yields a source buffer to the passed block' do
        SourceParser.parse(file) do |buffer|
          expect(buffer).to be_a(Parser::Source::Buffer)
          buffer.read
        end
      end

      let (:return_values) do
        SourceParser.parse_file(file)
      end

      it 'returns the root node of AST as first return value' do
        node = return_values[0]
        expect(node).to be_a(Parser::AST::Node)
      end

      it 'returns an array of comments as second return value' do
        comments = return_values[1]
        expect(comments).to be_a(Array)
        expect(comments.first).to be_a(Parser::Source::Comment)
      end

      it 'returns an array of tokens as third return value' do
        tokens = return_values[2]
        expect(tokens).to be_a(Array)
        expect(tokens.first).to be_a(Cop::Token)
      end

      it 'returns the source buffer as fourth return value' do
        source_buffer = return_values[3]
        expect(source_buffer).to be_a(Parser::Source::Buffer)
      end

      it 'returns an array of source lines as fifth return value' do
        source_lines = return_values[4]
        expect(source_lines).to be_a(Array)
        expect(source_lines.first).to eq('# encoding: utf-8')
      end

      context 'when the source is valid' do
        it 'returns empty array as sixth return value' do
          diagnostics = return_values[5]
          expect(diagnostics).to be_a(Array)
          expect(diagnostics).to be_empty
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

        it 'returns an array of diagnostics as sixth return value' do
          diagnostics = return_values[5]
          expect(diagnostics).to be_a(Array)
          expect(diagnostics.first).to be_a(Parser::Diagnostic)
        end
      end
    end

    describe '.disabled_lines_in' do
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

      let(:disabled_lines) { SourceParser.disabled_lines_in(source) }

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
        all_cop_names = Cop::Cop.all.map(&:cop_name).sort
        expect(disabled_lines.keys.sort).to eq(all_cop_names)

        expected_part = (9..10).to_a

        disabled_lines.each_value do |each_cop_disabled_lines|
          expect(each_cop_disabled_lines & expected_part)
            .to eq(expected_part)
        end
      end
    end
  end
end
