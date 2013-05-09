# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe HashLiteral do
      let(:a) { HashLiteral.new }

      it 'registers an offence for Hash.new()' do
        inspect_source(a,
                       'file.rb',
                       ['test = Hash.new()'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([HashLiteral::ERROR_MESSAGE])
      end

      it 'registers an offence for Hash.new' do
        inspect_source(a,
                       'file.rb',
                       ['test = Hash.new'])
        expect(a.offences.size).to eq(1)
        expect(a.offences.map(&:message))
          .to eq([HashLiteral::ERROR_MESSAGE])
      end

      it 'does not register an offence for Hash.new(3)' do
        inspect_source(a,
                       'file.rb',
                       ['test = Hash.new(3)'])
        expect(a.offences).to be_empty
      end

      it 'does not crash when a method is called on super' do
        inspect_source(a,
                       'file.rb',
                       ['class Derived < Base',
                        '  def func',
                        '    super.slice(1..2)',
                        '  end',
                        'end'])
      end
    end
  end
end
