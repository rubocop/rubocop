# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe UnreachableCode do
      let(:uc) { UnreachableCode.new }

      it 'registers an offence for return before other statements' do
        inspect_source(uc,
                       ['foo = 5',
                        'return',
                        'bar'
                       ])
        expect(uc.offences.size).to eq(1)
      end

      it 'accepts code with conditional return' do
        inspect_source(uc,
                       ['foo = 5',
                        'return if test',
                        'bar'
                       ])
        expect(uc.offences).to be_empty
      end

      it 'accepts return as the final expression' do
        inspect_source(uc,
                       ['foo = 5',
                        'return if test'
                       ])
        expect(uc.offences).to be_empty
      end
    end
  end
end
