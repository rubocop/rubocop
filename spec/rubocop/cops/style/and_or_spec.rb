# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AndOr do
        let(:cop) { AndOr.new }

        it 'registers an offence for OR' do
          inspect_source(cop,
                         ['test if a or b'])
          expect(cop.offences.size).to eq(1)
          expect(cop.messages).to eq(['Use || instead of or.'])
        end

        it 'registers an offence for AND' do
          inspect_source(cop,
                         ['test if a and b'])
          expect(cop.offences.size).to eq(1)
          expect(cop.messages).to eq(['Use && instead of and.'])
        end

        it 'accepts ||' do
          inspect_source(cop,
                         ['test if a || b'])
          expect(cop.offences).to be_empty
        end

        it 'accepts &&' do
          inspect_source(cop,
                         ['test if a && b'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
