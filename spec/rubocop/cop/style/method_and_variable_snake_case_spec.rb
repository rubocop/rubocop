# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe MethodAndVariableSnakeCase do
        let(:snake_case) { MethodAndVariableSnakeCase.new }

        it 'registers an offence for camel case in instance method name' do
          inspect_source(snake_case,
                         ['def myMethod',
                          '  # ...',
                          'end',
                         ])
          expect(snake_case.offences.map(&:message)).to eq(
            ['Use snake_case for methods and variables.'])
          expect(snake_case.offences.map { |o| o.location.source })
            .to eq(['myMethod'])
        end

        it 'registers an offence for camel case in singleton method name' do
          inspect_source(snake_case,
                         ['def self.myMethod',
                          '  # ...',
                          'end',
                         ])
          expect(snake_case.offences.map(&:message)).to eq(
            ['Use snake_case for methods and variables.'])
          expect(snake_case.offences.map { |o| o.location.source })
            .to eq(['myMethod'])
        end

        it 'registers an offence for camel case in local variable name' do
          inspect_source(snake_case, ['myLocal = 1'])
          expect(snake_case.offences.map(&:message)).to eq(
            ['Use snake_case for methods and variables.'])
          expect(snake_case.offences.map { |o| o.location.source })
            .to eq(['myLocal'])
        end

        it 'registers an offence for camel case in instance variable name' do
          inspect_source(snake_case, ['@myAttribute = 3'])
          expect(snake_case.offences.map(&:message)).to eq(
            ['Use snake_case for methods and variables.'])
          expect(snake_case.offences.map { |o| o.location.source })
            .to eq(['@myAttribute'])
        end

        it 'registers an offence for camel case in setter name' do
          inspect_source(snake_case, ['self.mySetter = 2'])
          expect(snake_case.offences.map(&:message)).to eq(
            ['Use snake_case for methods and variables.'])
          expect(snake_case.offences.map { |o| o.location.source })
            .to eq(['mySetter'])
        end

        it 'registers an offence for capitalized camel case' do
          inspect_source(snake_case,
                         ['def MyMethod',
                          'end',
                         ])
          expect(snake_case.offences.map(&:message)).to eq(
            ['Use snake_case for methods and variables.'])
          expect(snake_case.offences.map { |o| o.location.source })
            .to eq(['MyMethod'])
        end

        it 'accepts snake case in names' do
          inspect_source(snake_case,
                         ['def my_method',
                          '  my_local_html = 1',
                          '  self.my_setter = 2',
                          '  @my_attribute = 3',
                          'end',
                         ])
          expect(snake_case.offences.map(&:message)).to be_empty
        end

        it 'registers an offence for mixed snake case and camel case' do
          inspect_source(snake_case,
                         ['def visit_Arel_Nodes_SelectStatement',
                          'end'])
          expect(snake_case.offences.map(&:message)).to eq(
            ['Use snake_case for methods and variables.'])
          expect(snake_case.offences.map { |o| o.location.source })
            .to eq(['visit_Arel_Nodes_SelectStatement'])
        end

        it 'accepts screaming snake case globals' do
          inspect_source(snake_case, ['$MY_GLOBAL = 0'])
          expect(snake_case.offences.map(&:message)).to be_empty
        end

        it 'accepts screaming snake case constants' do
          inspect_source(snake_case, ['MY_CONSTANT = 0'])
          expect(snake_case.offences.map(&:message)).to be_empty
        end

        it 'accepts assigning to camel case constant' do
          inspect_source(snake_case,
                         ['Paren = Struct.new :left, :right, :kind'])
          expect(snake_case.offences.map(&:message)).to be_empty
        end
      end
    end
  end
end
