# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe MethodAndVariableSnakeCase do
      let(:snake_case) { MethodAndVariableSnakeCase.new }

      it 'registers an offence for camel case in names' do
        inspect_source(snake_case, 'file.rb',
                       ['def myMethod',
                        '  myLocal = 1',
                        '  self.mySetter = 2',
                        '  @myAttribute = 3',
                        'end',
                       ])
        expect(snake_case.offences.map(&:message)).to eq(
          ['Use snake_case for methods and variables.'] * 4)
      end

      it 'registers an offence for capitalized camel case' do
        inspect_source(snake_case, 'file.rb',
                       ['def MyMethod',
                        'end',
                       ])
        expect(snake_case.offences.map(&:message)).to eq(
          ['Use snake_case for methods and variables.'])
      end

      it 'accepts snake case in names' do
        inspect_source(snake_case, 'file.rb',
                       ['def my_method',
                        '  my_local_html = 1',
                        '  self.my_setter = 2',
                        '  @my_attribute = 3',
                        'end',
                       ])
        expect(snake_case.offences.map(&:message)).to be_empty
      end

      it 'registers an offence for mixed snake case and camel case' do
        inspect_source(snake_case, 'file.rb',
                       ['def visit_Arel_Nodes_SelectStatement',
                        'end'])
        expect(snake_case.offences.map(&:message)).to eq(
          ['Use snake_case for methods and variables.'])
      end

      it 'accepts screaming snake case globals' do
        inspect_source(snake_case, 'file.rb', ['$MY_GLOBAL = 0'])
        expect(snake_case.offences.map(&:message)).to be_empty
      end

      it 'accepts screaming snake case constants' do
        inspect_source(snake_case, 'file.rb', ['MY_CONSTANT = 0'])
        expect(snake_case.offences.map(&:message)).to be_empty
      end

      it 'accepts assigning to camel case constant' do
        inspect_source(snake_case, 'file.rb',
                       ['Paren = Struct.new :left, :right, :kind'])
        expect(snake_case.offences.map(&:message)).to be_empty
      end
    end
  end
end
