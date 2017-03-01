# frozen_string_literal: true

describe RuboCop::AST::UntilNode do
  let(:until_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a statement until' do
      let(:source) { 'until foo; bar; end' }

      it { expect(until_node).to be_a(described_class) }
    end

    context 'with a modifier until' do
      let(:source) { 'begin foo; end until bar' }

      it { expect(until_node).to be_a(described_class) }
    end
  end

  describe '#keyword' do
    let(:source) { 'until foo; bar; end' }

    it { expect(until_node.keyword).to eq('until') }
  end

  describe '#inverse_keyword' do
    let(:source) { 'until foo; bar; end' }

    it { expect(until_node.inverse_keyword).to eq('while') }
  end

  describe '#do?' do
    context 'with a do keyword' do
      let(:source) { 'until foo do; bar; end' }

      it { expect(until_node.do?).to be_truthy }
    end

    context 'without a do keyword' do
      let(:source) { 'until foo; bar; end' }

      it { expect(until_node.do?).to be_falsey }
    end
  end
end
