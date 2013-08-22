# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe MethodCallParentheses do
        let(:cop) { described_class.new }

        it 'registers an offence for parens in method call without args' do
          inspect_source(cop, ['top.test()'])
        end

        it 'it accepts no parens in method call without args' do
          inspect_source(cop, ['top.test'])
        end

        it 'it accepts parens in method call with args' do
          inspect_source(cop, ['top.test(a)'])
        end

        it 'auto-corrects by removing unneeded braces' do
          new_source = autocorrect_source(cop, 'test()')
          expect(new_source).to eq('test')
        end
      end
    end
  end
end
