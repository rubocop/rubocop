# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::VariableInspector::Variable do
  include AST::Sexp

  describe '.new' do
    context 'when non variable declaration node is passed' do
      it 'raises error' do
        name = :foo
        declaration_node = s(:def)
        scope = Rubocop::Cop::VariableInspector::Scope.new(s(:class))
        expect { described_class.new(name, declaration_node, scope) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#referenced?' do
    let(:name) { :foo }
    let(:declaration_node) { s(:arg, name) }
    let(:scope) { double('scope') }
    let(:variable) { described_class.new(name, declaration_node, scope) }

    subject { variable.referenced? }

    context 'when the variable is not yet assigned' do
      it { should be_false }
    end

    context 'when the variable has an assignment' do
      before do
        variable.assign(s(:lvasgn, :foo))
      end

      context 'and the assignment is not yet referenced' do
        it { should be_false }
      end

      context 'and the assignment is referenced' do
        before do
          variable.assignments.first.reference!
        end

        it { should be_true }
      end
    end

    context 'when the variable has multiple assignments' do
      before do
        variable.assign(s(:lvasgn, :foo))
        variable.assign(s(:lvasgn, :foo))
      end

      context 'and only once assignment is referenced' do
        before do
          variable.assignments[1].reference!
        end

        it { should be_true }
      end

      context 'and all assignments are referenced' do
        before do
          variable.assignments.each { |a| a.reference! }
        end

        it { should be_true }
      end
    end
  end
end
