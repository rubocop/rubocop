# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe HashSyntax do
        subject(:cop) { described_class.new }

        it 'registers offence for hash rocket syntax when new is possible' do
          inspect_source(cop, ['x = { :a => 0 }'])
          expect(cop.messages).to eq(
            ['Ruby 1.8 hash syntax detected'])
        end

        it 'registers an offence for mixed syntax when new is possible' do
          inspect_source(cop, ['x = { :a => 0, b: 1 }'])
          expect(cop.messages).to eq(
            ['Ruby 1.8 hash syntax detected'])
        end

        it 'registers an offence for hash rockets in method calls' do
          inspect_source(cop, ['func(3, :a => 0)'])
          expect(cop.messages).to eq(
            ['Ruby 1.8 hash syntax detected'])
        end

        it 'accepts hash rockets when keys have different types' do
          inspect_source(cop, ['x = { :a => 0, "b" => 1 }'])
          expect(cop.messages).to be_empty
        end

        it 'accepts hash rockets when keys have whitespaces in them' do
          inspect_source(cop, ['x = { :"t o" => 0 }'])
          expect(cop.messages).to be_empty
        end

        it 'accepts hash rockets when keys have special symbols in them' do
          inspect_source(cop, ['x = { :"\tab" => 1 }'])
          expect(cop.messages).to be_empty
        end

        it 'accepts hash rockets when keys start with a digit' do
          inspect_source(cop, ['x = { :"1" => 1 }'])
          expect(cop.messages).to be_empty
        end

        it 'registers offence when keys start with an uppercase letter' do
          inspect_source(cop, ['x = { :A => 0 }'])
          expect(cop.messages).to eq(
            ['Ruby 1.8 hash syntax detected'])
        end

        it 'accepts new syntax in a hash literal' do
          inspect_source(cop, ['x = { a: 0, b: 1 }'])
          expect(cop.messages).to be_empty
        end

        it 'accepts new syntax in method calls' do
          inspect_source(cop, ['func(3, a: 0)'])
          expect(cop.messages).to be_empty
        end

        it 'auto-corrects old to new style' do
          new_source = autocorrect_source(cop, '{ :a => 1, :b   =>  2}')
          expect(new_source).to eq('{ a: 1, b: 2}')
        end
      end
    end
  end
end
