# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Util do
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

    let(:ast) do
      processed_source = parse_source(source)
      processed_source.ast
    end

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

  # Test compatibility with Range#size in Ruby 2.0.
  describe '#numeric_range_size', ruby: 2 do
    [1..1, 1...1, 1..2, 1...2, 1..3, 1...3, 1..-1, 1...-1].each do |range|
      context "with range #{range}" do
        subject { described_class.numeric_range_size(range) }
        it { should eq(range.size) }
      end
    end
  end
end
