# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::VariableInspector::VariableTable do
  include AST::Sexp

  subject(:variable_table) { described_class.new }

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

  describe '#declare_variable' do
    before do
      2.times do
        node = s(:def)
        variable_table.push_scope(node)
      end
    end

    it 'adds variable to current scope with its name as key' do
      node = s(:lvasgn, :foo)
      variable_table.declare_variable(:foo, node)
      expect(variable_table.current_scope.variables)
        .to have_key(:foo)
      expect(variable_table.scope_stack[-2].variables)
        .to be_empty
      variable = variable_table.current_scope.variables[:foo]
      expect(variable.declaration_node).to equal(node)
    end

    it 'returns the added variable' do
      node = s(:lvasgn, :foo)
      variable = variable_table.declare_variable(:foo, node)
      expect(variable.declaration_node).to equal(node)
    end
  end

  describe '#find_variable' do
    before do
      variable_table.push_scope(s(:class))
      variable_table.declare_variable(:baz, s(:lvasgn, :baz))

      variable_table.push_scope(s(:def))
      variable_table.declare_variable(:bar, s(:lvasgn, :bar))
    end

    context 'when current scope is block' do
      before do
        variable_table.push_scope(s(:block))
      end

      context 'when a variable with the target name exists ' \
              'in current scope' do
        before do
          variable_table.declare_variable(:foo, s(:lvasgn, :foo))
        end

        context 'and does not exist in outer scope' do
          it 'returns the current scope variable' do
            found_variable = variable_table.find_variable(:foo)
            expect(found_variable.name).to eq(:foo)
          end
        end

        context 'and also exists in outer scope' do
          before do
            variable_table.declare_variable(:bar, s(:lvasgn, :bar))
          end

          it 'returns the current scope variable' do
            found_variable = variable_table.find_variable(:bar)
            expect(found_variable.name).to equal(:bar)
            expect(variable_table.current_scope.variables)
              .to have_value(found_variable)
            expect(variable_table.scope_stack[-2].variables)
              .not_to have_value(found_variable)
          end
        end
      end

      context 'when a variable with the target name does not exist ' \
              'in current scope' do
        context 'but exists in the direct outer scope' do
          it 'returns the direct outer scope variable' do
            found_variable = variable_table.find_variable(:bar)
            expect(found_variable.name).to equal(:bar)
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

            it 'returns the indirect outer scope variable' do
              found_variable = variable_table.find_variable(:baz)
              expect(found_variable.name).to equal(:baz)
            end
          end

          context 'when the direct outer scope is not block' do
            it 'returns nil' do
              found_variable = variable_table.find_variable(:baz)
              expect(found_variable).to be_nil
            end
          end
        end

        context 'and does not exist in all outer scopes' do
          it 'returns nil' do
            found_variable = variable_table.find_variable(:non)
            expect(found_variable).to be_nil
          end
        end
      end
    end

    context 'when current scope is not block' do
      before do
        variable_table.push_scope(s(:def))
      end

      context 'when a variable with the target name exists ' \
              'in current scope' do
        before do
          variable_table.declare_variable(:foo, s(:lvasgn, :foo))
        end

        context 'and does not exist in outer scope' do
          it 'returns the current scope variable' do
            found_variable = variable_table.find_variable(:foo)
            expect(found_variable.name).to eq(:foo)
          end
        end

        context 'and also exists in outer scope' do
          it 'returns the current scope variable' do
            found_variable = variable_table.find_variable(:foo)
            expect(found_variable.name).to equal(:foo)
            expect(variable_table.current_scope.variables)
              .to have_value(found_variable)
            expect(variable_table.scope_stack[-2].variables)
              .not_to have_value(found_variable)
          end
        end
      end

      context 'when a variable with the target name does not exist ' \
              'in current scope' do
        context 'but exists in the direct outer scope' do
          it 'returns nil' do
            found_variable = variable_table.find_variable(:bar)
            expect(found_variable).to be_nil
          end
        end

        context 'and does not exist in all outer scopes' do
          it 'returns nil' do
            found_variable = variable_table.find_variable(:non)
            expect(found_variable).to be_nil
          end
        end
      end
    end
  end

  describe '#accessible_variables' do
    let(:accessible_variable_names) do
      variable_table.accessible_variables.map(&:name)
    end

    before do
      variable_table.push_scope(s(:class))
    end

    context 'when there are no variables' do
      it 'returns empty array' do
        expect(variable_table.accessible_variables).to be_empty
      end
    end

    context 'when the current scope has some variables' do
      before do
        variable_table.declare_variable(:foo, s(:lvasgn, :foo))
        variable_table.declare_variable(:bar, s(:lvasgn, :bar))
      end

      it 'returns all the variables' do
        expect(accessible_variable_names).to match_array([:foo, :bar])
      end
    end

    context 'when the direct outer scope has some variables' do
      before do
        variable_table.declare_variable(:foo, s(:lvasgn, :foo))
      end

      context 'and the current scope is block' do
        before do
          variable_table.push_scope(s(:block))
          variable_table.declare_variable(:bar, s(:lvasgn, :bar))
          variable_table.declare_variable(:baz, s(:lvasgn, :baz))
        end

        it 'returns the current and direct outer scope variables' do
          expect(accessible_variable_names)
            .to match_array([:foo, :bar, :baz])
        end
      end

      context 'and the current scope is not block' do
        before do
          variable_table.push_scope(s(:def))
          variable_table.declare_variable(:bar, s(:lvasgn, :bar))
          variable_table.declare_variable(:baz, s(:lvasgn, :baz))
        end

        it 'returns only the current scope variables' do
          expect(accessible_variable_names).to match_array([:bar, :baz])
        end
      end
    end
  end
end
