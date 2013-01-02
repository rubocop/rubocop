# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe DefParentheses do
      let (:def_par) { DefParentheses.new }

      it 'reports an offence for def with parameters but no parens' do
        src = ['def func a, b',
               'end']
        inspect_source(def_par, '', src)
        def_par.offences.map(&:message).should ==
          ['Use def with parentheses when there are arguments.']
      end

      it 'reports an offence for def with empty parens' do
        src = ['def func()',
               'end']
        inspect_source(def_par, '', src)
        def_par.offences.map(&:message).should ==
          ["Omit the parentheses in defs when the method doesn't accept any " +
           "arguments."]
      end

      it 'accepts def with arg and parens' do
        src = ['def func(a)',
               'end']
        inspect_source(def_par, '', src)
        def_par.offences.map(&:message).should == []
      end

      it 'accepts def with no args and no parens' do
        src = ['def func',
               'end']
        inspect_source(def_par, '', src)
        def_par.offences.map(&:message).should == []
      end

      it 'accepts empty parentheses in one liners' do
        src = ["def to_s() join '/' end"]
        inspect_source(def_par, '', src)
        def_par.offences.map(&:message).should == []
    end
    end
  end
end
