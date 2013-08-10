# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe RedundantReturn do
        let(:cop) { RedundantReturn.new }

        it 'reports an offence for def with only a return' do
          src = ['def func',
                 '  return something',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences.size).to eq(1)
        end

        it 'reports an offence for defs with only a return' do
          src = ['def Test.func',
                 '  return something',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences.size).to eq(1)
        end

        it 'reports an offence for def ending with return' do
          src = ['def func',
                 '  one',
                 '  two',
                 '  return something',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences.size).to eq(1)
        end

        it 'reports an offence for defs ending with return' do
          src = ['def func',
                 '  one',
                 '  two',
                 '  return something',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences.size).to eq(1)
        end

        it 'accepts return in a non-final position' do
          src = ['def func',
                 '  return something if something_else',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end

        it 'does not blow up on empty method body' do
          src = ['def func',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
