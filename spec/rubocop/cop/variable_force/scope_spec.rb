# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::VariableForce::Scope do
  include RuboCop::Sexp

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

  let(:ast) do
    RuboCop::ProcessedSource.new(source, ruby_version).ast
  end

  let(:scope_node) { ast.each_node(scope_node_type).first }

  subject(:scope) { described_class.new(scope_node) }

  describe '#name' do
    context 'when the scope is instance method definition' do
      let(:source) { <<-END }
        def some_method
        end
      END

      let(:scope_node_type) { :def }

      it 'returns the method name' do
        expect(scope.name).to eq(:some_method)
      end
    end

    context 'when the scope is singleton method definition' do
      let(:source) { <<-END }
        def self.some_method
        end
      END

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
        <<-END
          def some_method
            this_is_target
          end
        END
      end

      let(:scope_node_type) { :def }

      include_examples 'returns the body node'
    end

    context 'when the scope is singleton method' do
      let(:source) do
        <<-END
          def self.some_method
            this_is_target
          end
        END
      end

      let(:scope_node_type) { :defs }

      include_examples 'returns the body node'
    end

    context 'when the scope is module' do
      let(:source) do
        <<-END
          module SomeModule
            this_is_target
          end
        END
      end

      let(:scope_node_type) { :module }

      include_examples 'returns the body node'
    end

    context 'when the scope is class' do
      let(:source) do
        <<-END
          class SomeClass
            this_is_target
          end
        END
      end

      let(:scope_node_type) { :class }

      include_examples 'returns the body node'
    end

    context 'when the scope is singleton class' do
      let(:source) do
        <<-END
          class << self
            this_is_target
          end
        END
      end

      let(:scope_node_type) { :sclass }

      include_examples 'returns the body node'
    end

    context 'when the scope is block' do
      let(:source) do
        <<-END
          1.times do
            this_is_target
          end
        END
      end

      let(:scope_node_type) { :block }

      include_examples 'returns the body node'
    end

    context 'when the scope is top level' do
      let(:source) do
        <<-END
          this_is_target
        END
      end

      let(:scope_node_type) { :send }

      include_examples 'returns the body node'
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
        let(:source) { <<-END }
          def some_method(arg1, arg2)
            :body
          end
        END

        let(:scope_node_type) { :def }
        let(:expected_types) { %w(def args arg arg sym) }
        include_examples 'yields', 'the argument and the body nodes'
      end

      context 'when the scope is singleton method' do
        let(:source) { <<-END }
          def self.some_method(arg1, arg2)
            :body
          end
        END

        let(:scope_node_type) { :defs }
        let(:expected_types) { %w(defs args arg arg sym) }
        include_examples 'yields', 'the argument and the body nodes'
      end

      context 'when the scope is module' do
        let(:source) { <<-END }
          module SomeModule
            :body
          end
        END

        let(:scope_node_type) { :module }
        let(:expected_types) { %w(module sym) }
        include_examples 'yields', 'the body nodes'
      end

      context 'when the scope is class' do
        let(:source) { <<-END }
          some_super_class = Class.new

          class SomeClass < some_super_class
            :body
          end
        END

        let(:scope_node_type) { :class }
        let(:expected_types) { %w(sym) }
        include_examples 'yields', 'the body nodes'
      end

      context 'when the scope is singleton class' do
        let(:source) { <<-END }
          some_object = Object.new

          class << some_object
            :body
          end
        END

        let(:scope_node_type) { :sclass }
        let(:expected_types) { %w(sym) }
        include_examples 'yields', 'the body nodes'
      end

      context 'when the scope is block' do
        let(:source) { <<-END }
          1.times do |arg1, arg2|
            :body
          end
        END

        let(:scope_node_type) { :block }
        let(:expected_types) { %w(block args arg arg sym) }
        include_examples 'yields', 'the argument and the body nodes'
      end

      context 'when the scope is top level' do
        let(:source) { <<-END }
          :body
        END

        let(:scope_node_type) { :sym }
        let(:expected_types) { %w(sym) }
        include_examples 'yields', 'the body nodes'
      end
    end

    describe 'inner scope boundary handling' do
      context "when there's a method invocation with block" do
        let(:source) { <<-END }
          foo = 1

          do_something(1, 2) do |arg|
            :body
          end

          foo
        END

        let(:scope_node_type) { :begin }
        let(:expected_types) { %w(begin lvasgn int block send int int lvar) }
        include_examples 'yields', 'only the block node and the child send node'
      end

      context "when there's a singleton method definition" do
        let(:source) { <<-END }
          foo = 1

          def self.some_method(arg1, arg2)
            :body
          end

          foo
        END

        let(:scope_node_type) { :begin }
        let(:expected_types) { %w(begin lvasgn int defs self lvar) }
        include_examples 'yields', 'only the defs node and the method host node'
      end

      context 'when there are grouped nodes with a begin node' do
        let(:source) { <<-END }
          foo = 1

          if true
            do_something
            do_anything
          end

          foo
        END

        let(:scope_node_type) { :begin }
        let(:expected_types) do
          %w(begin lvasgn int if true begin send send lvar)
        end
        include_examples 'yields', 'them without confused with top level scope'
      end
    end
  end
end
