# frozen_string_literal: true

RSpec.describe RuboCop::AST::DefinedNode do
  let(:defined_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a defined? node' do
      let(:source) { 'defined? :foo' }

      it { expect(defined_node.is_a?(described_class)).to be(true) }
    end
  end

  describe '#receiver' do
    let(:source) { 'defined? :foo' }

    it { expect(defined_node.receiver).to eq(nil) }
  end

  describe '#method_name' do
    let(:source) { 'defined? :foo' }

    it { expect(defined_node.method_name).to eq(:defined?) }
  end

  describe '#arguments' do
    let(:source) { 'defined? :foo' }

    it { expect(defined_node.arguments.size).to eq(1) }
    it { expect(defined_node.arguments).to all(be_sym_type) }
  end
end
