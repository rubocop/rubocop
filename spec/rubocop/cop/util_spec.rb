# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Util do
  class TestUtil
    include RuboCop::Cop::Util
  end

  describe '#line_range' do
    let(:source) do
      <<-RUBY
        foo = 1
        bar = 2
        class Test
          def some_method
            do_something
          end
        end
        baz = 8
      RUBY
    end

    let(:processed_source) { parse_source(source) }
    let(:ast) { processed_source.ast }

    let(:node) { ast.each_node.find(&:class_type?) }

    it 'returns line range of the expression' do
      line_range = described_class.line_range(node)
      expect(line_range).to eq(3..7)
    end
  end

  describe 'source indicated by #range_with_surrounding_comma' do
    subject do
      obj = TestUtil.new
      obj.instance_exec(processed_source) { |src| @processed_source = src }
      r = obj.send(:range_with_surrounding_comma, input_range, side)
      processed_source.buffer.source[r.begin_pos...r.end_pos]
    end

    let(:source) { 'raise " ,Error, "' }
    let(:processed_source) { parse_source(source) }
    let(:input_range) do
      Parser::Source::Range.new(processed_source.buffer, 9, 14)
    end

    context 'when side is :both' do
      let(:side) { :both }

      it { is_expected.to eq(',Error,') }
    end

    context 'when side is :left' do
      let(:side) { :left }

      it { is_expected.to eq(',Error') }
    end

    context 'when side is :right' do
      let(:side) { :right }

      it { is_expected.to eq('Error,') }
    end
  end

  describe 'source indicated by #range_with_surrounding_space' do
    subject do
      obj = TestUtil.new
      obj.instance_exec(processed_source) { |src| @processed_source = src }
      r = obj.send(:range_with_surrounding_space, range: input_range,
                                                  side: side)
      processed_source.buffer.source[r.begin_pos...r.end_pos]
    end

    let(:source) { 'f {  a(2) }' }
    let(:processed_source) { parse_source(source) }
    let(:input_range) do
      Parser::Source::Range.new(processed_source.buffer, 5, 9)
    end

    context 'when side is :both' do
      let(:side) { :both }

      it { is_expected.to eq('  a(2) ') }
    end

    context 'when side is :left' do
      let(:side) { :left }

      it { is_expected.to eq('  a(2)') }
    end

    context 'when side is :right' do
      let(:side) { :right }

      it { is_expected.to eq('a(2) ') }
    end
  end

  describe 'source indicated by #range_by_whole_lines' do
    subject do
      r = output_range
      processed_source.buffer.source[r.begin_pos...r.end_pos]
    end

    let(:source) { <<-RUBY.strip_indent }
      puts 'example'
      puts 'another example'

      something_else
    RUBY
    let(:processed_source) { parse_source(source) }

    # `input_source` defined in contexts
    let(:begin_pos) { source.index(input_source) }
    let(:end_pos) { begin_pos + input_source.length }
    let(:input_range) do
      Parser::Source::Range.new(processed_source.buffer, begin_pos, end_pos)
    end

    let(:output_range) do
      obj = TestUtil.new
      obj.instance_exec(processed_source) { |src| @processed_source = src }
      obj.send(:range_by_whole_lines,
               input_range,
               include_final_newline: include_final_newline)
    end

    shared_examples 'final newline behavior' do
      context 'without include_final_newline' do
        let(:include_final_newline) { false }

        it { is_expected.to eq(expected) }
      end

      context 'with include_final_newline' do
        let(:include_final_newline) { true }

        it { is_expected.to eq(expected + "\n") }
      end
    end

    context 'when part of a single line is selected' do
      let(:input_source) { "'example'" }
      let(:expected) { "puts 'example'" }

      include_examples 'final newline behavior'
    end

    context 'with a whole line except newline selected' do
      let(:input_source) { "puts 'example'" }
      let(:expected) { "puts 'example'" }

      include_examples 'final newline behavior'
    end

    context 'with a whole line plus beginning of next line' do
      let(:input_source) { "puts 'example'\n" }
      let(:expected) { "puts 'example'\nputs 'another example'" }

      include_examples 'final newline behavior'
    end

    context 'with end of one line' do
      let(:begin_pos) { 14 }
      let(:end_pos) { 14 }
      let(:expected) { "puts 'example'" }

      include_examples 'final newline behavior'
    end

    context 'with beginning of one line' do
      let(:begin_pos) { 15 }
      let(:end_pos) { 15 }
      let(:expected) { "puts 'another example'" }

      include_examples 'final newline behavior'
    end

    context 'with parts of two lines' do
      let(:input_source) { "'example'\nputs 'another" }
      let(:expected) { "puts 'example'\nputs 'another example'" }

      include_examples 'final newline behavior'
    end

    context 'with parts of four lines' do
      let(:input_source) { "'example'\nputs 'another example'\n\nso" }
      let(:expected) { source.chomp }

      include_examples 'final newline behavior'
    end

    context "when source doesn't end with a newline" do
      let(:source) { "example\nwith\nno\nnewline_at_end" }
      let(:input_source) { 'line_at_e' }

      context 'without include_final_newline' do
        let(:include_final_newline) { false }

        it { is_expected.to eq('newline_at_end') }
      end

      context 'with include_final_newline' do
        let(:include_final_newline) { true }

        it { is_expected.to eq('newline_at_end') }
      end
    end
  end

  describe '#to_symbol_literal' do
    [
      ['foo', ':foo'],
      ['foo?', ':foo?'],
      ['foo!', ':foo!'],
      ['@foo', ':@foo'],
      ['@@foo', ':@@foo'],
      ['$\\', ':$\\'],
      ['$a', ':$a'],
      ['==', ':=='],
      ['a-b', ":'a-b'"]
    ].each do |string, expectation|
      context "when #{string}" do
        it "returns #{expectation}" do
          expect(described_class.to_symbol_literal(string)).to eq(expectation)
        end
      end
    end
  end

  describe '#to_supported_styles' do
    subject { described_class.to_supported_styles(enforced_style) }

    context 'when EnforcedStyle' do
      let(:enforced_style) { 'EnforcedStyle' }

      it { is_expected.to eq('SupportedStyles') }
    end

    context 'when EnforcedStyleInsidePipes' do
      let(:enforced_style) { 'EnforcedStyleInsidePipes' }

      it { is_expected.to eq('SupportedStylesInsidePipes') }
    end
  end
end
