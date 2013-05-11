# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe OpMethod do
      let(:om) { OpMethod.new }

      it 'registers an offence for arg not named other' do
        inspect_source(om,
                       'file.rb',
                       ['def +(another)',
                        '  another',
                        'end'])
        expect(om.offences.size).to eq(1)
        expect(om.offences.map(&:message))
          .to eq([sprintf(OpMethod::ERROR_MESSAGE, '+')])
      end

      it 'works properly even if the argument is not surrounded with braces' do
        inspect_source(om,
                       'file.rb',
                       ['def + another',
                        '  another',
                        'end'])
        expect(om.offences.size).to eq(1)
        expect(om.offences.map(&:message))
          .to eq([sprintf(OpMethod::ERROR_MESSAGE, '+')])
      end

      it 'does not register an offence for arg named other' do
        inspect_source(om,
                       'file.rb',
                       ['def +(other)',
                        '  other',
                        'end'])
        expect(om.offences).to be_empty
      end

      it 'does not register an offence for []' do
        inspect_source(om,
                       'file.rb',
                       ['def [](index)',
                        '  other',
                        'end'])
        expect(om.offences).to be_empty
      end

      it 'does not register an offence for []=' do
        inspect_source(om,
                       'file.rb',
                       ['def []=(index, value)',
                        '  other',
                        'end'])
        expect(om.offences).to be_empty
      end

      it 'does not register an offence for <<' do
        inspect_source(om,
                       'file.rb',
                       ['def <<(cop)',
                        '  other',
                        'end'])
        expect(om.offences).to be_empty
      end

      it 'does not register an offence for non binary operators' do
        inspect_source(om,
                       'file.rb',
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
