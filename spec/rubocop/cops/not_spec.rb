# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Not do
      let(:a) { Not.new }

      it 'registers an offence for not' do
        inspect_source(a,
                       'file.rb',
                       ['not test'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([Not::ERROR_MESSAGE])
      end

      it 'does not register an offence for !' do
        inspect_source(a,
                       'file.rb',
                       ['!test'])
        expect(a.offences).to be_empty
      end

      it 'does not register an offence for :not' do
        inspect_source(a,
                       'file.rb',
                       ['[:not, :if, :else]'])
        expect(a.offences).to be_empty
      end
    end
  end
end
