# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe DefWithParentheses do
      let(:def_par) { DefWithParentheses.new }

      it 'reports an offence for def with empty parens' do
        src = ['def func()',
               'end']
        inspect_source(def_par, src)
        expect(def_par.offences.size).to eq(1)
      end

      it 'reports an offence for class def with empty parens' do
        src = ['def Test.func()',
               'end']
        inspect_source(def_par, src)
        expect(def_par.offences.size).to eq(1)
      end

      it 'accepts def with arg and parens' do
        src = ['def func(a)',
               'end']
        inspect_source(def_par, src)
        expect(def_par.offences).to be_empty
      end

      it 'accepts empty parentheses in one liners' do
        src = ["def to_s() join '/' end"]
        inspect_source(def_par, src)
        expect(def_par.offences).to be_empty
      end
    end
  end
end
