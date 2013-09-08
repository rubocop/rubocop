# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module VariableInspector
      describe Scope do
        include ASTHelper
        include AST::Sexp

        describe '.new' do
          context 'when non scope node is passed' do
            it 'raises error' do
              node = s(:lvasgn)
              expect { Scope.new(node) }.to raise_error(ArgumentError)
            end
          end

          context 'when begin node is passed' do
            it 'accepts that as pseudo scope for top level scope' do
              node = s(:begin)
              expect { Scope.new(node) }.not_to raise_error
            end
          end
        end

        describe '#ancestors_of_node' do
          let(:ast) do
            processed_source = Rubocop::SourceParser.parse(source)
            processed_source.ast
          end

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

          let(:scope_node) do
            found_node = scan_node(ast) do |node|
              break node if node.type == :def
            end
            fail 'No scope node found!' unless found_node
            found_node
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

          let(:scope) { Scope.new(scope_node) }

          it 'returns nodes in between the scope node and the passed node' do
            ancestor_nodes = scope.ancestors_of_node(target_node)
            ancestor_types = ancestor_nodes.map(&:type)
            expect(ancestor_types).to eq([:begin, :if, :while, :begin])
          end
        end
      end
    end
  end
end
