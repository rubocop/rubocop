# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SpaceAroundEqualsInParameterDefault do
        subject(:space) { SpaceAroundEqualsInParameterDefault.new }

        it 'registers an offence for default value assignment without space' do
          inspect_source(space, ['def f(x, y=0, z=1)', 'end'])
          expect(space.messages).to eq(
            ['Surrounding space missing in default value assignment.'] * 2)
        end

        it 'registers an offence for assignment empty string without space' do
          inspect_source(space, ['def f(x, y="", z=1)', 'end'])
          expect(space.offences.size).to eq(2)
        end

        it 'registers an offence for assignment of empty list without space' do
          inspect_source(space, ['def f(x, y=[])', 'end'])
          expect(space.offences.size).to eq(1)
        end

        it 'accepts default value assignment with space' do
          inspect_source(space, ['def f(x, y = 0, z = {})', 'end'])
          expect(space.messages).to be_empty
        end
      end
    end
  end
end
