# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module VariableInspector
      describe VariableEntry do
        include AST::Sexp

        describe '.new' do
          context 'when non variable declaration node is passed' do
            it 'raises error' do
              node = s(:def)
              expect { VariableEntry.new(node) }.to raise_error(ArgumentError)
            end
          end
        end
      end

      describe Scope do
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
      end

      describe VariableTable do
        include AST::Sexp

        subject(:variable_table) { VariableTable.new }

        describe '#push_scope' do
          it 'returns pushed scope object' do
            node = s(:def)
            scope = variable_table.push_scope(node)
            expect(scope).to equal(variable_table.current_scope)
            expect(scope.node).to equal(node)
          end
        end

        describe '#pop_scope' do
          before do
            node = s(:def)
            variable_table.push_scope(node)
          end

          it 'returns popped scope object' do
            last_scope = variable_table.current_scope
            popped_scope = variable_table.pop_scope
            expect(popped_scope).to equal(last_scope)
          end
        end

        describe '#current_scope_level' do
          before do
            variable_table.push_scope(s(:def))
          end

          it 'increases by pushing scope' do
            last_scope_level = variable_table.current_scope_level
            variable_table.push_scope(s(:def))
            expect(variable_table.current_scope_level)
              .to eq(last_scope_level + 1)
          end

          it 'decreases by popping scope' do
            last_scope_level = variable_table.current_scope_level
            variable_table.pop_scope
            expect(variable_table.current_scope_level)
              .to eq(last_scope_level - 1)
          end
        end

        describe '#add_variable_entry' do
          before do
            2.times do
              node = s(:def)
              variable_table.push_scope(node)
            end
          end

          it 'adds variable entry to current scope with its name as key' do
            node = s(:lvasgn, :foo)
            variable_table.add_variable_entry(node)
            expect(variable_table.current_scope.variable_entries)
              .to have_key(:foo)
            expect(variable_table.scope_stack[-2].variable_entries)
              .to be_empty
            entry = variable_table.current_scope.variable_entries[:foo]
            expect(entry.node).to equal(node)
          end

          it 'returns the added variable entry' do
            node = s(:lvasgn, :foo)
            entry = variable_table.add_variable_entry(node)
            expect(entry.node).to equal(node)
          end
        end

        describe '#find_variable_entry' do
          before do
            variable_table.push_scope(s(:class))
            variable_table.add_variable_entry(s(:lvasgn, :baz))

            variable_table.push_scope(s(:def))
            variable_table.add_variable_entry(s(:lvasgn, :bar))
          end

          context 'when current scope is block' do
            before do
              variable_table.push_scope(s(:block))
            end

            context 'when a variable with the target name exists ' +
                    'in current scope' do
              before do
                variable_table.add_variable_entry(s(:lvasgn, :foo))
              end

              context 'and does not exist in outer scope' do
                it 'returns the current scope variable entry' do
                  found_entry = variable_table.find_variable_entry(:foo)
                  expect(found_entry.name).to eq(:foo)
                end
              end

              context 'and also exists in outer scope' do
                before do
                  variable_table.add_variable_entry(s(:lvasgn, :bar))
                end

                it 'returns the current scope variable entry' do
                  found_entry = variable_table.find_variable_entry(:bar)
                  expect(found_entry.name).to equal(:bar)
                  expect(variable_table.current_scope.variable_entries)
                    .to have_value(found_entry)
                  expect(variable_table.scope_stack[-2].variable_entries)
                    .not_to have_value(found_entry)
                end
              end
            end

            context 'when a variable with the target name does not exist ' +
                    'in current scope' do
              context 'but exists in the direct outer scope' do
                it 'returns the direct outer scope variable entry' do
                  found_entry = variable_table.find_variable_entry(:bar)
                  expect(found_entry.name).to equal(:bar)
                end
              end

              context 'but exists in a indirect outer scope' do
                context 'when the direct outer scope is block' do
                  before do
                    variable_table.pop_scope
                    variable_table.pop_scope

                    variable_table.push_scope(s(:block))
                    variable_table.push_scope(s(:block))
                  end

                  it 'returns the indirect outer scope variable entry' do
                    found_entry = variable_table.find_variable_entry(:baz)
                    expect(found_entry.name).to equal(:baz)
                  end
                end

                context 'when the direct outer scope is not block' do
                  it 'returns nil' do
                    found_entry = variable_table.find_variable_entry(:baz)
                    expect(found_entry).to be_nil
                  end
                end
              end

              context 'and does not exist in all outer scopes' do
                it 'returns nil' do
                  found_entry = variable_table.find_variable_entry(:non)
                  expect(found_entry).to be_nil
                end
              end
            end
          end

          context 'when current scope is not block' do
            before do
              variable_table.push_scope(s(:def))
            end

            context 'when a variable with the target name exists ' +
                    'in current scope' do
              before do
                variable_table.add_variable_entry(s(:lvasgn, :foo))
              end

              context 'and does not exist in outer scope' do
                it 'returns the current scope variable entry' do
                  found_entry = variable_table.find_variable_entry(:foo)
                  expect(found_entry.name).to eq(:foo)
                end
              end

              context 'and also exists in outer scope' do
                it 'returns the current scope variable entry' do
                  found_entry = variable_table.find_variable_entry(:foo)
                  expect(found_entry.name).to equal(:foo)
                  expect(variable_table.current_scope.variable_entries)
                    .to have_value(found_entry)
                  expect(variable_table.scope_stack[-2].variable_entries)
                    .not_to have_value(found_entry)
                end
              end
            end

            context 'when a variable with the target name does not exist ' +
                    'in current scope' do
              context 'but exists in the direct outer scope' do
                it 'returns nil' do
                  found_entry = variable_table.find_variable_entry(:bar)
                  expect(found_entry).to be_nil
                end
              end

              context 'and does not exist in all outer scopes' do
                it 'returns nil' do
                  found_entry = variable_table.find_variable_entry(:non)
                  expect(found_entry).to be_nil
                end
              end
            end
          end
        end
      end

      describe NodeScanner do
        let(:source) do
          <<-END
            class SomeClass
              foo = 1.to_s
              bar = 2.to_s
              def some_method
                baz = 3.to_s
              end
            end
          END
        end

        let(:ast) do
          processed_source = Rubocop::SourceParser.parse(source)
          processed_source.ast
        end

        # (class
        #   (const nil :SomeClass) nil
        #   (begin
        #     (lvasgn :foo
        #       (send
        #         (int 1) :to_s))
        #     (lvasgn :bar
        #       (send
        #         (int 2) :to_s))
        #     (def :some_method
        #       (args)
        #       (lvasgn :baz
        #         (send
        #           (int 3) :to_s)))))

        describe '.scan_nodes_in_scope' do
          it 'does not scan children of inner scope node' do
            scanned_node_count = 0

            NodeScanner.scan_nodes_in_scope(ast) do |node|
              scanned_node_count += 1
              fail if node.type == :lvasgn && node.children.first == :baz
            end

            expect(scanned_node_count).to eq(9)
          end

          it 'scans nodes with depth first order' do
            index = 0

            NodeScanner.scan_nodes_in_scope(ast) do |node|
              case index
              when 0
                expect(node.type).to eq(:const)
              when 1
                expect(node.type).to eq(:begin)
              when 2
                expect(node.type).to eq(:lvasgn)
              when 3
                expect(node.type).to eq(:send)
              when 4
                expect(node.type).to eq(:int)
              when 5
                expect(node.type).to eq(:lvasgn)
              end

              index += 1
            end

            expect(index).not_to eq(0)
          end

          it 'passes node index in the scope as second block argument' do
            last_index = -1

            NodeScanner.scan_nodes_in_scope(ast) do |node, index|
              expect(index).to eq(last_index + 1)
              last_index = index
            end

            expect(last_index).not_to eq(-1)
          end
        end
      end

      describe VariableInspector do
        include AST::Sexp

        class ExampleInspector
          include VariableInspector
        end

        subject(:inspector) { ExampleInspector.new }

        describe '#process_node' do
          before do
            inspector.variable_table.push_scope(s(:def))
          end

          context 'when processing lvar node' do
            let(:node) { s(:lvar, :foo) }

            context 'when the variable is already declared' do
              before do
                inspector.variable_table.add_variable_entry(s(:lvasgn, :foo))
              end

              it 'marks the variable as used' do
                entry = inspector.variable_table.find_variable_entry(:foo)
                expect(entry).not_to be_used
                inspector.process_node(node)
                expect(entry).to be_used
              end
            end

            context 'when the variable is not yet declared' do
              it 'raises error' do
                expect { inspector.process_node(node) }.to raise_error
              end
            end
          end
        end
      end
    end
  end
end
