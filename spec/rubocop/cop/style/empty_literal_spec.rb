# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe EmptyLiteral do
        let(:a) { EmptyLiteral.new }

        describe 'Empty Array' do
          it 'registers an offence for Array.new()' do
            inspect_source(a,
                           ['test = Array.new()'])
            expect(a.offences.size).to eq(1)
            expect(a.offences.map(&:message))
              .to eq([EmptyLiteral::ARR_MSG])
          end

          it 'registers an offence for Array.new' do
            inspect_source(a,
                           ['test = Array.new'])
            expect(a.offences.size).to eq(1)
            expect(a.offences.map(&:message))
              .to eq([EmptyLiteral::ARR_MSG])
          end

          it 'does not register an offence for Array.new(3)' do
            inspect_source(a,
                           ['test = Array.new(3)'])
            expect(a.offences).to be_empty
          end
        end

        describe 'Empty Hash' do
          it 'registers an offence for Hash.new()' do
            inspect_source(a,
                           ['test = Hash.new()'])
            expect(a.offences.size).to eq(1)
            expect(a.offences.map(&:message))
              .to eq([EmptyLiteral::HASH_MSG])
          end

          it 'registers an offence for Hash.new' do
            inspect_source(a,
                           ['test = Hash.new'])
            expect(a.offences.size).to eq(1)
            expect(a.offences.map(&:message))
              .to eq([EmptyLiteral::HASH_MSG])
          end

          it 'does not register an offence for Hash.new(3)' do
            inspect_source(a,
                           ['test = Hash.new(3)'])
            expect(a.offences).to be_empty
          end

          it 'does not register an offence for Hash.new { block }' do
            inspect_source(a,
                           ['test = Hash.new { block }'])
            expect(a.offences).to be_empty
          end
        end

        describe 'Empty String' do
          it 'registers an offence for String.new()' do
            inspect_source(a,
                           ['test = String.new()'])
            expect(a.offences.size).to eq(1)
            expect(a.offences.map(&:message))
              .to eq([EmptyLiteral::STR_MSG])
          end

          it 'registers an offence for String.new' do
            inspect_source(a,
                           ['test = String.new'])
            expect(a.offences.size).to eq(1)
            expect(a.offences.map(&:message))
              .to eq([EmptyLiteral::STR_MSG])
          end

          it 'does not register an offence for String.new("top")' do
            inspect_source(a,
                           ['test = String.new("top")'])
            expect(a.offences).to be_empty
          end
        end
      end
    end
  end
end
