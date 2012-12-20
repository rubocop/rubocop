require 'spec_helper'

module Rubocop
  module Cop
    describe HashSyntax do
      let (:hash_syntax) { HashSyntax.new }

      it 'registers an offence for hash rocket syntax when new is possible' do
        hash_syntax.inspect_source "", ['x = { :a => 0 }']
        hash_syntax.offences.map(&:message).should ==
          ['Ruby 1.8 hash syntax detected']
      end

      it 'registers an offence for mixed syntax when new is possible' do
        hash_syntax.inspect_source "", ['x = { :a => 0, b: 1 }']
        hash_syntax.offences.map(&:message).should ==
          ['Ruby 1.8 hash syntax detected']
      end

      it 'registers an offence for hash rockets in method calls' do
        hash_syntax.inspect_source "", ['func(3, :a => 0)']
        hash_syntax.offences.map(&:message).should ==
          ['Ruby 1.8 hash syntax detected']
      end

      it 'accepts hash rockets when keys have different types' do
        hash_syntax.inspect_source "", ['x = { :a => 0, "b" => 1 }']
        hash_syntax.offences.map(&:message).should == []
      end

      it 'accepts new syntax in a hash literal' do
        hash_syntax.inspect_source "", ['x = { a: 0, b: 1 }']
        hash_syntax.offences.map(&:message).should == []
      end

      it 'accepts new syntax in method calls' do
        hash_syntax.inspect_source "", ['func(3, a: 0)']
        hash_syntax.offences.map(&:message).should == []
      end
    end
  end
end
