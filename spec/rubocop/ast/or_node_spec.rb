# frozen_string_literal: true

describe RuboCop::AST::OrNode do
  let(:or_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a logical or node' do
      let(:source) do
        ':foo || :bar'
      end

      it { expect(or_node).to be_a(described_class) }
    end

    context 'with a semantic or node' do
      let(:source) do
        ':foo or :bar'
      end

      it { expect(or_node).to be_a(described_class) }
    end
  end

  describe '#logical_operator?' do
    context 'with a logical or node' do
      let(:source) do
        ':foo || :bar'
      end

      it { expect(or_node).to be_logical_operator }
    end

    context 'with a semantic or node' do
      let(:source) do
        ':foo or :bar'
      end

      it { expect(or_node).not_to be_logical_operator }
    end
  end

  describe '#semantic_operator?' do
    context 'with a logical or node' do
      let(:source) do
        ':foo || :bar'
      end

      it { expect(or_node).not_to be_semantic_operator }
    end

    context 'with a semantic or node' do
      let(:source) do
        ':foo or :bar'
      end

      it { expect(or_node).to be_semantic_operator }
    end
  end

  describe '#operator' do
    context 'with a logical or node' do
      let(:source) do
        ':foo || :bar'
      end

      it { expect(or_node.operator).to eq('||') }
    end

    context 'with a semantic or node' do
      let(:source) do
        ':foo or :bar'
      end

      it { expect(or_node.operator).to eq('or') }
    end
  end

  describe '#alternate_operator' do
    context 'with a logical or node' do
      let(:source) do
        ':foo || :bar'
      end

      it { expect(or_node.alternate_operator).to eq('or') }
    end

    context 'with a semantic or node' do
      let(:source) do
        ':foo or :bar'
      end

      it { expect(or_node.alternate_operator).to eq('||') }
    end
  end

  describe '#inverse_operator' do
    context 'with a logical or node' do
      let(:source) do
        ':foo || :bar'
      end

      it { expect(or_node.inverse_operator).to eq('&&') }
    end

    context 'with a semantic or node' do
      let(:source) do
        ':foo or :bar'
      end

      it { expect(or_node.inverse_operator).to eq('and') }
    end
  end

  describe '#lhs' do
    context 'with a logical or node' do
      let(:source) do
        ':foo || 42'
      end

      it { expect(or_node.lhs).to be_sym_type }
    end

    context 'with a semantic or node' do
      let(:source) do
        ':foo or 42'
      end

      it { expect(or_node.lhs).to be_sym_type }
    end
  end

  describe '#rhs' do
    context 'with a logical or node' do
      let(:source) do
        ':foo || 42'
      end

      it { expect(or_node.rhs).to be_int_type }
    end

    context 'with a semantic or node' do
      let(:source) do
        ':foo or 42'
      end

      it { expect(or_node.rhs).to be_int_type }
    end
  end
end
