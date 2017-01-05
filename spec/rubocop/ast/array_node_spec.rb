# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::AST::ArrayNode do
  let(:array_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) { '[]' }

    it { expect(array_node).to be_a(described_class) }
  end

  describe '#values' do
    context 'with an empty array' do
      let(:source) { '[]' }

      it { expect(array_node.values).to be_empty }
    end

    context 'with an array of literals' do
      let(:source) { '[1, 2, 3]' }

      it { expect(array_node.values.size).to eq(3) }
      it { expect(array_node.values).to all(be_literal) }
    end

    context 'with an array of variables' do
      let(:source) { '[foo, bar]' }

      it { expect(array_node.values.size).to eq(2) }
      it { expect(array_node.values).to all(be_send_type) }
    end
  end

  describe '#square_brackets?' do
    context 'with square brackets' do
      let(:source) { '[1, 2, 3]' }

      it { expect(array_node.square_brackets?).to be_truthy }
    end

    context 'with a percent literal' do
      let(:source) { '%w(foo bar)' }

      it { expect(array_node.square_brackets?).to be_falsey }
    end
  end

  describe '#percent_literal?' do
    context 'with square brackets' do
      let(:source) { '[1, 2, 3]' }

      it { expect(array_node.percent_literal?).to be_falsey }
      it { expect(array_node.percent_literal?(:string)).to be_falsey }
      it { expect(array_node.percent_literal?(:symbol)).to be_falsey }
    end

    context 'with a string percent literal' do
      let(:source) { '%w(foo bar)' }

      it { expect(array_node.percent_literal?).to be_truthy }
      it { expect(array_node.percent_literal?(:string)).to be_truthy }
      it { expect(array_node.percent_literal?(:symbol)).to be_falsey }
    end

    context 'with a symbol percent literal' do
      let(:source) { '%i(foo bar)' }

      it { expect(array_node.percent_literal?).to be_truthy }
      it { expect(array_node.percent_literal?(:string)).to be_falsey }
      it { expect(array_node.percent_literal?(:symbol)).to be_truthy }
    end
  end
end
