# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe HashSyntax do
      let(:hash_syntax) { HashSyntax.new }

      it 'registers an offence for hash rocket syntax when new is possible' do
        inspect_source(hash_syntax, '', ['x = { :a => 0 }'])
        expect(hash_syntax.offences.map(&:message)).to eq(
          ['Ruby 1.8 hash syntax detected'])
      end

      it 'registers an offence for mixed syntax when new is possible' do
        inspect_source(hash_syntax, '', ['x = { :a => 0, b: 1 }'])
        expect(hash_syntax.offences.map(&:message)).to eq(
          ['Ruby 1.8 hash syntax detected'])
      end

      it 'registers an offence for hash rockets in method calls' do
        inspect_source(hash_syntax, '', ['func(3, :a => 0)'])
        expect(hash_syntax.offences.map(&:message)).to eq(
          ['Ruby 1.8 hash syntax detected'])
      end

      it 'accepts hash rockets when keys have different types' do
        inspect_source(hash_syntax, '', ['x = { :a => 0, "b" => 1 }'])
        expect(hash_syntax.offences.map(&:message)).to be_empty
      end

      it 'accepts new syntax in a hash literal' do
        inspect_source(hash_syntax, '', ['x = { a: 0, b: 1 }'])
        expect(hash_syntax.offences.map(&:message)).to be_empty
      end

      it 'accepts new syntax in method calls' do
        inspect_source(hash_syntax, '', ['func(3, a: 0)'])
        expect(hash_syntax.offences.map(&:message)).to be_empty
      end
    end
  end
end
