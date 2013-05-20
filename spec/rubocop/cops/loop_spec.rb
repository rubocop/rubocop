# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Loop do
      let(:loop) { Loop.new }

      it 'registers an offence for begin/end/while' do
        inspect_source(loop, '', ['begin something; top; end while test'])
        expect(loop.offences.size).to eq(1)
      end

      it 'registers an offence for begin/end/until' do
        inspect_source(loop, '', ['begin something; top; end until test'])
        expect(loop.offences.size).to eq(1)
      end

      it 'accepts normal while' do
        inspect_source(loop, '', ['while test; one; two; end'])
        expect(loop.offences).to be_empty
      end

      it 'accepts normal until' do
        inspect_source(loop, '', ['until test; one; two; end'])
        expect(loop.offences).to be_empty
      end
    end
  end
end
