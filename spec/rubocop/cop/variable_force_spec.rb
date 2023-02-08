# frozen_string_literal: true

require 'rubocop/ast/sexp'

RSpec.describe RuboCop::Cop::VariableForce do
  include RuboCop::AST::Sexp

  subject(:force) { described_class.new([]) }

  describe '#process_node' do
    before { force.variable_table.push_scope(s(:def)) }

    context 'when processing lvar node' do
      let(:node) { s(:lvar, :foo) }

      context 'when the variable is not yet declared' do
        it 'does not raise error' do
          expect { force.process_node(node) }.not_to raise_error
        end
      end
    end

    context 'when processing an empty regex' do
      let(:node) { parse_source('// =~ ""').ast }

      it 'does not raise an error' do
        expect { force.process_node(node) }.not_to raise_error
      end
    end

    context 'when processing a regex with regopt' do
      let(:node) { parse_source('/\x82/n =~ "a"').ast }

      it 'does not raise an error' do
        expect { force.process_node(node) }.not_to raise_error
      end
    end

    context 'when processing a regexp with a line break at the start of capture parenthesis' do
      let(:node) do
        parse_source(<<~REGEXP).ast
          /(
           pattern
          )/ =~ string
        REGEXP
      end

      it 'does not raise an error' do
        expect { force.process_node(node) }.not_to raise_error
      end
    end
  end
end
