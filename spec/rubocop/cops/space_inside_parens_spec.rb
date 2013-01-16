# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceInsideParens do
      let (:space) { SpaceInsideParens.new }

      it 'registers an offence for spaces inside parens' do
        inspect_source(space, 'file.rb', ['f( 3)',
                                         'g(3 )'])
        space.offences.map(&:message).should ==
          ['Space inside parentheses detected.',
           'Space inside parentheses detected.']
      end

      it 'accepts parentheses in block parameter list' do
        inspect_source(space, 'file.rb',
                       ['list.inject(Tms.new) { |sum, (label, item)|',
                        '}'])
        space.offences.map(&:message).should == []
      end

    end
  end
end
