# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe ParenthesesAroundCondition do
      let(:pac) { ParenthesesAroundCondition.new }

      it 'registers an offence for parentheses around condition' do
        inspect_source(pac, ['if (x > 10)',
                             'elsif (x < 3)',
                             'end',
                             'unless (x > 10)',
                             'end',
                             'while (x > 10)',
                             'end',
                             'until (x > 10)',
                             'end',
                             'x += 1 if (x < 10)',
                             'x += 1 unless (x < 10)',
                             'x += 1 while (x < 10)',
                             'x += 1 until (x < 10)',
                            ])
        expect(pac.offences.size).to eq(9)
      end

      it 'accepts condition without parentheses' do
        inspect_source(pac, ['if x > 10',
                             'end',
                             'unless x > 10',
                             'end',
                             'while x > 10',
                             'end',
                             'until x > 10',
                             'end',
                             'x += 1 if x < 10',
                             'x += 1 unless x < 10',
                             'x += 1 while x < 10',
                             'x += 1 until x < 10',
                            ])
        expect(pac.offences).to be_empty
      end

      it 'is not confused by leading brace in subexpression' do
        inspect_source(pac, ['(a > b) && other ? one : two'])
        expect(pac.offences).to be_empty
      end

      it 'is not confused by unbalanced parentheses' do
        inspect_source(pac, ['if (a + b).c()',
                             'end'])
        expect(pac.offences).to be_empty
      end
    end
  end
end
