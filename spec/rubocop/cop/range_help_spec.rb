# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RangeHelp do
  before { stub_const('TestRangeHelp', klass) }

  let(:instance) do
    klass.new(processed_source: processed_source)
  end

  let(:klass) do
    Class.new do
      include RuboCop::Cop::RangeHelp

      def initialize(processed_source:)
        @processed_source = processed_source
      end
    end
  end

  let(:processed_source) do
    parse_source(source)
  end

  describe 'source indicated by #range_with_surrounding_comma' do
    subject do
      r = instance.send(:range_with_surrounding_comma, input_range, side)
      processed_source.buffer.source[r.begin_pos...r.end_pos]
    end

    let(:source) { 'raise " ,Error, "' }
    let(:input_range) { Parser::Source::Range.new(processed_source.buffer, 9, 14) }

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
    let(:source) { 'f {  a(2) }' }
    let(:input_range) { Parser::Source::Range.new(processed_source.buffer, 5, 9) }

    shared_examples 'works with various `side`s' do
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

    context 'when passing range as a kwarg' do
      subject do
        r = instance.send(:range_with_surrounding_space, range: input_range, side: side)
        processed_source.buffer.source[r.begin_pos...r.end_pos]
      end

      it_behaves_like 'works with various `side`s'
    end

    context 'when passing range as a positional argument' do
      subject do
        r = instance.send(:range_with_surrounding_space, input_range, side: side)
        processed_source.buffer.source[r.begin_pos...r.end_pos]
      end

      it_behaves_like 'works with various `side`s'
    end
  end

  describe 'source indicated by #range_by_whole_lines' do
    subject do
      r = output_range
      processed_source.buffer.source[r.begin_pos...r.end_pos]
    end

    let(:source) { <<~RUBY }
      puts 'example'
      puts 'another example'

      something_else
    RUBY

    # `input_source` defined in contexts
    let(:begin_pos) { source.index(input_source) }
    let(:end_pos) { begin_pos + input_source.length }
    let(:input_range) { Parser::Source::Range.new(processed_source.buffer, begin_pos, end_pos) }

    let(:output_range) do
      instance.send(
        :range_by_whole_lines,
        input_range,
        include_final_newline: include_final_newline
      )
    end

    shared_examples 'final newline behavior' do
      context 'without include_final_newline' do
        let(:include_final_newline) { false }

        it { is_expected.to eq(expected) }
      end

      context 'with include_final_newline' do
        let(:include_final_newline) { true }

        it { is_expected.to eq("#{expected}\n") }
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
        it { expect(output_range.end_pos).to eq(source.size) }
      end
    end
  end

  describe '#range_with_comments_and_lines' do
    subject(:result) do
      instance.send(:range_with_comments_and_lines, node)
    end

    def indent(string, amount)
      string.gsub(/^(?!$)/, ' ' * amount)
    end

    let(:node) do
      processed_source.ast.each_node(:def).to_a[1]
    end

    let(:source) do
      <<~RUBY
        class A
          # foo 1
          def foo
            # foo 2
          end

          # bar 1
          def bar
            # bar 2
          end

          # baz 1
          def baz
            # baz 2
          end
        end
      RUBY
    end

    it 'returns a range that includes related comments and whole lines' do
      expect(result.source).to eq(indent(<<~RUBY, 2))
        # bar 1
        def bar
          # bar 2
        end
      RUBY
    end
  end
end
