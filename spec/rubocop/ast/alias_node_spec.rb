# frozen_string_literal: true

RSpec.describe RuboCop::AST::AliasNode do
  let(:alias_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) do
      'alias foo bar'
    end

    it { expect(alias_node.is_a?(described_class)).to be(true) }
  end

  describe '#new_identifier' do
    let(:source) do
      'alias foo bar'
    end

    it { expect(alias_node.new_identifier.sym_type?).to be(true) }
    it { expect(alias_node.new_identifier.children.first).to eq(:foo) }
  end

  describe '#old_identifier' do
    let(:source) do
      'alias foo bar'
    end

    it { expect(alias_node.old_identifier.sym_type?).to be(true) }
    it { expect(alias_node.old_identifier.children.first).to eq(:bar) }
  end
end
