# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe ParenthesesAroundCondition do
      let(:pac) { ParenthesesAroundCondition.new }

      it 'registers an offence for parentheses around condition' do
        inspect_source(pac, 'file.rb', ['if (x > 10)',
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
        expect(pac.offences.map(&:message)).to eq(
          ["Don't use parentheses around the condition of an if/unless/" +
           'while/until, unless the condition contains an assignment.'] * 9)
      end

      it 'accepts condition without parentheses' do
        inspect_source(pac, 'file.rb', ['if x > 10',
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
        expect(pac.offences.map(&:message)).to be_empty
      end

      # Parentheses are sometimes used to help the editor make nice
      # indentation of conditions spanning several lines.
      it 'accepts parentheses around multiline conditions' do
        inspect_source(pac, 'file.rb', ['if (@lex_state != EXPR_BEG &&',
                                        '    @lex_state != EXPR_FNAME &&',
                                        '    trans[1])',
                                        'end'])
        expect(pac.offences.map(&:message)).to be_empty
      end

      it 'accepts parentheses around assignment' do
        inspect_source(pac, 'file.rb', ['if (x = self.next_value)',
                                        'end'])
        expect(pac.offences.map(&:message)).to be_empty
      end
    end
  end
end
