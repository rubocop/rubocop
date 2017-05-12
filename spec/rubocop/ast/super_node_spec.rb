# frozen_string_literal: true

describe RuboCop::AST::SuperNode do
  let(:super_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a super node' do
      let(:source) { 'super(:baz)' }

      it { expect(super_node).to be_a(described_class) }
    end

    context 'with a zsuper node' do
      let(:source) { 'super' }

      it { expect(super_node).to be_a(described_class) }
    end
  end

  describe '#method_name' do
    let(:source) { 'super(foo)' }

    it { expect(super_node.method_name).to eq(:super) }
  end

  describe '#method?' do
    context 'when message matches' do
      context 'when argument is a symbol' do
        let(:source) { 'super(:baz)' }

        it { expect(super_node.method?(:super)).to be_truthy }
      end

      context 'when argument is a string' do
        let(:source) { 'super(:baz)' }

        it { expect(super_node.method?('super')).to be_truthy }
      end
    end

    context 'when message does not match' do
      context 'when argument is a symbol' do
        let(:source) { 'super(:baz)' }

        it { expect(super_node.method?(:foo)).to be_falsey }
      end

      context 'when argument is a string' do
        let(:source) { 'super(:baz)' }

        it { expect(super_node.method?('foo')).to be_falsey }
      end
    end
  end

  describe '#parenthesized?' do
    context 'with no arguments' do
      context 'when not using parentheses' do
        let(:source) { 'super' }

        it { expect(super_node.parenthesized?).to be_falsey }
      end

      context 'when using parentheses' do
        let(:source) { 'foo.bar()' }

        it { expect(super_node.parenthesized?).to be_truthy }
      end
    end

    context 'with arguments' do
      context 'when not using parentheses' do
        let(:source) { 'foo.bar :baz' }

        it { expect(super_node.parenthesized?).to be_falsey }
      end

      context 'when using parentheses' do
        let(:source) { 'foo.bar(:baz)' }

        it { expect(super_node.parenthesized?).to be_truthy }
      end
    end
  end
end
