# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe ArrayLiteral do
      let(:a) { ArrayLiteral.new }

      it 'registers an offence for Array.new()' do
        inspect_source(a,
                       'file.rb',
                       ['test = Array.new()'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([ArrayLiteral::ERROR_MESSAGE])
      end

      it 'registers an offence for Array.new'

      it 'does not register an offence for Array.new(3)' do
        inspect_source(a,
                       'file.rb',
                       ['test = Array.new(3)'])
        expect(a.offences).to be_empty
      end
    end
  end
end
