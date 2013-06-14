# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe TrailingWhitespace do
      let(:tws) { TrailingWhitespace.new }

      it 'registers an offence for a line ending with space' do
        source = ['x = 0 ']
        inspect_source(tws, source)
        expect(tws.offences.size).to eq(1)
      end

      it 'registers an offence for a line ending with tab' do
        inspect_source(tws, ["x = 0\t"])
        expect(tws.offences.size).to eq(1)
      end

      it 'accepts a line without trailing whitespace' do
        inspect_source(tws, ["x = 0\n"])
        expect(tws.offences).to be_empty
      end
    end
  end
end
