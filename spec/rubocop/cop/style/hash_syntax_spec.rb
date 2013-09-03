# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe HashSyntax do
        subject(:hash_syntax) { HashSyntax.new }

        it 'registers offence for hash rocket syntax when new is possible' do
          inspect_source(hash_syntax, ['x = { :a => 0 }'])
          expect(hash_syntax.messages).to eq(
            ['Ruby 1.8 hash syntax detected'])
        end

        it 'registers an offence for mixed syntax when new is possible' do
          inspect_source(hash_syntax, ['x = { :a => 0, b: 1 }'])
          expect(hash_syntax.messages).to eq(
            ['Ruby 1.8 hash syntax detected'])
        end

        it 'registers an offence for hash rockets in method calls' do
          inspect_source(hash_syntax, ['func(3, :a => 0)'])
          expect(hash_syntax.messages).to eq(
            ['Ruby 1.8 hash syntax detected'])
        end

        it 'accepts hash rockets when keys have different types' do
          inspect_source(hash_syntax, ['x = { :a => 0, "b" => 1 }'])
          expect(hash_syntax.messages).to be_empty
        end

        it 'accepts hash rockets when keys have whitespaces in them' do
          inspect_source(hash_syntax, ['x = { :"t o" => 0 }'])
          expect(hash_syntax.messages).to be_empty
        end

        it 'accepts hash rockets when keys have special symbols in them' do
          inspect_source(hash_syntax, ['x = { :"\tab" => 1 }'])
          expect(hash_syntax.messages).to be_empty
        end

        it 'accepts hash rockets when keys start with a digit' do
          inspect_source(hash_syntax, ['x = { :"1" => 1 }'])
          expect(hash_syntax.messages).to be_empty
        end

        it 'registers offence when keys start with an uppercase letter' do
          inspect_source(hash_syntax, ['x = { :A => 0 }'])
          expect(hash_syntax.messages).to eq(
            ['Ruby 1.8 hash syntax detected'])
        end

        it 'accepts new syntax in a hash literal' do
          inspect_source(hash_syntax, ['x = { a: 0, b: 1 }'])
          expect(hash_syntax.messages).to be_empty
        end

        it 'accepts new syntax in method calls' do
          inspect_source(hash_syntax, ['func(3, a: 0)'])
          expect(hash_syntax.messages).to be_empty
        end
      end
    end
  end
end
