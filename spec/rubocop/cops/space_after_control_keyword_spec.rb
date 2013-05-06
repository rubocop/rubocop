# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceAfterControlKeyword do
      let(:ap) { SpaceAfterControlKeyword.new }

      it 'registers an offence for normal if' do
        inspect_source(ap, 'file.rb',
                       ['if(test) then result end'])
        expect(ap.offences.size).to eq(1)
      end

      it 'registers an offence for modifier unless' do
        inspect_source(ap, 'file.rb', ['action unless(test)'])

        expect(ap.offences.size).to eq(1)
      end

      it 'does not get confused by keywords' do
        inspect_source(ap, 'file.rb', ['[:if, :unless].action'])
        expect(ap.offences).to be_empty
      end
    end
  end
end
