# frozen_string_literal: true

describe RuboCop::Cop::VariableForce::Scope do
  include RuboCop::AST::Sexp

  describe '.new' do
    context 'when lvasgn node is passed' do
      it 'accepts that as top level scope' do
        node = s(:lvasgn)
        expect { described_class.new(node) }.not_to raise_error
      end
    end

    context 'when begin node is passed' do
      it 'accepts that as top level scope' do
        node = s(:begin)
        expect { described_class.new(node) }.not_to raise_error
      end
    end
  end

  subject(:scope) { described_class.new(scope_node) }

  let(:ast) do
    RuboCop::ProcessedSource.new(source, ruby_version).ast
  end

  let(:scope_node) { ast.each_node(scope_node_type).first }

  describe '#name' do
    context 'when the scope is instance method definition' do
      let(:source) { <<-RUBY }
        def some_method
        end
      RUBY

      let(:scope_node_type) { :def }

      it 'returns the method name' do
        expect(scope.name).to eq(:some_method)
      end
    end

    context 'when the scope is singleton method definition' do
      let(:source) { <<-RUBY }
        def self.some_method
        end
      RUBY

      let(:scope_node_type) { :defs }

      it 'returns the method name' do
        expect(scope.name).to eq(:some_method)
      end
    end
  end

  describe '#body_node' do
    shared_examples 'returns the body node' do
      it 'returns the body node' do
        expect(scope.body_node.children[1]).to eq(:this_is_target)
      end
    end

    context 'when the scope is instance method' do
      let(:source) do
        <<-RUBY
          def some_method
            this_is_target
          end
        RUBY
      end

      let(:scope_node_type) { :def }

      include_examples 'returns the body node'
    end

    context 'when the scope is singleton method' do
      let(:source) do
        <<-RUBY
          def self.some_method
            this_is_target
          end
        RUBY
      end

      let(:scope_node_type) { :defs }

      include_examples 'returns the body node'
    end

    context 'when the scope is module' do
      let(:source) do
        <<-RUBY
          module SomeModule
            this_is_target
          end
        RUBY
      end

      let(:scope_node_type) { :module }

      include_examples 'returns the body node'
    end

    context 'when the scope is class' do
      let(:source) do
        <<-RUBY
          class SomeClass
            this_is_target
          end
        RUBY
      end

      let(:scope_node_type) { :class }

      include_examples 'returns the body node'
    end

    context 'when the scope is singleton class' do
      let(:source) do
        <<-RUBY
          class << self
            this_is_target
          end
        RUBY
      end

      let(:scope_node_type) { :sclass }

      include_examples 'returns the body node'
    end

    context 'when the scope is block' do
      let(:source) do
        <<-RUBY
          1.times do
            this_is_target
          end
        RUBY
      end

      let(:scope_node_type) { :block }

      include_examples 'returns the body node'
    end

    context 'when the scope is top level' do
      let(:source) do
        <<-RUBY
          this_is_target
        RUBY
      end

      let(:scope_node_type) { :send }

      include_examples 'returns the body node'
    end
  end

  describe '#include?' do
    subject do
      scope.include?(target_node)
    end

    let(:source) { <<-RUBY }
      class SomeClass
        def self.some_method(arg1, arg2)
          do_something

          1.times do
            foo = 1
          end
        end
      end
    RUBY

    let(:scope_node_type) { :defs }

    context 'with ancestor node the scope does not include' do
      let(:target_node) do
        ast
      end

      it { is_expected.to be false }
    end

    context 'with node of the scope itself' do
      let(:target_node) do
        ast.each_node.find(&:defs_type?)
      end

      it { is_expected.to be false }
    end

    context 'with child node the scope does not include' do
      let(:target_node) do
        ast.each_node.find(&:self_type?)
      end

      it { is_expected.to be false }
    end

    context 'with child node the scope includes' do
      let(:target_node) do
        ast.each_node.find(&:send_type?)
      end

      it { is_expected.to be true }
    end

    context 'with descendant node the scope does not include' do
      let(:target_node) do
        ast.each_node.find(&:lvasgn_type?)
      end

      it { is_expected.to be false }
    end
  end

  describe '#each_node' do
    shared_examples 'yields' do |description|
      it "yields #{description}" do
        yielded_types = []

        scope.each_node do |node|
          yielded_types << node.type
        end

        expect(yielded_types).to eq(expected_types.map(&:to_sym))
      end
    end

    describe 'outer scope boundary handling' do
      context 'when the scope is instance method' do
        let(:source) { <<-RUBY }
          def some_method(arg1, arg2)
            :body
          end
        RUBY

        let(:scope_node_type) { :def }
        let(:expected_types) { %w[args arg arg sym] }

        include_examples 'yields', 'the argument and the body nodes'
      end

      context 'when the scope is singleton method' do
        let(:source) { <<-RUBY }
          def self.some_method(arg1, arg2)
            :body
          end
        RUBY

        let(:scope_node_type) { :defs }
        let(:expected_types) { %w[args arg arg sym] }

        include_examples 'yields', 'the argument and the body nodes'
      end

      context 'when the scope is module' do
        let(:source) { <<-RUBY }
          module SomeModule
            :body
          end
        RUBY

        let(:scope_node_type) { :module }
        let(:expected_types) { %w[sym] }

        include_examples 'yields', 'the body nodes'
      end

      context 'when the scope is class' do
        let(:source) { <<-RUBY }
          some_super_class = Class.new

          class SomeClass < some_super_class
            :body
          end
        RUBY

        let(:scope_node_type) { :class }
        let(:expected_types) { %w[sym] }

        include_examples 'yields', 'the body nodes'
      end

      context 'when the scope is singleton class' do
        let(:source) { <<-RUBY }
          some_object = Object.new

          class << some_object
            :body
          end
        RUBY

        let(:scope_node_type) { :sclass }
        let(:expected_types) { %w[sym] }

        include_examples 'yields', 'the body nodes'
      end

      context 'when the scope is block' do
        let(:source) { <<-RUBY }
          1.times do |arg1, arg2|
            :body
          end
        RUBY

        let(:scope_node_type) { :block }
        let(:expected_types) { %w[args arg arg sym] }

        include_examples 'yields', 'the argument and the body nodes'
      end

      context 'when the scope is top level' do
        let(:source) { <<-RUBY }
          :body
        RUBY

        let(:scope_node_type) { :sym }
        let(:expected_types) { %w[sym] }

        include_examples 'yields', 'the body nodes'
      end
    end

    describe 'inner scope boundary handling' do
      context "when there's a method invocation with block" do
        let(:source) { <<-RUBY }
          foo = 1

          do_something(1, 2) do |arg|
            :body
          end

          foo
        RUBY

        let(:scope_node_type) { :begin }
        let(:expected_types) { %w[begin lvasgn int block send int int lvar] }

        include_examples 'yields', 'only the block node and the child send node'
      end

      context "when there's a singleton method definition" do
        let(:source) { <<-RUBY }
          foo = 1

          def self.some_method(arg1, arg2)
            :body
          end

          foo
        RUBY

        let(:scope_node_type) { :begin }
        let(:expected_types) { %w[begin lvasgn int defs self lvar] }

        include_examples 'yields', 'only the defs node and the method host node'
      end
    end
  end
end
