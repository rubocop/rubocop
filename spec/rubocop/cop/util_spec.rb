# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Util do
  describe '#line_range' do
    include ASTHelper

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

    let(:node) do
      target_node = scan_node(ast) do |node|
        break node if node.type == :class
      end
      fail 'No target node found!' unless target_node
      target_node
    end

    context 'when Source::Range object is passed' do
      it 'returns line range of that' do
        line_range = Rubocop::Cop::Util.line_range(node.loc.expression)
        expect(line_range).to eq(3..7)
      end
    end

    context 'when AST::Node object is passed' do
      it 'returns line range of the expression' do
        line_range = Rubocop::Cop::Util.line_range(node)
        expect(line_range).to eq(3..7)
      end
    end
  end
end
