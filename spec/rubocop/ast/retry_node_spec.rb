# frozen_string_literal: true

RSpec.describe RuboCop::AST::RetryNode do
  let(:retry_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a retry node' do
      let(:source) { 'retry' }

      it { expect(retry_node.is_a?(described_class)).to be(true) }
    end
  end
end
