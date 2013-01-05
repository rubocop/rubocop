# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe TernaryOperator do
      let (:num) { TernaryOperator.new }

      it 'registers an offence for a multiline ternary operator expression' do
        inspect_source(num, 'file.rb', ['a = cond ?',
                                        '  b : c'])
        num.offences.map(&:message).should ==
          ['Avoid multi-line ?: (the ternary operator); use if/unless ' +
           'instead.']
      end

      it 'accepts a single line ternary operator expression' do
        inspect_source(num, 'file.rb', ['a = cond ? b : c'])
        num.offences.map(&:message).should == []
      end
    end
  end
end
