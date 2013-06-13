# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe MethodInvocationParentheses do
      let(:mip) { MethodInvocationParentheses.new }

      it 'registers an offence for parens in method call without args' do
        inspect_source(mip, ['top.test()'])
      end

      it 'it accepts no parens in method call without args' do
        inspect_source(mip, ['top.test'])
      end

      it 'it accepts parens in method call with args' do
        inspect_source(mip, ['top.test(a)'])
      end
    end
  end
end
