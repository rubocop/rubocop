# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AvoidFor do
      let(:af) { AvoidFor.new }

      it 'registers an offence for for' do
        inspect_source(af,
                       'file.rb',
                       ['def func',
                        '  for n in [1, 2, 3] do',
                        '    puts n',
                        '  end',
                        'end'])
        expect(af.offences.size).to eq(1)
        expect(af.offences.map(&:message))
          .to eq([AvoidFor::ERROR_MESSAGE])
      end

      it 'does not register an offence for :for' do
        inspect_source(af,
                       'file.rb',
                       ['[:for, :ala, :bala]'])
        expect(af.offences).to be_empty
      end

      it 'does not register an offence for def for' do
        inspect_source(af,
                       'file.rb',
                       ['def for; end'])
        expect(af.offences).to be_empty
      end
    end
  end
end
