# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::AST::HashNode do
  let(:hash_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) { '{}' }

    it { expect(hash_node).to be_a(described_class) }
  end

  describe '#pairs' do
    context 'with an empty hash' do
      let(:source) { '{}' }

      it { expect(hash_node.pairs).to be_empty }
    end

    context 'with a hash of literals' do
      let(:source) { '{ a: 1, b: 2, c: 3 }' }

      it { expect(hash_node.pairs.size).to eq(3) }
      it { expect(hash_node.pairs).to all(be_pair_type) }
    end

    context 'with a hash of variables' do
      let(:source) { '{ a: foo, b: bar }' }

      it { expect(hash_node.pairs.size).to eq(2) }
      it { expect(hash_node.pairs).to all(be_pair_type) }
    end
  end

  describe '#keys' do
    context 'with an empty hash' do
      let(:source) { '{}' }

      it { expect(hash_node.keys).to be_empty }
    end

    context 'with a hash with symbol keys' do
      let(:source) { '{ a: 1, b: 2, c: 3 }' }

      it { expect(hash_node.keys.size).to eq(3) }
      it { expect(hash_node.keys).to all(be_sym_type) }
    end

    context 'with a hash with string keys' do
      let(:source) { "{ 'a' => foo,'b' => bar }" }

      it { expect(hash_node.keys.size).to eq(2) }
      it { expect(hash_node.keys).to all(be_str_type) }
    end
  end

  describe '#keys' do
    context 'with an empty hash' do
      let(:source) { '{}' }

      it { expect(hash_node.values).to be_empty }
    end

    context 'with a hash with literal values' do
      let(:source) { '{ a: 1, b: 2, c: 3 }' }

      it { expect(hash_node.values.size).to eq(3) }
      it { expect(hash_node.values).to all(be_literal) }
    end

    context 'with a hash with string keys' do
      let(:source) { '{ a: foo, b: bar }' }

      it { expect(hash_node.values.size).to eq(2) }
      it { expect(hash_node.values).to all(be_send_type) }
    end
  end

  describe '#each_pair' do
    let(:source) { '{ a: 1, b: 2, c: 3 }' }

    context 'when not passed a block' do
      it { expect(hash_node.each_pair).to be_an(Enumerator) }
    end

    context 'when passed a block' do
      let(:expected) do
        [
          [*hash_node.pairs[0]],
          [*hash_node.pairs[1]],
          [*hash_node.pairs[2]]
        ]
      end

      it 'yields all the pairs' do
        expect { |b| hash_node.each_pair(&b) }
          .to yield_successive_args(*expected)
      end
    end
  end

  describe '#pairs_on_same_line?' do
    context 'with all pairs on the same line' do
      let(:source) { '{ a: 1, b: 2 }' }

      it { expect(hash_node.pairs_on_same_line?).to be_truthy }
    end

    context 'with no pairs on the same line' do
      let(:source) do
        ['{ a: 1,',
         ' b: 2 }'].join("\n")
      end

      it { expect(hash_node.pairs_on_same_line?).to be_falsey }
    end

    context 'with some pairs on the same line' do
      let(:source) do
        ['{ a: 1,',
         ' b: 2, c: 3 }'].join("\n")
      end

      it { expect(hash_node.pairs_on_same_line?).to be_truthy }
    end
  end

  describe '#braces?' do
    context 'with braces' do
      let(:source) { '{ a: 1, b: 2 }' }

      it { expect(hash_node.braces?).to be_truthy }
    end

    context 'as an argument with no braces' do
      let(:source) { 'foo(:bar, a: 1, b: 2)' }

      let(:hash_argument) { hash_node.children.last }

      it { expect(hash_argument.braces?).to be_falsey }
    end

    context 'as an argument with braces' do
      let(:source) { 'foo(:bar, { a: 1, b: 2 })' }

      let(:hash_argument) { hash_node.children.last }

      it { expect(hash_argument.braces?).to be_truthy }
    end
  end
end
