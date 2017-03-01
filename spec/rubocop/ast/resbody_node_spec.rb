# frozen_string_literal: true

describe RuboCop::AST::ResbodyNode do
  let(:resbody_node) do
    begin_node = parse_source(source).ast
    rescue_node, = *begin_node
    rescue_node.children[1]
  end

  describe '.new' do
    let(:source) { 'begin; beginbody; rescue; rescuebody; end' }

    it { expect(resbody_node).to be_a(described_class) }
  end

  describe '#body' do
    let(:source) { 'begin; beginbody; rescue Error => ex; :rescuebody; end' }

    it { expect(resbody_node.body).to be_sym_type }
  end
end
