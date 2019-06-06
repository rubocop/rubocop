# frozen_string_literal: true

RSpec.describe RuboCop::AST::FloatNode do
  let(:int_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) { '42.0' }

    it { expect(int_node.is_a?(described_class)).to be_truthy }
  end

  describe '#sign?' do
    context 'explicit positive float' do
      let(:source) { '+42.0' }

      it { expect(int_node.sign?).to be_truthy }
    end

    context 'explicit negative float' do
      let(:source) { '-42.0' }

      it { expect(int_node.sign?).to be_truthy }
    end
  end
end
