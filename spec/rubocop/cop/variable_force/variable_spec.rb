# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/ast_node/sexp'

describe RuboCop::Cop::VariableForce::Variable do
  include RuboCop::Sexp

  describe '.new' do
    context 'when non variable declaration node is passed' do
      it 'raises error' do
        name = :foo
        declaration_node = s(:def)
        scope = RuboCop::Cop::VariableForce::Scope.new(s(:class))
        expect { described_class.new(name, declaration_node, scope) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#referenced?' do
    let(:name) { :foo }
    let(:declaration_node) { s(:arg, name) }
    let(:scope) { double('scope').as_null_object }
    let(:variable) { described_class.new(name, declaration_node, scope) }

    subject { variable.referenced? }

    context 'when the variable is not assigned' do
      it { is_expected.to be_falsey }

      context 'and the variable is referenced' do
        before do
          variable.reference!(s(:lvar, name))
        end

        it { is_expected.to be_truthy }
      end
    end

    context 'when the variable has an assignment' do
      before do
        variable.assign(s(:lvasgn, name))
      end

      context 'and the variable is not yet referenced' do
        it { is_expected.to be_falsey }
      end

      context 'and the variable is referenced' do
        before do
          variable.reference!(s(:lvar, name))
        end

        it { is_expected.to be_truthy }
      end
    end
  end
end
