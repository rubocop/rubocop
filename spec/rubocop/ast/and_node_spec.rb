# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::AST::AndNode do
  let(:and_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node).to be_a(described_class) }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node).to be_a(described_class) }
    end
  end

  describe '#logical_operator?' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node).to be_logical_operator }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node).not_to be_logical_operator }
    end
  end

  describe '#semantic_operator?' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && :bar'
      end

      it { expect(and_node).not_to be_semantic_operator }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and :bar'
      end

      it { expect(and_node).to be_semantic_operator }
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

      it { expect(and_node.lhs).to be_sym_type }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and 42'
      end

      it { expect(and_node.lhs).to be_sym_type }
    end
  end

  describe '#rhs' do
    context 'with a logical and node' do
      let(:source) do
        ':foo && 42'
      end

      it { expect(and_node.rhs).to be_int_type }
    end

    context 'with a semantic and node' do
      let(:source) do
        ':foo and 42'
      end

      it { expect(and_node.rhs).to be_int_type }
    end
  end
end
