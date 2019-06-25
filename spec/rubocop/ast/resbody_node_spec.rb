# frozen_string_literal: true

RSpec.describe RuboCop::AST::ResbodyNode do
  let(:resbody_node) do
    begin_node = parse_source(source).ast
    rescue_node, = *begin_node
    rescue_node.children[1]
  end

  describe '.new' do
    let(:source) { 'begin; beginbody; rescue; rescuebody; end' }

    it { expect(resbody_node.is_a?(described_class)).to be(true) }
  end

  describe '#exception_variable' do
    context 'for an explicit rescue' do
      let(:source) { 'begin; beginbody; rescue Error => ex; rescuebody; end' }

      it { expect(resbody_node.exception_variable.source).to eq('ex') }
    end

    context 'for an implicit rescue' do
      let(:source) { 'begin; beginbody; rescue => ex; rescuebody; end' }

      it { expect(resbody_node.exception_variable.source).to eq('ex') }
    end

    context 'when an exception variable is not given' do
      let(:source) { 'begin; beginbody; rescue; rescuebody; end' }

      it { expect(resbody_node.exception_variable).to be(nil) }
    end
  end

  describe '#body' do
    let(:source) { 'begin; beginbody; rescue Error => ex; :rescuebody; end' }

    it { expect(resbody_node.body.sym_type?).to be(true) }
  end
end
