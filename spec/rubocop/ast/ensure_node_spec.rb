# frozen_string_literal: true

describe RuboCop::AST::EnsureNode do
  let(:ensure_node) { parse_source(source).ast.children.first }

  describe '.new' do
    let(:source) { 'begin; beginbody; ensure; ensurebody; end' }

    it { expect(ensure_node.is_a?(described_class)).to be(true) }
  end

  describe '#body' do
    let(:source) { 'begin; beginbody; ensure; :ensurebody; end' }

    it { expect(ensure_node.body.sym_type?).to be(true) }
  end
end
