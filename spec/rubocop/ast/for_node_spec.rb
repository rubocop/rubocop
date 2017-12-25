# frozen_string_literal: true

RSpec.describe RuboCop::AST::ForNode do
  let(:for_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) { 'for foo in bar; baz; end' }

    it { expect(for_node.is_a?(described_class)).to be(true) }
  end

  describe '#keyword' do
    let(:source) { 'for foo in bar; baz; end' }

    it { expect(for_node.keyword).to eq('for') }
  end

  describe '#do?' do
    context 'with a do keyword' do
      let(:source) { 'for foo in bar do baz; end' }

      it { expect(for_node.do?).to be_truthy }
    end

    context 'without a do keyword' do
      let(:source) { 'for foo in bar; baz; end' }

      it { expect(for_node.do?).to be_falsey }
    end
  end

  describe '#void_context?' do
    context 'with a do keyword' do
      let(:source) { 'for foo in bar do baz; end' }

      it { expect(for_node.void_context?).to be_truthy }
    end

    context 'without a do keyword' do
      let(:source) { 'for foo in bar; baz; end' }

      it { expect(for_node.void_context?).to be_truthy }
    end
  end

  describe '#variable' do
    let(:source) { 'for foo in :bar; :baz; end' }

    it { expect(for_node.variable.lvasgn_type?).to be(true) }
  end

  describe '#collection' do
    let(:source) { 'for foo in :bar; baz; end' }

    it { expect(for_node.collection.sym_type?).to be(true) }
  end

  describe '#body' do
    let(:source) { 'for foo in bar; :baz; end' }

    it { expect(for_node.body.sym_type?).to be(true) }
  end
end
