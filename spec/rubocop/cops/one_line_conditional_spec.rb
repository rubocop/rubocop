# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe OneLineConditional do
      let (:olc) { OneLineConditional.new }

      it 'registers an offence for one line if/then/end' do
        inspect_source(olc, '', ['if cond then run else dont end'])
        olc.offences.map(&:message).should ==
          ['Favor the ternary operator (?:) over if/then/else/end constructs.']
      end
    end
  end
end
