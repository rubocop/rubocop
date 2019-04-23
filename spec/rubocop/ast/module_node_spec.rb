# frozen_string_literal: true

RSpec.describe RuboCop::AST::ModuleNode do
  let(:module_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) do
      'module Foo; end'
    end

    it { expect(module_node.is_a?(described_class)).to be(true) }
  end

  describe '#identifier' do
    let(:source) do
      'module Foo; end'
    end

    it { expect(module_node.identifier.const_type?).to be(true) }
  end

  describe '#body' do
    context 'with a single expression body' do
      let(:source) do
        'module Foo; bar; end'
      end

      it { expect(module_node.body.send_type?).to be(true) }
    end

    context 'with a multi-expression body' do
      let(:source) do
        'module Foo; bar; baz; end'
      end

      it { expect(module_node.body.begin_type?).to be(true) }
    end

    context 'with an empty body' do
      let(:source) do
        'module Foo; end'
      end

      it { expect(module_node.body).to be(nil) }
    end
  end
end
