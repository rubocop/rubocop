# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe MultilineTernaryOperator do
        subject(:op) { MultilineTernaryOperator.new }

        it 'registers offence for a multiline ternary operator expression' do
          inspect_source(op, ['a = cond ?',
                              '  b : c'])
          expect(op.offences.size).to eq(1)
        end

        it 'accepts a single line ternary operator expression' do
          inspect_source(op, ['a = cond ? b : c'])
          expect(op.offences).to be_empty
        end
      end

      describe NestedTernaryOperator do
        subject(:op) { NestedTernaryOperator.new }

        it 'registers an offence for a nested ternary operator expression' do
          inspect_source(op, ['a ? (b ? b1 : b2) : a2'])
          expect(op.offences.size).to eq(1)
        end

        it 'accepts a non-nested ternary operator within an if' do
          inspect_source(op, ['a = if x',
                              '  cond ? b : c',
                              'else',
                              '  d',
                              'end'])
          expect(op.offences).to be_empty
        end
      end
    end
  end
end
