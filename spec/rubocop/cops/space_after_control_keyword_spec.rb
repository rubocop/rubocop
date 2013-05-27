# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceAfterControlKeyword do
      let(:ap) { SpaceAfterControlKeyword.new }

      it 'registers an offence for normal if' do
        inspect_source(ap,
                       ['if(test) then result end'])
        expect(ap.offences.size).to eq(1)
      end

      it 'registers an offence for modifier unless' do
        inspect_source(ap, ['action unless(test)'])

        expect(ap.offences.size).to eq(1)
      end

      it 'does not get confused by keywords' do
        inspect_source(ap, ['[:if, :unless].action'])
        expect(ap.offences).to be_empty
      end

      it 'does not get confused by the ternary operator' do
        inspect_source(ap, ['a ? b : c'])
        expect(ap.offences).to be_empty
      end

      it 'registers an offence for if, elsif, and unless' do
        inspect_source(ap,
                       ['if(a)',
                        'elsif(b)',
                        '  unless(c)',
                        '  end',
                        'end'])
        expect(ap.offences.map(&:line_number)).to eq([1, 2, 3])
      end

      it 'registers an offence for case and when' do
        inspect_source(ap,
                       ['case(a)',
                        'when(0) then 1',
                        'end'])
        expect(ap.offences.map(&:line_number)).to eq([1, 2])
      end

      it 'registers an offence for case and when' do
        inspect_source(ap,
                       ['case(a)',
                        'when(0) then 1',
                        'end'])
        expect(ap.offences.map(&:line_number)).to eq([1, 2])
      end

      it 'registers an offence for while and until' do
        inspect_source(ap,
                       ['while(a)',
                        '  b until(c)',
                        'end'])
        expect(ap.offences.map(&:line_number)).to eq([1, 2])
      end
    end
  end
end
