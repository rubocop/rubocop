# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceAfterColon do
      let (:space) { SpaceAfterColon.new }

      it 'registers an offence for colon without space after it' do
        inspect_source(space, 'file.rb', ['x = w ? {a:3}:4'])
        space.offences.map(&:message).should ==
          ['Space missing after colon.'] * 2
      end

      it 'allows the colons in symbols' do
        inspect_source(space, 'file.rb', ['x = :a'])
        space.offences.map(&:message).should == []
      end

      it 'allows colons in strings' do
        inspect_source(space, 'file.rb', ["str << ':'"])
        space.offences.map(&:message).should == []
      end
    end
  end
end
