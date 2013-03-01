# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe NewLambdaLiteral do
      let (:lambda_literal) { NewLambdaLiteral.new }

      it 'registers an offence for an old lambda call' do
        inspect_source(lambda_literal, 'file.rb', ['f = lambda { |x| x }'])
        lambda_literal.offences.map(&:message).should ==
          ['The new lambda literal syntax is preferred in Ruby 1.9.']
      end

      it 'accepts the new lambda literal' do
        inspect_source(lambda_literal, 'file.rb', ['lambda = ->(x) { x }',
                                              'lambda.(1)'])
        lambda_literal.offences.map(&:message).should == []
      end
    end
  end
end
