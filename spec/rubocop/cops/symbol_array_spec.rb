# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SymbolArray do
      let(:sa) { SymbolArray.new }

      it 'registers an offence for arrays of symbols', { ruby: 2.0 } do
        inspect_source(sa,
                       'file.rb',
                       ['[:one, :two, :three]'])
        expect(sa.offences.size).to eq(1)
      end

      it 'does nothing on Ruby 1.9', { ruby: 1.9 } do
        inspect_source(sa,
                       'file.rb',
                       ['[:one, :two, :three]'])
        expect(sa.offences).to be_empty
      end
    end
  end
end
