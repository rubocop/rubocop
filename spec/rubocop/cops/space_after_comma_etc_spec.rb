# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceAfterCommaEtc do
      let (:space) { SpaceAfterCommaEtc.new }

      it 'registers an offence for block argument commas' do
        space.inspect_source('file.rb', ['each { |s,t| }'])
        space.offences.map(&:message).should ==
          ['Space missing after comma.']
      end

      it 'registers an offence for colon without space after it' do
        space.inspect_source('file.rb', ['x = w ? {a:3}:4'])
        space.offences.map(&:message).should ==
          ['Space missing after colon.'] * 2
      end

      it 'registers an offence for semicolon without space after it' do
        space.inspect_source('file.rb', ['x = 1;y = 2'])
        space.offences.map(&:message).should ==
          ['Space missing after semicolon.']
      end

      it 'allows the colons in symbols' do
        space.inspect_source('file.rb', ['x = :a'])
        space.offences.map(&:message).should == []
      end

      it 'allows colons in strings' do
        space.inspect_source('file.rb', ["str << ':'"])
        space.offences.map(&:message).should == []
      end
    end
  end
end
