# frozen_string_literal: true

describe RuboCop::AST::SendNode do
  let(:send_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a regular method send' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.is_a?(described_class)).to be(true) }
    end

    context 'with a safe navigation method send' do
      let(:ruby_version) { 2.3 }
      let(:source) { 'foo&.bar(:baz)' }

      it { expect(send_node.is_a?(described_class)).to be(true) }
    end
  end

  describe '#receiver' do
    context 'with no receiver' do
      let(:source) { 'bar(:baz)' }

      it { expect(send_node.receiver.nil?).to be(true) }
    end

    context 'with a literal receiver' do
      let(:source) { "'foo'.bar(:baz)" }

      it { expect(send_node.receiver.str_type?).to be(true) }
    end

    context 'with a variable receiver' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.receiver.send_type?).to be(true) }
    end
  end

  describe '#method_name' do
    context 'with a plain method' do
      let(:source) { 'bar(:baz)' }

      it { expect(send_node.method_name).to eq(:bar) }
    end

    context 'with a setter method' do
      let(:source) { 'foo.bar = :baz' }

      it { expect(send_node.method_name).to eq(:bar=) }
    end

    context 'with an operator method' do
      let(:source) { 'foo == bar' }

      it { expect(send_node.method_name).to eq(:==) }
    end

    context 'with an implicit call method' do
      let(:source) { 'foo.(:baz)' }

      it { expect(send_node.method_name).to eq(:call) }
    end
  end

  describe '#method?' do
    context 'when message matches' do
      context 'when argument is a symbol' do
        let(:source) { 'bar(:baz)' }

        it { expect(send_node.method?(:bar)).to be_truthy }
      end

      context 'when argument is a string' do
        let(:source) { 'bar(:baz)' }

        it { expect(send_node.method?('bar')).to be_truthy }
      end
    end

    context 'when message does not match' do
      context 'when argument is a symbol' do
        let(:source) { 'bar(:baz)' }

        it { expect(send_node.method?(:foo)).to be_falsey }
      end

      context 'when argument is a string' do
        let(:source) { 'bar(:baz)' }

        it { expect(send_node.method?('foo')).to be_falsey }
      end
    end
  end

  describe '#access_modifier?' do
    let(:send_node) { parse_source(source).ast.children[1] }

    context 'when node is a bare `module_function`' do
      let(:source) do
        ['module Foo',
         '  module_function',
         'end'].join("\n")
      end

      it { expect(send_node.access_modifier?).to be_truthy }
    end

    context 'when node is a bare `private`' do
      let(:source) do
        ['module Foo',
         '  private',
         'end'].join("\n")
      end

      it { expect(send_node.access_modifier?).to be_truthy }
    end

    context 'when node is a bare `protected`' do
      let(:source) do
        ['module Foo',
         '  protected',
         'end'].join("\n")
      end

      it { expect(send_node.access_modifier?).to be_truthy }
    end

    context 'when node is a bare `public`' do
      let(:source) do
        ['module Foo',
         '  public',
         'end'].join("\n")
      end

      it { expect(send_node.access_modifier?).to be_truthy }
    end

    context 'when node has an argument' do
      let(:source) do
        ['module Foo',
         '  private :foo',
         'end'].join("\n")
      end

      it { expect(send_node.access_modifier?).to be_falsey }
    end

    context 'when node is not an access modifier' do
      let(:source) do
        ['module Foo',
         '  some_command',
         'end'].join("\n")
      end

      it { expect(send_node.access_modifier?).to be_falsey }
    end
  end

  describe '#macro?' do
    context 'without a receiver' do
      context 'when parent is a class' do
        let(:send_node) { parse_source(source).ast.children[2].children[0] }

        let(:source) do
          ['class Foo',
           '  bar :baz',
           '  bar :qux',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_truthy }
      end

      context 'when parent is a module' do
        let(:send_node) { parse_source(source).ast.children[1].children[0] }

        let(:source) do
          ['module Foo',
           '  bar :baz',
           '  bar :qux',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_truthy }
      end

      context 'when parent is a class constructor' do
        let(:send_node) { parse_source(source).ast.children[2].children[0] }

        let(:source) do
          ['Module.new do',
           '  bar :baz',
           '  bar :qux',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_truthy }
      end

      context 'when parent is a singleton class' do
        let(:send_node) { parse_source(source).ast.children[1].children[0] }

        let(:source) do
          ['class << self',
           '  bar :baz',
           '  bar :qux',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_truthy }
      end

      context 'when parent is a block' do
        let(:send_node) { parse_source(source).ast.children[2].children[0] }

        let(:source) do
          ['concern :Auth do',
           '  bar :baz',
           '  bar :qux',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_truthy }
      end

      context 'when parent is a keyword begin inside of an class' do
        let(:send_node) { parse_source(source).ast.children[2].children[0] }

        let(:source) do
          ['class Foo',
           '  begin',
           '    bar :qux',
           '  end',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_truthy }
      end

      context 'without a parent' do
        let(:source) { 'bar :baz' }

        it { expect(send_node.macro?).to be_truthy }
      end

      context 'when parent is a begin without a parent' do
        let(:send_node) { parse_source(source).ast.children[0] }

        let(:source) do
          ['begin',
           '  bar :qux',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_truthy }
      end

      context 'when parent is a method definition' do
        let(:send_node) { parse_source(source).ast.children[2] }

        let(:source) do
          ['def foo',
           '  bar :baz',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_falsey }
      end
    end

    context 'with a receiver' do
      context 'when parent is a class' do
        let(:send_node) { parse_source(source).ast.children[2] }

        let(:source) do
          ['class Foo',
           '  qux.bar :baz',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_falsey }
      end

      context 'when parent is a module' do
        let(:send_node) { parse_source(source).ast.children[1] }

        let(:source) do
          ['module Foo',
           '  qux.bar :baz',
           'end'].join("\n")
        end

        it { expect(send_node.macro?).to be_falsey }
      end
    end
  end

  describe '#command?' do
    context 'when argument is a symbol' do
      context 'with an explicit receiver' do
        let(:source) { 'foo.bar(:baz)' }

        it { expect(send_node.command?(:bar)).to be_falsey }
      end

      context 'with an implicit receiver' do
        let(:source) { 'bar(:baz)' }

        it { expect(send_node.command?(:bar)).to be_truthy }
      end
    end

    context 'when argument is a string' do
      context 'with an explicit receiver' do
        let(:source) { 'foo.bar(:baz)' }

        it { expect(send_node.command?('bar')).to be_falsey }
      end

      context 'with an implicit receiver' do
        let(:source) { 'bar(:baz)' }

        it { expect(send_node.command?('bar')).to be_truthy }
      end
    end
  end

  describe '#arguments' do
    context 'with no arguments' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.arguments.empty?).to be(true) }
    end

    context 'with a single literal argument' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.arguments.size).to eq(1) }
    end

    context 'with a single splat argument' do
      let(:source) { 'foo.bar(*baz)' }

      it { expect(send_node.arguments.size).to eq(1) }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'foo.bar(:baz, :qux)' }

      it { expect(send_node.arguments.size).to eq(2) }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'foo.bar(:baz, *qux)' }

      it { expect(send_node.arguments.size).to eq(2) }
    end
  end

  describe '#first_argument' do
    context 'with no arguments' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.first_argument.nil?).to be(true) }
    end

    context 'with a single literal argument' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.first_argument.sym_type?).to be(true) }
    end

    context 'with a single splat argument' do
      let(:source) { 'foo.bar(*baz)' }

      it { expect(send_node.first_argument.splat_type?).to be(true) }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'foo.bar(:baz, :qux)' }

      it { expect(send_node.first_argument.sym_type?).to be(true) }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'foo.bar(:baz, *qux)' }

      it { expect(send_node.first_argument.sym_type?).to be(true) }
    end
  end

  describe '#last_argument' do
    context 'with no arguments' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.last_argument.nil?).to be(true) }
    end

    context 'with a single literal argument' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.last_argument.sym_type?).to be(true) }
    end

    context 'with a single splat argument' do
      let(:source) { 'foo.bar(*baz)' }

      it { expect(send_node.last_argument.splat_type?).to be(true) }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'foo.bar(:baz, :qux)' }

      it { expect(send_node.last_argument.sym_type?).to be(true) }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'foo.bar(:baz, *qux)' }

      it { expect(send_node.last_argument.splat_type?).to be(true) }
    end
  end

  describe '#arguments?' do
    context 'with no arguments' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.arguments?).to be_falsey }
    end

    context 'with a single literal argument' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.arguments?).to be_truthy }
    end

    context 'with a single splat argument' do
      let(:source) { 'foo.bar(*baz)' }

      it { expect(send_node.arguments?).to be_truthy }
    end

    context 'with multiple literal arguments' do
      let(:source) { 'foo.bar(:baz, :qux)' }

      it { expect(send_node.arguments?).to be_truthy }
    end

    context 'with multiple mixed arguments' do
      let(:source) { 'foo.bar(:baz, *qux)' }

      it { expect(send_node.arguments?).to be_truthy }
    end
  end

  describe '#parenthesized?' do
    context 'with no arguments' do
      context 'when not using parentheses' do
        let(:source) { 'foo.bar' }

        it { expect(send_node.parenthesized?).to be_falsey }
      end

      context 'when using parentheses' do
        let(:source) { 'foo.bar()' }

        it { expect(send_node.parenthesized?).to be_truthy }
      end
    end

    context 'with arguments' do
      context 'when not using parentheses' do
        let(:source) { 'foo.bar :baz' }

        it { expect(send_node.parenthesized?).to be_falsey }
      end

      context 'when using parentheses' do
        let(:source) { 'foo.bar(:baz)' }

        it { expect(send_node.parenthesized?).to be_truthy }
      end
    end
  end

  describe '#setter_method?' do
    context 'with a setter method' do
      let(:source) { 'foo.bar = :baz' }

      it { expect(send_node.setter_method?).to be_truthy }
    end

    context 'with an indexed setter method' do
      let(:source) { 'foo.bar[:baz] = :qux' }

      it { expect(send_node.setter_method?).to be_truthy }
    end

    context 'with an operator method' do
      let(:source) { 'foo.bar + 1' }

      it { expect(send_node.setter_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.setter_method?).to be_falsey }
    end
  end

  describe '#operator_method?' do
    context 'with a binary operator method' do
      let(:source) { 'foo.bar + :baz' }

      it { expect(send_node.operator_method?).to be_truthy }
    end

    context 'with a unary operator method' do
      let(:source) { '!foo.bar' }

      it { expect(send_node.operator_method?).to be_truthy }
    end

    context 'with a setter method' do
      let(:source) { 'foo.bar = :baz' }

      it { expect(send_node.operator_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.operator_method?).to be_falsey }
    end
  end

  describe '#comparison_method?' do
    context 'with a comparison method' do
      let(:source) { 'foo.bar >= :baz' }

      it { expect(send_node.comparison_method?).to be_truthy }
    end

    context 'with a regular method' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.comparison_method?).to be_falsey }
    end

    context 'with a negation method' do
      let(:source) { '!foo' }

      it { expect(send_node.comparison_method?).to be_falsey }
    end
  end

  describe '#assignment_method?' do
    context 'with an assignment method' do
      let(:source) { 'foo.bar = :baz' }

      it { expect(send_node.assignment_method?).to be_truthy }
    end

    context 'with a bracket assignment method' do
      let(:source) { 'foo.bar[:baz] = :qux' }

      it { expect(send_node.assignment_method?).to be_truthy }
    end

    context 'with a comparison method' do
      let(:source) { 'foo.bar == :qux' }

      it { expect(send_node.assignment_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.assignment_method?).to be_falsey }
    end
  end

  describe '#dot?' do
    context 'with a dot' do
      let(:source) { 'foo.+ 1' }

      it { expect(send_node.dot?).to be_truthy }
    end

    context 'without a dot' do
      let(:source) { 'foo + 1' }

      it { expect(send_node.dot?).to be_falsey }
    end

    context 'with a double colon' do
      let(:source) { 'Foo::bar' }

      it { expect(send_node.dot?).to be_falsey }
    end

    context 'with a unary method' do
      let(:source) { '!foo.bar' }

      it { expect(send_node.dot?).to be_falsey }
    end
  end

  describe '#double_colon?' do
    context 'with a double colon' do
      let(:source) { 'Foo::bar' }

      it { expect(send_node.double_colon?).to be_truthy }
    end

    context 'with a dot' do
      let(:source) { 'foo.+ 1' }

      it { expect(send_node.double_colon?).to be_falsey }
    end

    context 'without a dot' do
      let(:source) { 'foo + 1' }

      it { expect(send_node.double_colon?).to be_falsey }
    end

    context 'with a unary method' do
      let(:source) { '!foo.bar' }

      it { expect(send_node.double_colon?).to be_falsey }
    end
  end

  describe '#self_receiver?' do
    context 'with a self receiver' do
      let(:source) { 'self.bar' }

      it { expect(send_node.self_receiver?).to be_truthy }
    end

    context 'with a non-self receiver' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.self_receiver?).to be_falsey }
    end

    context 'with an implicit receiver' do
      let(:source) { 'bar' }

      it { expect(send_node.self_receiver?).to be_falsey }
    end
  end

  describe '#const_receiver?' do
    context 'with a self receiver' do
      let(:source) { 'self.bar' }

      it { expect(send_node.const_receiver?).to be_falsey }
    end

    context 'with a non-constant receiver' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.const_receiver?).to be_falsey }
    end

    context 'with a constant receiver' do
      let(:source) { 'Foo.bar' }

      it { expect(send_node.const_receiver?).to be_truthy }
    end
  end

  describe '#implicit_call?' do
    context 'with an implicit call method' do
      let(:source) { 'foo.(:bar)' }

      it { expect(send_node.implicit_call?).to be_truthy }
    end

    context 'with an explicit call method' do
      let(:source) { 'foo.call(:bar)' }

      it { expect(send_node.implicit_call?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.implicit_call?).to be_falsey }
    end
  end

  describe '#predicate_method?' do
    context 'with a predicate method' do
      let(:source) { 'foo.bar?' }

      it { expect(send_node.predicate_method?).to be_truthy }
    end

    context 'with a bang method' do
      let(:source) { 'foo.bar!' }

      it { expect(send_node.predicate_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.predicate_method?).to be_falsey }
    end
  end

  describe '#bang_method?' do
    context 'with a bang method' do
      let(:source) { 'foo.bar!' }

      it { expect(send_node.bang_method?).to be_truthy }
    end

    context 'with a predicate method' do
      let(:source) { 'foo.bar?' }

      it { expect(send_node.bang_method?).to be_falsey }
    end

    context 'with a regular method' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.bang_method?).to be_falsey }
    end
  end

  describe '#camel_case_method?' do
    context 'with a camel case method' do
      let(:source) { 'Integer(1.0)' }

      it { expect(send_node.camel_case_method?).to be_truthy }
    end

    context 'with a regular method' do
      let(:source) { 'integer(1.0)' }

      it { expect(send_node.camel_case_method?).to be_falsey }
    end
  end

  describe '#block_argument?' do
    context 'with a block argument' do
      let(:source) { 'foo.bar(&baz)' }

      it { expect(send_node.block_argument?).to be_truthy }
    end

    context 'with no arguments' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.block_argument?).to be_falsey }
    end

    context 'with regular arguments' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.block_argument?).to be_falsey }
    end

    context 'with mixed arguments' do
      let(:source) { 'foo.bar(:baz, &qux)' }

      it { expect(send_node.block_argument?).to be_truthy }
    end
  end

  describe '#block_literal?' do
    context 'with a block literal' do
      let(:send_node) { parse_source(source).ast.children[0] }

      let(:source) { 'foo.bar { |q| baz(q) }' }

      it { expect(send_node.block_literal?).to be_truthy }
    end

    context 'with a block argument' do
      let(:source) { 'foo.bar(&baz)' }

      it { expect(send_node.block_literal?).to be_falsey }
    end

    context 'with no block' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.block_literal?).to be_falsey }
    end
  end

  describe '#block_node' do
    context 'with a block literal' do
      let(:send_node) { parse_source(source).ast.children[0] }

      let(:source) { 'foo.bar { |q| baz(q) }' }

      it { expect(send_node.block_node.block_type?).to be(true) }
    end

    context 'with a block argument' do
      let(:source) { 'foo.bar(&baz)' }

      it { expect(send_node.block_node.nil?).to be(true) }
    end

    context 'with no block' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.block_node.nil?).to be(true) }
    end
  end

  describe '#splat_argument?' do
    context 'with a splat argument' do
      let(:source) { 'foo.bar(*baz)' }

      it { expect(send_node.splat_argument?).to be_truthy }
    end

    context 'with no arguments' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.splat_argument?).to be_falsey }
    end

    context 'with regular arguments' do
      let(:source) { 'foo.bar(:baz)' }

      it { expect(send_node.splat_argument?).to be_falsey }
    end

    context 'with mixed arguments' do
      let(:source) { 'foo.bar(:baz, *qux)' }

      it { expect(send_node.splat_argument?).to be_truthy }
    end
  end

  describe '#def_modifier?' do
    context 'with a prefixed def modifier' do
      let(:source) { 'foo def bar; end' }

      it { expect(send_node.def_modifier?).to be_truthy }
    end

    context 'with several prefixed def modifiers' do
      let(:source) { 'foo bar def baz; end' }

      it { expect(send_node.def_modifier?).to be_truthy }
    end
  end

  describe '#negation_method?' do
    context 'with keyword `not`' do
      let(:source) { 'not foo' }

      it { expect(send_node.negation_method?).to be_truthy }
    end

    context 'with a bang method' do
      let(:source) { '!foo' }

      it { expect(send_node.negation_method?).to be_truthy }
    end

    context 'with a non-negated method' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.negation_method?).to be_falsey }
    end
  end

  describe '#lambda?' do
    context 'with a lambda method' do
      let(:source) { 'lambda { |foo| bar(foo) }' }

      it { expect(send_node.lambda?).to be_truthy }
    end

    context 'with a non-lambda method' do
      let(:source) { 'foo.bar' }

      it { expect(send_node.lambda?).to be_falsey }
    end
  end
end
