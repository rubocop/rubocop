# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module VariableInspector
      describe Variable do
        include AST::Sexp

        describe '.new' do
          context 'when non variable declaration node is passed' do
            it 'raises error' do
              node = s(:def)
              expect { Variable.new(node) }.to raise_error(ArgumentError)
            end
          end
        end
      end
    end
  end
end
