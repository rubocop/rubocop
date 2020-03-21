# frozen_string_literal: true

RSpec.describe RuboCop::AST::ForwardArgsNode do
  let(:args_node) { parse_source(source).ast.arguments }

  context 'when using Ruby 2.7 or newer', :ruby27 do
    describe '.new' do
      let(:source) { 'def foo(...); end' }

      it { expect(args_node.is_a?(described_class)).to be(true) }
    end

    describe '#to_a' do
      let(:source) { 'def foo(...); end' }

      it { expect(args_node.to_a).to contain_exactly(args_node) }
    end
  end
end
