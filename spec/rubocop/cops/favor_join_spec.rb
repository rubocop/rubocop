# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe FavorJoin do
      let(:fj) { FavorJoin.new }

      it 'registers an offence for an array followed by string' do
        inspect_source(fj,
                       'file.rb',
                       ['%w(one two three) * ", "'])
        expect(fj.offences.size).to eq(1)
        expect(fj.offences.map(&:message))
          .to eq([FavorJoin::ERROR_MESSAGE])
      end

      it 'does not register an offence for numbers' do
        inspect_source(fj,
                       'file.rb',
                       ['%w(one two three) * 4'])
        expect(fj.offences).to be_empty
      end

      it 'does not register an offence for ambiguous cases' do
        inspect_source(fj,
                       'file.rb',
                       ['test * ", "'])
        expect(fj.offences).to be_empty

        inspect_source(fj,
                       'file.rb',
                       ['%w(one two three) * test'])
        expect(fj.offences).to be_empty
      end
    end
  end
end
