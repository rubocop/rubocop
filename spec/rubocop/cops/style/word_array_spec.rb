# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe WordArray do
        let(:wa) { WordArray.new }

        it 'registers an offence for arrays of single quoted strings' do
          inspect_source(wa,
                         ["['one', 'two', 'three']"])
          expect(wa.offences.size).to eq(1)
        end

        it 'registers an offence for arrays of double quoted strings' do
          inspect_source(wa,
                         ['["one", "two", "three"]'])
          expect(wa.offences.size).to eq(1)
        end

        it 'does not register an offence for array of non-words' do
          inspect_source(wa,
                         ['["one space", "two", "three"]'])
          expect(wa.offences).to be_empty
        end

        it 'does not register an offence for array starting with %w' do
          inspect_source(wa,
                         ['%w(one two three)'])
          expect(wa.offences).to be_empty
        end

        it 'does not register an offence for array with one element' do
          inspect_source(wa,
                         ['["three"]'])
          expect(wa.offences).to be_empty
        end

        it 'does not register an offence for array with empty strings' do
          inspect_source(wa,
                         ['["", "two", "three"]'])
          expect(wa.offences).to be_empty
        end
      end
    end
  end
end
