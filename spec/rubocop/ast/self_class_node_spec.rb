# frozen_string_literal: true

RSpec.describe RuboCop::AST::SelfClassNode do
  let(:self_class_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) do
      'class << self; end'
    end

    it { expect(self_class_node.is_a?(described_class)).to be(true) }
  end

  describe '#identifier' do
    let(:source) do
      'class << self; end'
    end

    it { expect(self_class_node.identifier.self_type?).to be(true) }
  end

  describe '#body' do
    context 'with a single expression body' do
      let(:source) do
        'class << self; bar; end'
      end

      it { expect(self_class_node.body.send_type?).to be(true) }
    end

    context 'with a multi-expression body' do
      let(:source) do
        'class << self; bar; baz; end'
      end

      it { expect(self_class_node.body.begin_type?).to be(true) }
    end

    context 'with an empty body' do
      let(:source) do
        'class << self; end'
      end

      it { expect(self_class_node.body).to be(nil) }
    end
  end
end
