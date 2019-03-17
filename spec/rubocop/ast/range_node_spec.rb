# frozen_string_literal: true

RSpec.describe RuboCop::AST::RangeNode do
  let(:range_node) { parse_source(source).ast }

  describe '.new' do
    context 'with an inclusive range' do
      let(:source) do
        '1..2'
      end

      it { expect(range_node.is_a?(described_class)).to be(true) }
      it { expect(range_node.range_type?).to be(true) }
    end

    context 'with an exclusive range' do
      let(:source) do
        '1...2'
      end

      it { expect(range_node.is_a?(described_class)).to be(true) }
      it { expect(range_node.range_type?).to be(true) }
    end

    context 'with an infinite range' do
      let(:ruby_version) { 2.6 }
      let(:source) do
        '1..'
      end

      it { expect(range_node.is_a?(described_class)).to be(true) }
      it { expect(range_node.range_type?).to be(true) }
    end
  end
end
