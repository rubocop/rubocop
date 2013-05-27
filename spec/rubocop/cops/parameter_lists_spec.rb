# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe ParameterLists do
      let(:list) { ParameterLists.new }

      it 'registers an offence for a method def with 5 parameters' do
        inspect_source(list, ['def meth(a, b, c, d, e)',
                              'end'])
        expect(list.messages).to eq(
          ['Avoid parameter lists longer than 4 parameters.'])
      end

      it 'accepts a method def with 4 parameters' do
        inspect_source(list, ['def meth(a, b, c, d)',
                              'end'])
        expect(list.offences).to be_empty
      end
    end
  end
end
