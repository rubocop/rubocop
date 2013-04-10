# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe DefWithoutParentheses do
      let(:def_par) { DefWithoutParentheses.new }

      it 'reports an offence for def with parameters but no parens' do
        src = ['def func a, b',
               'end']
        inspect_source(def_par, '', src)
        expect(def_par.offences.map(&:message)).to eq(
          ['Use def with parentheses when there are arguments.'])
      end

      it 'accepts def with no args and no parens' do
        src = ['def func',
               'end']
        inspect_source(def_par, '', src)
        expect(def_par.offences.map(&:message)).to be_empty
      end
    end
  end
end
