# frozen_string_literal: true

RSpec.describe RuboCop::AST::SelfNode do
  let(:source) { 'self' }
  let(:self_node) { parse_source(source).ast }

  describe '.new' do
    it { expect(self_node.is_a?(described_class)).to be(true) }
  end

  describe '#arguments?' do
    it { expect(self_node.arguments?).to be(false) }
  end
end
