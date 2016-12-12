# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Util do
  class TestUtil
    include RuboCop::Cop::Util
  end

  describe '#line_range' do
    let(:source) do
      <<-END
        foo = 1
        bar = 2
        class Test
          def some_method
            do_something
          end
        end
        baz = 8
      END
    end

    let(:processed_source) { parse_source(source) }
    let(:ast) { processed_source.ast }

    let(:node) { ast.each_node.find(&:class_type?) }

    context 'when Source::Range object is passed' do
      it 'returns line range of that' do
        line_range = described_class.line_range(node.loc.expression)
        expect(line_range).to eq(3..7)
      end
    end

    context 'when AST::Node object is passed' do
      it 'returns line range of the expression' do
        line_range = described_class.line_range(node)
        expect(line_range).to eq(3..7)
      end
    end
  end

  describe 'source indicated by #range_with_surrounding_comma' do
    let(:source) { 'raise " ,Error, "' }
    let(:processed_source) { parse_source(source) }
    let(:input_range) do
      Parser::Source::Range.new(processed_source.buffer, 9, 14)
    end

    subject do
      obj = TestUtil.new
      obj.instance_exec(processed_source) { |src| @processed_source = src }
      r = obj.send(:range_with_surrounding_comma, input_range, side)
      processed_source.buffer.source[r.begin_pos...r.end_pos]
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
    let(:source) { 'f {  a(2) }' }
    let(:processed_source) { parse_source(source) }
    let(:input_range) do
      Parser::Source::Range.new(processed_source.buffer, 5, 9)
    end

    subject do
      obj = TestUtil.new
      obj.instance_exec(processed_source) { |src| @processed_source = src }
      r = obj.send(:range_with_surrounding_space, input_range, side)
      processed_source.buffer.source[r.begin_pos...r.end_pos]
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

  # Test compatibility with Range#size in Ruby 2.0.
  describe '#numeric_range_size' do
    if RUBY_VERSION >= '2'
      [1..1, 1...1, 1..2, 1...2, 1..3, 1...3, 1..-1, 1...-1].each do |range|
        context "with range #{range}" do
          subject { described_class.numeric_range_size(range) }
          it { is_expected.to eq(range.size) }
        end
      end
    end
  end

  describe '#to_supported_styles' do
    subject { RuboCop::Cop::Util.to_supported_styles(enforced_style) }

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
