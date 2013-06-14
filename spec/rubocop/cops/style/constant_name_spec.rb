# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe ConstantName do
        let(:const) { ConstantName.new }

        it 'registers an offence for camel case in const name' do
          inspect_source(const,
                         ['TopCase = 5'])
          expect(const.offences.size).to eq(1)
        end

        it 'registers offences for camel case in multiple const assignment' do
          inspect_source(const,
                         ['TopCase, Test2, TEST_3 = 5, 6, 7'])
          expect(const.offences.size).to eq(2)
        end

        it 'registers an offence for snake case in const name' do
          inspect_source(const,
                         ['TOP_test = 5'])
          expect(const.offences.size).to eq(1)
        end

        it 'allows screaming snake case in const name' do
          inspect_source(const,
                         ['TOP_TEST = 5'])
          expect(const.offences).to be_empty
        end

        it 'allows screaming snake case in multiple const assignment' do
          inspect_source(const,
                         ['TOP_TEST, TEST_2 = 5, 6'])
          expect(const.offences).to be_empty
        end

        it 'does not check names if rhs is a method call' do
          inspect_source(const,
                         ['AnythingGoes = test'])
          expect(const.offences).to be_empty
        end

        it 'checks qualified const names' do
          inspect_source(const,
                         ['::AnythingGoes = 30',
                          'a::Bar_foo = 10'])
          expect(const.offences.size).to eq(2)
        end
      end
    end
  end
end
