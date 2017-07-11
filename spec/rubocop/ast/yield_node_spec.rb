# frozen_string_literal: true

describe RuboCop::AST::YieldNode do
  let(:yield_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) { 'yield :foo, :bar' }

    it { expect(yield_node).to be_a(described_class) }
  end

  describe '#receiver' do
    let(:source) { 'yield :foo, :bar' }

    it { expect(yield_node.receiver).to be_nil }
  end

  describe '#method_name' do
    let(:source) { 'yield :foo, :bar' }

    it { expect(yield_node.method_name).to eq(:yield) }
  end

  describe '#method?' do
    context 'when message matches' do
      context 'when argument is a symbol' do
        let(:source) { 'yield :foo' }

        it { expect(yield_node.method?(:yield)).to be_truthy }
      end

      context 'when argument is a string' do
        let(:source) { 'yield :foo' }

        it { expect(yield_node.method?('yield')).to be_truthy }
      end
    end

    context 'when message does not match' do
      context 'when argument is a symbol' do
        let(:source) { 'yield :bar' }

        it { expect(yield_node.method?(:foo)).to be_falsey }
      end

      context 'when argument is a string' do
        let(:source) { 'yield :bar' }

        it { expect(yield_node.method?('foo')).to be_falsey }
      end
    end
  end

  describe '#macro?' do
    let(:source) { 'yield :bar' }

    it { expect(yield_node.macro?).to be_falsey }
  end

  describe '#command?' do
    context 'when argument is a symbol' do
      let(:source) { 'yield :bar' }

      it { expect(yield_node.command?(:yield)).to be_truthy }
    end

    context 'when argument is a string' do
      let(:source) { 'yield :bar' }

      it { expect(yield_node.command?('yield')).to be_truthy }
    end
  end

  describe '#arguments' do
    context 'with no arguments' do
      let(:source) { 'yield' }

      it { expect(yield_node.arguments).to be_empty }
    end

    context 'with a single literal argument' do
      let(:source) { 'yield :foo' }

      it { expect(yield_node.arguments.size).to eq(1) }
    end

    context 'with a single splat argument' do
      let(:source) { 'yield *foo' }

      it { expect(yield_node.arguments.size).to eq(1) }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'yield :foo, :bar' }

      it { expect(yield_node.arguments.size).to eq(2) }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'yield :foo, *bar' }

      it { expect(yield_node.arguments.size).to eq(2) }
    end
  end

  describe '#first_argument' do
    context 'with no arguments' do
      let(:source) { 'yield' }

      it { expect(yield_node.first_argument).to be_nil }
    end

    context 'with a single literal argument' do
      let(:source) { 'yield :foo' }

      it { expect(yield_node.first_argument).to be_sym_type }
    end

    context 'with a single splat argument' do
      let(:source) { 'yield *foo' }

      it { expect(yield_node.first_argument).to be_splat_type }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'yield :foo, :bar' }

      it { expect(yield_node.first_argument).to be_sym_type }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'yield :foo, *bar' }

      it { expect(yield_node.first_argument).to be_sym_type }
    end
  end

  describe '#last_argument' do
    context 'with no arguments' do
      let(:source) { 'yield' }

      it { expect(yield_node.last_argument).to be_nil }
    end

    context 'with a single literal argument' do
      let(:source) { 'yield :foo' }

      it { expect(yield_node.last_argument).to be_sym_type }
    end

    context 'with a single splat argument' do
      let(:source) { 'yield *foo' }

      it { expect(yield_node.last_argument).to be_splat_type }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'yield :foo, :bar' }

      it { expect(yield_node.last_argument).to be_sym_type }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'yield :foo, *bar' }

      it { expect(yield_node.last_argument).to be_splat_type }
    end
  end

  describe '#arguments?' do
    context 'with no arguments' do
      let(:source) { 'yield' }

      it { expect(yield_node.arguments?).to be_falsey }
    end

    context 'with a single literal argument' do
      let(:source) { 'yield :foo' }

      it { expect(yield_node.arguments?).to be_truthy }
    end

    context 'with a single splat argument' do
      let(:source) { 'yield *foo' }

      it { expect(yield_node.arguments?).to be_truthy }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'yield :foo, :bar' }

      it { expect(yield_node.arguments?).to be_truthy }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'yield :foo, *bar' }

      it { expect(yield_node.arguments?).to be_truthy }
    end
  end

  describe '#parenthesized?' do
    context 'with no arguments' do
      context 'when not using parentheses' do
        let(:source) { 'yield' }

        it { expect(yield_node.parenthesized?).to be_falsey }
      end

      context 'when using parentheses' do
        let(:source) { 'yield()' }

        it { expect(yield_node.parenthesized?).to be_truthy }
      end
    end

    context 'with arguments' do
      context 'when not using parentheses' do
        let(:source) { 'yield :foo' }

        it { expect(yield_node.parenthesized?).to be_falsey }
      end

      context 'when using parentheses' do
        let(:source) { 'yield(:foo)' }

        it { expect(yield_node.parenthesized?).to be_truthy }
      end
    end
  end

  describe '#setter_method?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.setter_method?).to be_falsey }
  end

  describe '#operator_method?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.operator_method?).to be_falsey }
  end

  describe '#comparison_method?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.comparison_method?).to be_falsey }
  end

  describe '#assignment_method?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.assignment_method?).to be_falsey }
  end

  describe '#dot?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.dot?).to be_falsey }
  end

  describe '#double_colon?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.double_colon?).to be_falsey }
  end

  describe '#self_receiver?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.self_receiver?).to be_falsey }
  end

  describe '#const_receiver?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.const_receiver?).to be_falsey }
  end

  describe '#implicit_call?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.implicit_call?).to be_falsey }
  end

  describe '#predicate_method?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.predicate_method?).to be_falsey }
  end

  describe '#bang_method?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.bang_method?).to be_falsey }
  end

  describe '#camel_case_method?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.camel_case_method?).to be_falsey }
  end

  describe '#block_argument?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.block_argument?).to be_falsey }
  end

  describe '#block_literal?' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.block_literal?).to be_falsey }
  end

  describe '#block_node' do
    let(:source) { 'yield :foo' }

    it { expect(yield_node.block_node).to be_nil }
  end

  describe '#splat_argument?' do
    context 'with a splat argument' do
      let(:source) { 'yield *foo' }

      it { expect(yield_node.splat_argument?).to be_truthy }
    end

    context 'with no arguments' do
      let(:source) { 'yield' }

      it { expect(yield_node.splat_argument?).to be_falsey }
    end

    context 'with regular arguments' do
      let(:source) { 'yield :foo' }

      it { expect(yield_node.splat_argument?).to be_falsey }
    end

    context 'with mixed arguments' do
      let(:source) { 'yield :foo, *bar' }

      it { expect(yield_node.splat_argument?).to be_truthy }
    end
  end
end
