# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe WordArray do
      let(:wa) { WordArray.new }

      it 'registers an offence for arrays of single quoted strings' do
        inspect_source(wa,
                       'file.rb',
                       ["['one', 'two', 'three']"])
        expect(wa.offences.size).to eq(1)
      end

      it 'registers an offence for arrays of double quoted strings' do
        inspect_source(wa,
                       'file.rb',
                       ['["one", "two", "three"]'])
        expect(wa.offences.size).to eq(1)
      end

      it 'does not register an offence for array of non-words' do
        inspect_source(wa,
                       'file.rb',
                       ['["one space", "two", "three"]'])
        expect(wa.offences).to be_empty
      end

      it 'does not register an offence for array with empty strings' do
        inspect_source(wa,
                       'file.rb',
                       ['["", "two", "three"]'])
        expect(wa.offences).to be_empty
      end
    end
  end
end
