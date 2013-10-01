# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::VariableInspector do
  include AST::Sexp

  class ExampleInspector
    include Rubocop::Cop::VariableInspector
  end

  subject(:inspector) { ExampleInspector.new }

  describe '#process_node' do
    before do
      inspector.variable_table.push_scope(s(:def))
    end

    context 'when processing lvar node' do
      let(:node) { s(:lvar, :foo) }

      context 'when the variable is not yet declared' do
        it 'does not raise error' do
          expect { inspector.process_node(node) }.not_to raise_error
        end
      end
    end
  end
end
