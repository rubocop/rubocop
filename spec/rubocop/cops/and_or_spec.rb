# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AndOr do
      let(:amp) { AndOr.new }

      it 'registers an offence for OR' do
        inspect_source(amp,
                       'file.rb',
                       ['test if a or b'])
        expect(amp.offences.size).to eq(1)
        expect(amp.messages).to eq(['Use || instead of or.'])
      end

      it 'registers an offence for AND' do
        inspect_source(amp,
                       'file.rb',
                       ['test if a and b'])
        expect(amp.offences.size).to eq(1)
        expect(amp.messages).to eq(['Use && instead of and.'])
      end

      it 'accepts ||' do
        inspect_source(amp,
                       'file.rb',
                       ['test if a || b'])
        expect(amp.offences).to be_empty
      end

      it 'accepts &&' do
        inspect_source(amp,
                       'file.rb',
                       ['test if a && b'])
        expect(amp.offences).to be_empty
      end
    end
  end
end
