# frozen_string_literal: true

require 'rubocop/ast/sexp'

RSpec.describe RuboCop::Cop::VariableForce::Reference do
  include RuboCop::AST::Sexp

  describe '.new' do
    context 'when non variable reference node is passed' do
      it 'raises error' do
        node = s(:def)
        scope = RuboCop::Cop::VariableForce::Scope.new(s(:class))
        expect { described_class.new(node, scope) }
          .to raise_error(ArgumentError)
      end
    end
  end
end
