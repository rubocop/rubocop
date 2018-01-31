# frozen_string_literal: true

RSpec.describe RuboCop::AST::InstanceVariableNode do
  let(:foo_node) { parse_source(source).ast.descendants[0] }
  let(:buzz_node) { parse_source(source).ast.descendants[5] }
  let(:source) do
    <<-RUBY.strip_indent
      @foo = 'bar'
      fred = 'flint'
      call_code(@buzz)
    RUBY
  end

  describe '.new' do
    it { expect(foo_node.is_a?(described_class)).to be true }
    it { expect(buzz_node.is_a?(described_class)).to be true }
  end

  describe '#identifier' do
    it { expect(foo_node.identifier).to eq(:@foo) }
    it { expect(buzz_node.identifier).to eq(:@buzz) }
  end

  describe '#name' do
    it { expect(foo_node.name).to eq('foo') }
    it { expect(buzz_node.name).to eq('buzz') }
  end

  describe '#node_parts' do
    it 'has all the pieces' do
      expect(foo_node.node_parts).to eq(
        [
          :@foo,
          RuboCop::AST::StrNode.new(:str, ['bar'])
        ]
      )
    end

    it { expect(buzz_node.node_parts).to eq([:@buzz]) }
  end

  context 'finds all instance variables' do
    subject { instance_variable_nodes.map(&:name) }

    let(:instance_variable_nodes) do
      parse_source(source).ast.each_descendant.select do |child|
        child.is_a?(described_class)
      end
    end

    it { is_expected.to eq %w[foo buzz] }
    it { is_expected.not_to include('fred') }
  end
end
