# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AvoidFor do
        let(:af) { AvoidFor.new }

        it 'registers an offence for for' do
          inspect_source(af,
                         ['def func',
                          '  for n in [1, 2, 3] do',
                          '    puts n',
                          '  end',
                          'end'])
          expect(af.offences.size).to eq(1)
          expect(af.messages)
            .to eq([AvoidFor::MSG])
        end

        it 'does not register an offence for :for' do
          inspect_source(af,
                         ['[:for, :ala, :bala]'])
          expect(af.offences).to be_empty
        end

        it 'does not register an offence for def for' do
          inspect_source(af,
                         ['def for; end'])
          expect(af.offences).to be_empty
        end
      end
    end
  end
end
