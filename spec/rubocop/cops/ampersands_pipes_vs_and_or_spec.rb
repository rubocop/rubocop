# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AmpersandsPipesVsAndOr do
      let(:amp) { AmpersandsPipesVsAndOr.new }

      it 'registers an offence for AND used in condition of if statement' do
        check('if', 'and', '&&')
      end

      it 'registers an offence for OR used in condition of if statement' do
        check('if', 'or', '||')
      end

      it 'registers an offence for AND used in condition of unless' do
        check('unless', 'and', '&&')
      end

      it 'registers an offence for OR used in condition of unless' do
        check('unless', 'or', '||')
      end

      it 'registers an offence for AND used in condition of while' do
        check('while', 'and', '&&')
      end

      it 'registers an offence for OR used in condition of while' do
        check('while', 'or', '||')
      end

      it 'registers an offence for AND used in condition of until' do
        check('until', 'and', '&&')
      end

      it 'registers an offence for OR used in condition of until' do
        check('until', 'or', '||')
      end

      def check(keyword, bad_operator, good_operator)
        inspect_source(amp, 'file.rb', ["#{keyword} a #{bad_operator} b",
                                        '  c',
                                        'end',
                                        "#{keyword} a #{good_operator} b",
                                        '  c',
                                        'end'])
        # Just one offence should be registered. The good_operator
        # should be accepted.
        expect(amp.offences.map(&:message)).to eq(
          ['Use &&/|| for boolean expressions, and/or for control flow.'])
        expect(amp.offences[0].line_number).to eq(1)
      end
    end
  end
end
