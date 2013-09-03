# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe Not do
        subject(:a) { Not.new }

        it 'registers an offence for not' do
          inspect_source(a, ['not test'])
          expect(a.offences.size).to eq(1)
        end

        it 'does not register an offence for !' do
          inspect_source(a, ['!test'])
          expect(a.offences).to be_empty
        end

        it 'does not register an offence for :not' do
          inspect_source(a, ['[:not, :if, :else]'])
          expect(a.offences).to be_empty
        end
      end
    end
  end
end
