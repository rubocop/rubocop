# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::VariableInspector::Scope do
  include ASTHelper
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
    ast = Rubocop::SourceParser.parse(source).ast
    Rubocop::Cop::VariableInspector.wrap_with_top_level_node(ast)
  end

  let(:scope_node_type) { :def }

  let(:scope_node) do
    found_node = scan_node(ast, include_origin_node: true) do |node|
      break node if node.type == scope_node_type
    end
    fail 'No scope node found!' unless found_node
    found_node
  end

  subject(:scope) { described_class.new(scope_node) }

  describe '#ancestors_of_node' do
    let(:source) do
      <<-END
        puts 1

        class SomeClass
          def some_method
            foo = 1

            if foo > 0
              while foo < 10
                this_is_target
                foo += 1
              end
            else
              do_something
            end
          end
        end
      END
    end

    let(:target_node) do
      found_node = scan_node(ast) do |node|
        next unless node.type == :send
        _receiver_node, method_name = *node
        break node if method_name == :this_is_target
      end
      fail 'No target node found!' unless found_node
      found_node
    end

    it 'returns nodes in between the scope node and the passed node' do
      ancestor_nodes = scope.ancestors_of_node(target_node)
      ancestor_types = ancestor_nodes.map(&:type)
      expect(ancestor_types).to eq([:begin, :if, :while, :begin])
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
