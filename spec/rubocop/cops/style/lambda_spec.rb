# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Lambda do
      let(:lambda) { Lambda.new }

      it 'registers an offence for an old single-line lambda call' do
        inspect_source(lambda, ['f = lambda { |x| x }'])
        expect(lambda.offences.size).to eq(1)
        expect(lambda.messages).to eq([Lambda::SINGLE_MSG])
      end

      it 'accepts the new lambda literal with single-line body' do
        inspect_source(lambda, ['lambda = ->(x) { x }',
                                   'lambda.(1)'])
        expect(lambda.offences).to be_empty
      end

      it 'registers an offence for a new multi-line lambda call' do
        inspect_source(lambda, ['f = ->(x) do',
                                        '  x',
                                        'end'])
        expect(lambda.offences.size).to eq(1)
        expect(lambda.messages).to eq([Lambda::MULTI_MSG])
      end

      it 'accepts the old lambda syntax with multi-line body' do
        inspect_source(lambda, ['l = lambda do |x|',
                                        '  x',
                                        'end'])
        expect(lambda.offences).to be_empty
      end

      it 'accepts the lambda call outside of block' do
        inspect_source(lambda, ['l = lambda.test'])
        expect(lambda.offences).to be_empty
      end
    end
  end
end
