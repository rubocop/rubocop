# frozen_string_literal: true

RSpec.describe RuboCop::AST::AndNode do
  let(:and_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node.is_a?(described_class)).to be(true) }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node.is_a?(described_class)).to be(true) }
    end
  end

  describe '#logical_operator?' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node.logical_operator?).to be(true) }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node.logical_operator?).to be(false) }
    end
  end

  describe '#semantic_operator?' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node.semantic_operator?).to be(false) }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node.semantic_operator?).to be(true) }
    end
  end

  describe '#operator' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node.operator).to eq('&&') }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node.operator).to eq('and') }
    end
  end

  describe '#alternate_operator' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node.alternate_operator).to eq('and') }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node.alternate_operator).to eq('&&') }
    end
  end

  describe '#inverse_operator' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node.inverse_operator).to eq('||') }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node.inverse_operator).to eq('or') }
    end
  end

  describe '#lhs' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && 42'
      end

      it { expect(and_node.lhs.sym_type?).to be(true) }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and 42'
      end

      it { expect(and_node.lhs.sym_type?).to be(true) }
    end
  end

  describe '#rhs' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && 42'
      end

      it { expect(and_node.rhs.int_type?).to be(true) }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and 42'
      end

      it { expect(and_node.rhs.int_type?).to be(true) }
    end
  end
end
