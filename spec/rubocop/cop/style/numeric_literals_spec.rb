# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe NumericLiterals, :config do
        subject(:cop) { described_class.new(config) }
        let(:cop_config) { { 'MinDigits' => 5 } }

        it 'registers an offence for a long integer without underscores' do
          inspect_source(cop, ['a = 123456'])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for an integer with misplaced' do
          inspect_source(cop, ['a = 123_456_78_90_00'])
          expect(cop.offences.size).to eq(1)
        end

        it 'accepts long numbers with underscore' do
          inspect_source(cop, ['a = 123_456',
                               'b = 123_456.55'])
          expect(cop.messages).to be_empty
        end

        it 'accepts a short integer without underscore' do
          inspect_source(cop, ['a = 123'])
          expect(cop.messages).to be_empty
        end

        it 'accepts short numbers without underscore' do
          inspect_source(cop, ['a = 123',
                               'b = 123.456'])
          expect(cop.messages).to be_empty
        end
      end
    end
  end
end
