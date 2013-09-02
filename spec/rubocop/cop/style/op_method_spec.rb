# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe OpMethod do
        let(:om) { OpMethod.new }

        it 'registers an offence for arg not named other' do
          inspect_source(om,
                         ['def +(another)',
                          '  another',
                          'end'])
          expect(om.offences.size).to eq(1)
          expect(om.messages)
            .to eq([sprintf(OpMethod::MSG, '+')])
        end

        it 'works properly even if the argument not surrounded with braces' do
          inspect_source(om,
                         ['def + another',
                          '  another',
                          'end'])
          expect(om.offences.size).to eq(1)
          expect(om.messages)
            .to eq([sprintf(OpMethod::MSG, '+')])
        end

        it 'does not register an offence for arg named other' do
          inspect_source(om,
                         ['def +(other)',
                          '  other',
                          'end'])
          expect(om.offences).to be_empty
        end

        it 'does not register an offence for []' do
          inspect_source(om,
                         ['def [](index)',
                          '  other',
                          'end'])
          expect(om.offences).to be_empty
        end

        it 'does not register an offence for []=' do
          inspect_source(om,
                         ['def []=(index, value)',
                          '  other',
                          'end'])
          expect(om.offences).to be_empty
        end

        it 'does not register an offence for <<' do
          inspect_source(om,
                         ['def <<(cop)',
                          '  other',
                          'end'])
          expect(om.offences).to be_empty
        end

        it 'does not register an offence for non binary operators' do
          inspect_source(om,
                         ['def -@', # Unary minus
                          'end',
                          '',
                          # This + is not a unary operator. It can only be
                          # called with dot notation.
                          'def +',
                          'end',
                          '',
                          'def *(a, b)', # Quite strange, but legal ruby.
                          'end'])
          expect(om.offences).to be_empty
        end
      end
    end
  end
end
