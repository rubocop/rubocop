# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe ParenthesesAroundCondition do
        let(:pac) { ParenthesesAroundCondition.new }

        # This is broken with Parser 2.0.0.beta6, would be fixed with beta7.
        # https://github.com/whitequark/parser/commit/8b066bf
        it 'registers an offence for parentheses around condition', :broken do
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
end
