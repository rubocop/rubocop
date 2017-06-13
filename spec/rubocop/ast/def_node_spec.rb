# frozen_string_literal: true

describe RuboCop::AST::DefNode do
  let(:def_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a def node' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node).to be_a(described_class) }
    end

    context 'with a defs node' do
      let(:source) { 'def self.foo(bar); end' }

      it { expect(def_node).to be_a(described_class) }
    end
  end

  describe '#method_name' do
    context 'with a plain method' do
      let(:source) { 'def foo; end' }

      it { expect(def_node.method_name).to eq(:foo) }
    end

    context 'with a setter method' do
      let(:source) { 'def foo=(bar); end' }

      it { expect(def_node.method_name).to eq(:foo=) }
    end

    context 'with an operator method' do
      let(:source) { 'def ==(bar); end' }

      it { expect(def_node.method_name).to eq(:==) }
    end

    context 'with a unary method' do
      let(:source) { 'def -@; end' }

      it { expect(def_node.method_name).to eq(:-@) }
    end
  end

  describe '#method?' do
    context 'when message matches' do
      context 'when argument is a symbol' do
        let(:source) { 'bar(:baz)' }

        it { expect(def_node.method?(:bar)).to be_truthy }
      end

      context 'when argument is a string' do
        let(:source) { 'bar(:baz)' }

        it { expect(def_node.method?('bar')).to be_truthy }
      end
    end

    context 'when message does not match' do
      context 'when argument is a symbol' do
        let(:source) { 'bar(:baz)' }

        it { expect(def_node.method?(:foo)).to be_falsey }
      end

      context 'when argument is a string' do
        let(:source) { 'bar(:baz)' }

        it { expect(def_node.method?('foo')).to be_falsey }
      end
    end
  end

  describe '#arguments' do
    context 'with no arguments' do
      let(:source) { 'def foo; end' }

      it { expect(def_node.arguments).to be_empty }
    end

    context 'with a single regular argument' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.arguments.size).to eq(1) }
    end

    context 'with a single rest argument' do
      let(:source) { 'def foo(*baz); end' }

      it { expect(def_node.arguments.size).to eq(1) }
    end

    context 'with multiple regular arguments' do
      let(:source) { 'def foo(bar, baz); end' }

      it { expect(def_node.arguments.size).to eq(2) }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'def foo(bar, *baz); end' }

      it { expect(def_node.arguments.size).to eq(2) }
    end
  end

  describe '#first_argument' do
    context 'with no arguments' do
      let(:source) { 'def foo; end' }

      it { expect(def_node.first_argument).to be_nil }
    end

    context 'with a single regular argument' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.first_argument).to be_arg_type }
    end

    context 'with a single rest argument' do
      let(:source) { 'def foo(*bar); end' }

      it { expect(def_node.first_argument).to be_restarg_type }
    end

    context 'with a single keyword argument' do
      let(:source) { 'def foo(bar: :baz); end' }

      it { expect(def_node.first_argument).to be_kwoptarg_type }
    end

    context 'with multiple regular arguments' do
      let(:source) { 'def foo(bar, baz); end' }

      it { expect(def_node.first_argument).to be_arg_type }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'def foo(bar, *baz); end' }

      it { expect(def_node.first_argument).to be_arg_type }
    end
  end

  describe '#last_argument' do
    context 'with no arguments' do
      let(:source) { 'def foo; end' }

      it { expect(def_node.last_argument).to be_nil }
    end

    context 'with a single regular argument' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.last_argument).to be_arg_type }
    end

    context 'with a single rest argument' do
      let(:source) { 'def foo(*bar); end' }

      it { expect(def_node.last_argument).to be_restarg_type }
    end

    context 'with a single keyword argument' do
      let(:source) { 'def foo(bar: :baz); end' }

      it { expect(def_node.last_argument).to be_kwoptarg_type }
    end

    context 'with multiple regular arguments' do
      let(:source) { 'def foo(bar, baz); end' }

      it { expect(def_node.last_argument).to be_arg_type }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'def foo(bar, *baz); end' }

      it { expect(def_node.last_argument).to be_restarg_type }
    end
  end

  describe '#arguments?' do
    context 'with no arguments' do
      let(:source) { 'def foo; end' }

      it { expect(def_node.arguments?).to be_falsey }
    end

    context 'with a single regular argument' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.arguments?).to be_truthy }
    end

    context 'with a single rest argument' do
      let(:source) { 'def foo(*bar); end' }

      it { expect(def_node.arguments?).to be_truthy }
    end

    context 'with a single keyword argument' do
      let(:source) { 'def foo(bar: :baz); end' }

      it { expect(def_node.arguments?).to be_truthy }
    end

    context 'with multiple regular arguments' do
      let(:source) { 'def foo(bar, baz); end' }

      it { expect(def_node.arguments?).to be_truthy }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'def foo(bar, *baz); end' }

      it { expect(def_node.arguments?).to be_truthy }
    end
  end

  describe '#rest_argument?' do
    context 'with a rest argument' do
      let(:source) { 'def foo(*bar); end' }

      it { expect(def_node.rest_argument?).to be_truthy }
    end

    context 'with no arguments' do
      let(:source) { 'def foo; end' }

      it { expect(def_node.rest_argument?).to be_falsey }
    end

    context 'with regular arguments' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.rest_argument?).to be_falsey }
    end

    context 'with mixed arguments' do
      let(:source) { 'def foo(bar, *baz); end' }

      it { expect(def_node.rest_argument?).to be_truthy }
    end
  end

  describe '#operator_method?' do
    context 'with a binary operator method' do
      let(:source) { 'def ==(bar); end' }

      it { expect(def_node.operator_method?).to be_truthy }
    end

    context 'with a unary operator method' do
      let(:source) { 'def -@; end' }

      it { expect(def_node.operator_method?).to be_truthy }
    end

    context 'with a setter method' do
      let(:source) { 'def foo=(bar); end' }

      it { expect(def_node.operator_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.operator_method?).to be_falsey }
    end
  end

  describe '#comparison_method?' do
    context 'with a comparison method' do
      let(:source) { 'def <=>(bar); end' }

      it { expect(def_node.comparison_method?).to be_truthy }
    end

    context 'with a regular method' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.comparison_method?).to be_falsey }
    end
  end

  describe '#assignment_method?' do
    context 'with an assignment method' do
      let(:source) { 'def foo=(bar); end' }

      it { expect(def_node.assignment_method?).to be_truthy }
    end

    context 'with a bracket assignment method' do
      let(:source) { 'def []=(bar); end' }

      it { expect(def_node.assignment_method?).to be_truthy }
    end

    context 'with a comparison method' do
      let(:source) { 'def ==(bar); end' }

      it { expect(def_node.assignment_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.assignment_method?).to be_falsey }
    end
  end

  describe '#receiver' do
    context 'with an instance method definition' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.receiver).to be_nil }
    end

    context 'with a class method definition' do
      let(:source) { 'def self.foo(bar); end' }

      it { expect(def_node.receiver).to be_self_type }
    end

    context 'with a singleton method definition' do
      let(:source) { 'def Foo.bar(baz); end' }

      it { expect(def_node.receiver).to be_const_type }
    end
  end

  describe '#self_receiver?' do
    context 'with an instance method definition' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.self_receiver?).to be_falsey }
    end

    context 'with a class method definition' do
      let(:source) { 'def self.foo(bar); end' }

      it { expect(def_node.self_receiver?).to be_truthy }
    end

    context 'with a singleton method definition' do
      let(:source) { 'def Foo.bar(baz); end' }

      it { expect(def_node.self_receiver?).to be_falsey }
    end
  end

  describe '#const_receiver?' do
    context 'with an instance method definition' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.const_receiver?).to be_falsey }
    end

    context 'with a class method definition' do
      let(:source) { 'def self.foo(bar); end' }

      it { expect(def_node.const_receiver?).to be_falsey }
    end

    context 'with a singleton method definition' do
      let(:source) { 'def Foo.bar(baz); end' }

      it { expect(def_node.const_receiver?).to be_truthy }
    end
  end

  describe '#predicate_method?' do
    context 'with a predicate method' do
      let(:source) { 'def foo?(bar); end' }

      it { expect(def_node.predicate_method?).to be_truthy }
    end

    context 'with a bang method' do
      let(:source) { 'def foo!(bar); end' }

      it { expect(def_node.predicate_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.predicate_method?).to be_falsey }
    end
  end

  describe '#bang_method?' do
    context 'with a bang method' do
      let(:source) { 'def foo!(bar); end' }

      it { expect(def_node.bang_method?).to be_truthy }
    end

    context 'with a predicate method' do
      let(:source) { 'def foo?(bar); end' }

      it { expect(def_node.bang_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.bang_method?).to be_falsey }
    end
  end

  describe '#camel_case_method?' do
    context 'with a camel case method' do
      let(:source) { 'def Foo(bar); end' }

      it { expect(def_node.camel_case_method?).to be_truthy }
    end

    context 'with a regular method' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.camel_case_method?).to be_falsey }
    end
  end

  describe '#block_argument?' do
    context 'with a block argument' do
      let(:source) { 'def foo(&bar); end' }

      it { expect(def_node.block_argument?).to be_truthy }
    end

    context 'with no arguments' do
      let(:source) { 'def foo; end' }

      it { expect(def_node.block_argument?).to be_falsey }
    end

    context 'with regular arguments' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.block_argument?).to be_falsey }
    end

    context 'with mixed arguments' do
      let(:source) { 'def foo(bar, &baz); end' }

      it { expect(def_node.block_argument?).to be_truthy }
    end
  end

  describe '#body' do
    context 'with no body' do
      let(:source) { 'def foo(bar); end' }

      it { expect(def_node.body).to be_nil }
    end

    context 'with a single expression body' do
      let(:source) { 'def foo(bar); baz; end' }

      it { expect(def_node.body).to be_send_type }
    end

    context 'with a multi-expression body' do
      let(:source) { 'def foo(bar); baz; qux; end' }

      it { expect(def_node.body).to be_begin_type }
    end
  end
end
