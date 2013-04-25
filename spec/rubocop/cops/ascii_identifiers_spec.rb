# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AsciiIdentifiers do
      let(:ascii) { AsciiIdentifiers.new }

      it 'registers an offence for a variable name with non-ascii chars' do
        inspect_source(ascii,
                       'file.rb',
                       ['älg = 1'])
        expect(ascii.offences.size).to eq(1)
        expect(ascii.offences.map(&:message))
          .to eq([AsciiIdentifiers::ERROR_MESSAGE])
      end

      it 'accepts identifiers with only ascii chars' do
        inspect_source(ascii,
                       'file.rb',
                       ['x.empty?'])
        expect(ascii.offences).to be_empty
      end
    end
  end
end
