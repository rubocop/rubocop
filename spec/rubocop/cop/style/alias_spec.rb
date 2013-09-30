# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe Alias do
        subject(:a) { Alias.new }

        it 'registers an offence for alias with symbol args' do
          inspect_source(a,
                         ['alias :ala :bala'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq(['Use alias_method instead of alias.'])
        end

        it 'registers an offence for alias with bareword args' do
          inspect_source(a,
                         ['alias ala bala'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq(['Use alias_method instead of alias.'])
        end

        it 'does not register an offence for alias_method' do
          inspect_source(a,
                         ['alias_method :ala, :bala'])
          expect(a.offences).to be_empty
        end

        it 'does not register an offence for :alias' do
          inspect_source(a,
                         ['[:alias, :ala, :bala]'])
          expect(a.offences).to be_empty
        end

        it 'does not register an offence for alias with gvars' do
          inspect_source(a,
                         ['alias $ala $bala'])
          expect(a.offences).to be_empty
        end
      end
    end
  end
end
