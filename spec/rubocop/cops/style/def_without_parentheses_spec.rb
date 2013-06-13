# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe DefWithoutParentheses do
      let(:def_par) { DefWithoutParentheses.new }

      it 'reports an offence for def with parameters but no parens' do
        src = ['def func a, b',
               'end']
        inspect_source(def_par, src)
        expect(def_par.offences.size).to eq(1)
      end

      it 'reports an offence for class def with parameters but no parens' do
        src = ['def Test.func a, b',
               'end']
        inspect_source(def_par, src)
        expect(def_par.offences.size).to eq(1)
      end

      it 'accepts def with no args and no parens' do
        src = ['def func',
               'end']
        inspect_source(def_par, src)
        expect(def_par.offences).to be_empty
      end
    end
  end
end
