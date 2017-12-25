# frozen_string_literal: true

RSpec.describe RuboCop::AST::SymbolNode do
  let(:sym_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a symbol node' do
      let(:source) do
        ':foo'
      end

      it { expect(sym_node.is_a?(described_class)).to be(true) }
    end
  end

  describe '#value' do
    let(:source) do
      ':foo'
    end

    it { expect(sym_node.value).to eq(:foo) }
  end
end
