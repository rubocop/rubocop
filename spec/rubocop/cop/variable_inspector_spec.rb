# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
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
              inspector.variable_table.add_variable(s(:lvasgn, :foo))
            end

            it 'marks the variable as used' do
              variable = inspector.variable_table.find_variable(:foo)
              expect(variable).not_to be_used
              inspector.process_node(node)
              expect(variable).to be_used
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
