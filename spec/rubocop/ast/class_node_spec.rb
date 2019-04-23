# frozen_string_literal: true

RSpec.describe RuboCop::AST::ClassNode do
  let(:class_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) do
      'class Foo; end'
    end

    it { expect(class_node.is_a?(described_class)).to be(true) }
  end

  describe '#identifier' do
    let(:source) do
      'class Foo; end'
    end

    it { expect(class_node.identifier.const_type?).to be(true) }
  end

  describe '#parent_class' do
    context 'when a parent class is specified' do
      let(:source) do
        'class Foo < Bar; end'
      end

      it { expect(class_node.parent_class.const_type?).to be(true) }
    end

    context 'when no parent class is specified' do
      let(:source) do
        'class Foo; end'
      end

      it { expect(class_node.parent_class).to be(nil) }
    end
  end

  describe '#body' do
    context 'with a single expression body' do
      let(:source) do
        'class Foo; bar; end'
      end

      it { expect(class_node.body.send_type?).to be(true) }
    end

    context 'with a multi-expression body' do
      let(:source) do
        'class Foo; bar; baz; end'
      end

      it { expect(class_node.body.begin_type?).to be(true) }
    end

    context 'with an empty body' do
      let(:source) do
        'class Foo; end'
      end

      it { expect(class_node.body).to be(nil) }
    end
  end
end
