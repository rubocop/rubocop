# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module VariableInspector
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
    end
  end
end
