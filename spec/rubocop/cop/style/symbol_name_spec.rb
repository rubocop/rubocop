  # encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SymbolName do
        let(:symbol_name) { SymbolName.new }

        before do
          SymbolName.config =
            Config.default_configuration.for_cop('SymbolName')
        end

        context 'when AllowCamelCase is true' do
          before do
            SymbolName.config = {
              'AllowCamelCase' => true
            }
          end

          it 'does not register an offence for camel case in names' do
            inspect_source(symbol_name,
                           ['test = :BadIdea'])
            expect(symbol_name.offences).to be_empty
          end
        end

        context 'when AllowCamelCase is false' do
          before do
            SymbolName.config = {
              'AllowCamelCase' => false
            }
          end

          it 'registers an offence for camel case in names' do
            inspect_source(symbol_name,
                           ['test = :BadIdea'])
            expect(symbol_name.offences.map(&:message)).to eq(
              ['Use snake_case for symbols.'])
          end
        end

        it 'registers an offence for symbol used as hash label' do
          inspect_source(symbol_name,
                         ['{ KEY_ONE: 1, KEY_TWO: 2 }'])
          expect(symbol_name.offences.map(&:message)).to eq(
            ['Use snake_case for symbols.'] * 2)
        end

        it 'accepts snake case in names' do
          inspect_source(symbol_name,
                         ['test = :good_idea'])
          expect(symbol_name.offences).to be_empty
        end

        it 'accepts snake case in hash label names' do
          inspect_source(symbol_name,
                         ['{ one: 1, one_more_3: 2 }'])
          expect(symbol_name.offences).to be_empty
        end

        it 'accepts snake case with a prefix @ in names' do
          inspect_source(symbol_name,
                         ['test = :@good_idea'])
          expect(symbol_name.offences).to be_empty
        end

        it 'accepts snake case with ? suffix' do
          inspect_source(symbol_name,
                         ['test = :good_idea?'])
          expect(symbol_name.offences).to be_empty
        end

        it 'accepts snake case with ! suffix' do
          inspect_source(symbol_name,
                         ['test = :good_idea!'])
          expect(symbol_name.offences).to be_empty
        end

        it 'accepts snake case with = suffix' do
          inspect_source(symbol_name,
                         ['test = :good_idea='])
          expect(symbol_name.offences).to be_empty
        end

        it 'accepts special cases - !, [] and **' do
          inspect_source(symbol_name,
                         ['test = :**',
                          'test = :!',
                          'test = :[]',
                          'test = :[]='])
          expect(symbol_name.offences).to be_empty
        end

        it 'accepts special cases - ==, <=>, >, <, >=, <=' do
          inspect_source(symbol_name,
                         ['test = :==',
                          'test = :<=>',
                          'test = :>',
                          'test = :<',
                          'test = :>=',
                          'test = :<='])
          expect(symbol_name.offences).to be_empty
        end

        it 'accepts non snake case arguments to private_constant' do
          inspect_source(symbol_name,
                         ['private_constant :NORMAL_MODE, :ADMIN_MODE'])
          expect(symbol_name.offences).to be_empty
        end

        it 'registers an offence for non snake case symbol near ' +
            'private_constant' do
          inspect_source(symbol_name,
                         ['private_constant f(:ADMIN_MODE)'])
          expect(symbol_name.offences.size).to eq(1)
        end

        it 'can handle an alias of and operator without crashing' do
          inspect_source(symbol_name,
                         ['alias + add'])
          expect(symbol_name.offences).to be_empty
        end

        it 'registers an offence for SCREAMING_symbol_name' do
          inspect_source(symbol_name,
                         ['test = :BAD_IDEA'])
          expect(symbol_name.offences.size).to eq(1)
        end
      end
    end
  end
end
