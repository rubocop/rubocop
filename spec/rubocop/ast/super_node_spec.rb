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

  describe '#block_argument?' do
    context 'with a block argument' do
      let(:source) { 'super(&baz)' }

      it { expect(super_node.block_argument?).to be_truthy }
    end

    context 'with no arguments' do
      let(:source) { 'super' }

      it { expect(super_node.block_argument?).to be_falsey }
    end

    context 'with regular arguments' do
      let(:source) { 'super(:baz)' }

      it { expect(super_node.block_argument?).to be_falsey }
    end

    context 'with mixed arguments' do
      let(:source) { 'super(:baz, &qux)' }

      it { expect(super_node.block_argument?).to be_truthy }
    end
  end

  describe '#block_literal?' do
    context 'with a block literal' do
      let(:super_node) { parse_source(source).ast.children[0] }

      let(:source) { 'super { |q| baz(q) }' }

      it { expect(super_node.block_literal?).to be_truthy }
    end

    context 'with a block argument' do
      let(:source) { 'super(&baz)' }

      it { expect(super_node.block_literal?).to be_falsey }
    end

    context 'with no block' do
      let(:source) { 'super' }

      it { expect(super_node.block_literal?).to be_falsey }
    end
  end

  describe '#block_node' do
    context 'with a block literal' do
      let(:super_node) { parse_source(source).ast.children[0] }

      let(:source) { 'super { |q| baz(q) }' }

      it { expect(super_node.block_node).to be_block_type }
    end

    context 'with a block argument' do
      let(:source) { 'super(&baz)' }

      it { expect(super_node.block_node).to be_nil }
    end

    context 'with no block' do
      let(:source) { 'super' }

      it { expect(super_node.block_node).to be_nil }
    end
  end

  describe '#arguments' do
    context 'with no arguments' do
      let(:source) { 'super' }

      it { expect(super_node.arguments).to be_empty }
    end

    context 'with a single literal argument' do
      let(:source) { 'super(:baz)' }

      it { expect(super_node.arguments.size).to eq(1) }
    end

    context 'with a single splat argument' do
      let(:source) { 'super(*baz)' }

      it { expect(super_node.arguments.size).to eq(1) }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'super(:baz, :qux)' }

      it { expect(super_node.arguments.size).to eq(2) }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'super(:baz, *qux)' }

      it { expect(super_node.arguments.size).to eq(2) }
    end
  end

  describe '#first_argument' do
    context 'with no arguments' do
      let(:source) { 'super' }

      it { expect(super_node.first_argument).to be_nil }
    end

    context 'with a single literal argument' do
      let(:source) { 'super(:baz)' }

      it { expect(super_node.first_argument).to be_sym_type }
    end

    context 'with a single splat argument' do
      let(:source) { 'super(*baz)' }

      it { expect(super_node.first_argument).to be_splat_type }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'super(:baz, :qux)' }

      it { expect(super_node.first_argument).to be_sym_type }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'superr(:baz, *qux)' }

      it { expect(super_node.first_argument).to be_sym_type }
    end
  end

  describe '#last_argument' do
    context 'with no arguments' do
      let(:source) { 'super' }

      it { expect(super_node.last_argument).to be_nil }
    end

    context 'with a single literal argument' do
      let(:source) { 'super(:baz)' }

      it { expect(super_node.last_argument).to be_sym_type }
    end

    context 'with a single splat argument' do
      let(:source) { 'super(*baz)' }

      it { expect(super_node.last_argument).to be_splat_type }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'super(:baz, :qux)' }

      it { expect(super_node.last_argument).to be_sym_type }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'super(:baz, *qux)' }

      it { expect(super_node.last_argument).to be_splat_type }
    end
  end

  describe '#arguments?' do
    context 'with no arguments' do
      let(:source) { 'super' }

      it { expect(super_node.arguments?).to be_falsey }
    end

    context 'with a single literal argument' do
      let(:source) { 'super(:baz)' }

      it { expect(super_node.arguments?).to be_truthy }
    end

    context 'with a single splat argument' do
      let(:source) { 'super(*baz)' }

      it { expect(super_node.arguments?).to be_truthy }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'super(:baz, :qux)' }

      it { expect(super_node.arguments?).to be_truthy }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'super(:baz, *qux)' }

      it { expect(super_node.arguments?).to be_truthy }
    end
  end

  describe '#splat_argument?' do
    context 'with a splat argument' do
      let(:source) { 'super(*baz)' }

      it { expect(super_node.splat_argument?).to be_truthy }
    end

    context 'with no arguments' do
      let(:source) { 'super' }

      it { expect(super_node.splat_argument?).to be_falsey }
    end

    context 'with regular arguments' do
      let(:source) { 'super(:baz)' }

      it { expect(super_node.splat_argument?).to be_falsey }
    end

    context 'with mixed arguments' do
      let(:source) { 'super(:baz, *qux)' }

      it { expect(super_node.splat_argument?).to be_truthy }
    end
  end
end
