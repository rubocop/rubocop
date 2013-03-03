# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe MethodAndVariableSnakeCase do
      let (:snake_case) { MethodAndVariableSnakeCase.new }

      it 'registers an offence for camel case in names' do
        inspect_source(snake_case, 'file.rb',
                       ['def myMethod',
                        '  myLocal = 1',
                        '  self.mySetter = 2',
                        '  @myAttribute = 3',
                        'end',
                       ])
        snake_case.offences.map(&:message).should ==
          ['Use snake_case for methods and variables.'] * 4
      end

      it 'accepts snake case in names' do
        inspect_source(snake_case, 'file.rb',
                       ['def my_method',
                        '  my_local_HTML = 1',
                        '  self.my_setter = 2',
                        '  @my_attribute = 3',
                        'end',
                       ])
        snake_case.offences.map(&:message).should == []
      end

      # Mixed snake_case and CamelCase. We assume that there's a
      # special reason for this, and that these people know what
      # they're doing.
      it 'accepts mixed snake case and camel case in names' do
        inspect_source(snake_case, 'file.rb',
                       ['def visit_Arel_Nodes_SelectStatement',
                        'end'])
        snake_case.offences.map(&:message).should == []
      end

      it 'accepts screaming snake case globals' do
        inspect_source(snake_case, 'file.rb', ['$MY_GLOBAL = 0'])
        snake_case.offences.map(&:message).should == []
      end
    end
  end
end
