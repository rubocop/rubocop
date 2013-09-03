# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SpaceInsideParens do
        subject(:space) { SpaceInsideParens.new }

        it 'registers an offence for spaces inside parens' do
          inspect_source(space, ['f( 3)',
                                 'g(3 )'])
          expect(space.messages).to eq(
            ['Space inside parentheses detected.',
             'Space inside parentheses detected.'])
        end

        it 'accepts parentheses in block parameter list' do
          inspect_source(space,
                         ['list.inject(Tms.new) { |sum, (label, item)|',
                          '}'])
          expect(space.messages).to be_empty
        end

        it 'accepts parentheses with no spaces' do
          inspect_source(space, ['split("\n")'])
          expect(space.messages).to be_empty
        end
      end
    end
  end
end
