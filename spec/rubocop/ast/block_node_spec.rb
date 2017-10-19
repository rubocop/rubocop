# frozen_string_literal: true

describe RuboCop::AST::BlockNode do
  let(:block_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) { 'foo { |q| bar(q) }' }

    it { expect(block_node.is_a?(described_class)).to be(true) }
  end

  describe '#arguments' do
    context 'with no arguments' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.arguments.empty?).to be(true) }
    end

    context 'with a single literal argument' do
      let(:source) { 'foo { |q| bar(q) }' }

      it { expect(block_node.arguments.size).to eq(1) }
    end

    context 'with a single splat argument' do
      let(:source) { 'foo { |*q| bar(q) }' }

      it { expect(block_node.arguments.size).to eq(1) }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'foo { |q, *z| bar(q, z) }' }

      it { expect(block_node.arguments.size).to eq(2) }
    end
  end

  describe '#arguments?' do
    context 'with no arguments' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.arguments?).to be_falsey }
    end

    context 'with a single argument' do
      let(:source) { 'foo { |q| bar(q) }' }

      it { expect(block_node.arguments?).to be_truthy }
    end

    context 'with a single splat argument' do
      let(:source) { 'foo { |*q| bar(q) }' }

      it { expect(block_node.arguments?).to be_truthy }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'foo { |q, *z| bar(q, z) }' }

      it { expect(block_node.arguments?).to be_truthy }
    end
  end

  describe '#braces?' do
    context 'when enclosed in braces' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.braces?).to be_truthy }
    end

    context 'when enclosed in do-end keywords' do
      let(:source) do
        ['foo do',
         '  bar',
         'end'].join("\n")
      end

      it { expect(block_node.braces?).to be_falsey }
    end
  end

  describe '#keywords?' do
    context 'when enclosed in braces' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.keywords?).to be_falsey }
    end

    context 'when enclosed in do-end keywords' do
      let(:source) do
        ['foo do',
         '  bar',
         'end'].join("\n")
      end

      it { expect(block_node.keywords?).to be_truthy }
    end
  end

  describe '#lambda?' do
    context 'when block belongs to a stabby lambda' do
      let(:source) { '-> { bar }' }

      it { expect(block_node.lambda?).to be_truthy }
    end

    context 'when block belongs to a method lambda' do
      let(:source) { 'lambda { bar }' }

      it { expect(block_node.lambda?).to be_truthy }
    end

    context 'when block belongs to a non-lambda method' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.lambda?).to be_falsey }
    end
  end

  describe '#delimiters' do
    context 'when enclosed in braces' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.delimiters).to eq(%w[{ }]) }
    end

    context 'when enclosed in do-end keywords' do
      let(:source) do
        ['foo do',
         '  bar',
         'end'].join("\n")
      end

      it { expect(block_node.delimiters).to eq(%w[do end]) }
    end
  end

  describe '#opening_delimiter' do
    context 'when enclosed in braces' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.opening_delimiter).to eq('{') }
    end

    context 'when enclosed in do-end keywords' do
      let(:source) do
        ['foo do',
         '  bar',
         'end'].join("\n")
      end

      it { expect(block_node.opening_delimiter).to eq('do') }
    end
  end

  describe '#closing_delimiter' do
    context 'when enclosed in braces' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.closing_delimiter).to eq('}') }
    end

    context 'when enclosed in do-end keywords' do
      let(:source) do
        ['foo do',
         '  bar',
         'end'].join("\n")
      end

      it { expect(block_node.closing_delimiter).to eq('end') }
    end
  end

  describe '#single_line?' do
    context 'when block is on a single line' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.single_line?).to be_truthy }
    end

    context 'when block is on several lines' do
      let(:source) do
        ['foo do',
         '  bar',
         'end'].join("\n")
      end

      it { expect(block_node.single_line?).to be_falsey }
    end
  end

  describe '#multiline?' do
    context 'when block is on a single line' do
      let(:source) { 'foo { bar }' }

      it { expect(block_node.multiline?).to be_falsey }
    end

    context 'when block is on several lines' do
      let(:source) do
        ['foo do',
         '  bar',
         'end'].join("\n")
      end

      it { expect(block_node.multiline?).to be_truthy }
    end
  end

  describe '#void_context?' do
    context 'when block method is each' do
      let(:source) { 'each { bar }' }

      it { expect(block_node.void_context?).to be_truthy }
    end

    context 'when block method is not each' do
      let(:source) { 'map { bar }' }

      it { expect(block_node.void_context?).to be_falsey }
    end
  end
end
