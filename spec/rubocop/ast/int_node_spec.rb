# frozen_string_literal: true

RSpec.describe RuboCop::AST::IntNode do
  let(:int_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) { '42' }

    it { expect(int_node.is_a?(described_class)).to be_truthy }
  end

  describe '#sign?' do
    context 'explicit positive int' do
      let(:source) { '+42' }

      it { expect(int_node.sign?).to be_truthy }
    end

    context 'explicit negative int' do
      let(:source) { '-42' }

      it { expect(int_node.sign?).to be_truthy }
    end
  end
end
