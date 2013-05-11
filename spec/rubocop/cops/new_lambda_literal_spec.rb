# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe NewLambdaLiteral do
      let(:lambda_literal) { NewLambdaLiteral.new }

      it 'registers an offence for an old lambda call' do
        inspect_source(lambda_literal, 'file.rb', ['f = lambda { |x| x }'])
        expect(lambda_literal.offences.size).to eq(1)
      end

      it 'accepts the new lambda literal' do
        inspect_source(lambda_literal, 'file.rb', ['lambda = ->(x) { x }',
                                              'lambda.(1)'])
        expect(lambda_literal.offences).to be_empty
      end
    end
  end
end
