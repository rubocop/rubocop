# frozen_string_literal: true

require 'rubocop/ast/sexp'

RSpec.describe RuboCop::Cop::VariableForce do
  include RuboCop::AST::Sexp

  subject(:force) { described_class.new([]) }

  describe '#process_node' do
    before do
      force.variable_table.push_scope(s(:def))
    end

    context 'when processing lvar node' do
      let(:node) { s(:lvar, :foo) }

      context 'when the variable is not yet declared' do
        it 'does not raise error' do
          expect { force.process_node(node) }.not_to raise_error
        end
      end
    end

    context 'when processing an empty regex' do
      let(:node) { s(:match_with_lvasgn, s(:regexp, s(:regopt)), s(:str)) }

      it 'does not raise an error' do
        expect { force.process_node(node) }.not_to raise_error
      end
    end
  end
end
