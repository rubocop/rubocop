# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe ParameterLists do
      let (:list) { ParameterLists.new }

      it 'registers an offence for a method def with 5 parameters' do
        inspect_source(list, 'file.rb', ['def meth(a, b, c, d, e)',
                                         'end'])
        list.offences.map(&:message).should ==
          ['Avoid parameter lists longer than four parameters.']
      end

      it 'accepts a method def with 4 parameters' do
        inspect_source(list, 'file.rb', ['def meth(a, b, c, d)',
                                         'end'])
        list.offences.map(&:message).should == []
      end
    end
  end
end
