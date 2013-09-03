# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SymbolArray do
        subject(:sa) { SymbolArray.new }

        it 'registers an offence for arrays of symbols', { ruby: 2.0 } do
          inspect_source(sa,
                         ['[:one, :two, :three]'])
          expect(sa.offences.size).to eq(1)
        end

        it 'does not reg an offence for array with non-syms', { ruby: 2.0 } do
          inspect_source(sa,
                         ['[:one, :two, "three"]'])
          expect(sa.offences).to be_empty
        end

        it 'does not reg an offence for array starting with %i',
           { ruby: 2.0 } do
          inspect_source(sa,
                         ['%i(one two three)'])
          expect(sa.offences).to be_empty
        end

        it 'does not reg an offence for array with one element',
           { ruby: 2.0 } do
          inspect_source(sa,
                         ['[:three]'])
          expect(sa.offences).to be_empty
        end

        it 'does nothing on Ruby 1.9', { ruby: 1.9 } do
          inspect_source(sa,
                         ['[:one, :two, :three]'])
          expect(sa.offences).to be_empty
        end
      end
    end
  end
end
