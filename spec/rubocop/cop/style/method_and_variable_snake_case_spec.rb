# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe MethodAndVariableSnakeCase do
        let(:cop) { described_class.new }
        let(:highlights) { cop.offences.map { |o| o.location.source } }

        it 'registers an offence for camel case in instance method name' do
          inspect_source(cop, ['def myMethod',
                               '  # ...',
                               'end'])
          expect(cop.offences).to have(1).item
          expect(highlights).to eq(['myMethod'])
        end

        it 'registers an offence for camel case in singleton method name' do
          inspect_source(cop, ['def self.myMethod',
                               '  # ...',
                               'end'])
          expect(cop.offences).to have(1).item
          expect(highlights).to eq(['myMethod'])
        end

        it 'registers an offence for camel case in local variable name' do
          inspect_source(cop, 'myLocal = 1')
          expect(cop.offences).to have(1).item
          expect(highlights).to eq(['myLocal'])
        end

        it 'registers an offence for camel case in instance variable name' do
          inspect_source(cop, '@myAttribute = 3')
          expect(cop.offences).to have(1).item
          expect(highlights).to eq(['@myAttribute'])
        end

        it 'registers an offence for camel case in setter name' do
          inspect_source(cop, 'self.mySetter = 2')
          expect(cop.offences).to have(1).item
          expect(highlights).to eq(['mySetter'])
        end

        it 'registers an offence for capitalized camel case' do
          inspect_source(cop, ['def MyMethod',
                               'end'])
          expect(cop.offences).to have(1).item
          expect(highlights).to eq(['MyMethod'])
        end

        it 'accepts snake case in names' do
          inspect_source(cop, ['def my_method',
                               '  my_local_html = 1',
                               '  self.my_setter = 2',
                               '  @my_attribute = 3',
                               'end'])
          expect(cop.offences).to be_empty
        end

        it 'registers an offence for mixed snake case and camel case' do
          inspect_source(cop, ['def visit_Arel_Nodes_SelectStatement',
                               'end'])
          expect(cop.offences).to have(1).item
          expect(highlights).to eq(['visit_Arel_Nodes_SelectStatement'])
        end

        it 'accepts screaming snake case globals' do
          inspect_source(cop, '$MY_GLOBAL = 0')
          expect(cop.offences).to be_empty
        end

        it 'accepts screaming snake case constants' do
          inspect_source(cop, 'MY_CONSTANT = 0')
          expect(cop.offences).to be_empty
        end

        it 'accepts assigning to camel case constant' do
          inspect_source(cop, 'Paren = Struct.new :left, :right, :kind')
          expect(cop.offences).to be_empty
        end

        it 'accepts one line methods' do
          inspect_source(cop, "def body; '' end")
          expect(cop.offences).to be_empty
        end

        it 'accepts operator definitions' do
          inspect_source(cop, ['def +(other)',
                               '  # ...',
                               'end'])
          expect(cop.offences).to be_empty
        end

        it 'accepts assignment with indexing of self' do
          inspect_source(cop, 'self[:a] = b')
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
