# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SymbolSnakeCase do
      let(:snake_case) { SymbolSnakeCase.new }

      it 'registers an offence for camel case in names' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :BadIdea'])
        expect(snake_case.offences.map(&:message)).to eq(
          ['Use snake_case for symbols.'])
      end

      it 'registers an offence for symbol used as hash label' do
        inspect_source(snake_case, 'file.rb',
                       ['{ ONE: 1, TWO: 2 }'])
        expect(snake_case.offences.map(&:message)).to eq(
          ['Use snake_case for symbols.'] * 2)
      end

      it 'accepts snake case in names' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :good_idea'])
        expect(snake_case.offences).to be_empty
      end

      it 'accepts snake case in hash label names' do
        inspect_source(snake_case, 'file.rb',
                       ['{ one: 1, one_more_3: 2 }'])
        expect(snake_case.offences).to be_empty
      end

      it 'accepts snake case with a prefix @ in names' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :@good_idea'])
        expect(snake_case.offences).to be_empty
      end

      it 'accepts snake case with ? suffix' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :good_idea?'])
        expect(snake_case.offences).to be_empty
      end

      it 'accepts snake case with ! suffix' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :good_idea!'])
        expect(snake_case.offences).to be_empty
      end

      it 'accepts snake case with = suffix' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :good_idea='])
        expect(snake_case.offences).to be_empty
      end

      it 'accepts special cases - !, [] and **' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :**',
                        'test = :!',
                        'test = :[]',
                        'test = :[]='])
        expect(snake_case.offences).to be_empty
      end

      it 'accepts special cases - ==, <=>, >, <, >=, <=' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :==',
                        'test = :<=>',
                        'test = :>',
                        'test = :<',
                        'test = :>=',
                        'test = :<='])
        expect(snake_case.offences).to be_empty
      end

      it 'can handle an alias of and operator without crashing' do
        inspect_source(snake_case, 'file.rb',
                       ['alias + add'])
        expect(snake_case.offences).to be_empty
      end

      it 'registers an offence for SCREAMING_SNAKE_CASE' do
        inspect_source(snake_case, 'file.rb',
                       ['test = :BAD_IDEA'])
        expect(snake_case.offences.size).to eq(1)
      end
    end
  end
end
