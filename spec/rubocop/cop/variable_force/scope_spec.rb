# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::VariableForce::Scope do
  include AST::Sexp

  describe '.new' do
    context 'when non scope node is passed' do
      it 'raises error' do
        node = s(:lvasgn)
        expect { described_class.new(node) }.to raise_error(ArgumentError)
      end
    end

    context 'when begin node is passed' do
      it 'accepts that as pseudo scope for top level scope' do
        node = s(:begin)
        expect { described_class.new(node) }.not_to raise_error
      end
    end
  end

  let(:ast) do
    ast = RuboCop::ProcessedSource.new(source).ast
    RuboCop::Cop::VariableForce.wrap_with_top_level_node(ast)
  end

  let(:scope_node_type) { :def }

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

      let(:scope_node_type) { :top_level }

      include_examples 'returns the body node'
    end
  end
end
