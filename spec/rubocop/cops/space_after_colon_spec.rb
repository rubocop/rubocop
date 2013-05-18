# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceAfterColon do
      let(:space) { SpaceAfterColon.new }

      it 'registers an offence for colon without space after it' do
        inspect_source(space, 'file.rb', ['x = w ? {a:3}:4'])
        expect(space.offences.map(&:message)).to eq(
          ['Space missing after colon.'] * 2)
      end

      it 'allows the colons in symbols' do
        inspect_source(space, 'file.rb', ['x = :a'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'allows colons in strings' do
        inspect_source(space, 'file.rb', ["str << ':'"])
        expect(space.offences.map(&:message)).to be_empty
      end
    end
  end
end
