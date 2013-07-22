# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AvoidClassesWithoutInstances do
        let(:cop) { AvoidClassesWithoutInstances.new }

        it 'reports an offence for a class with only singleton methods' do
          src = ['class C',
                 '  def self.a',
                 '  end',
                 '',
                 '  def C.b',
                 '  end',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences).to have(1).item
        end

        it 'accepts a class with a singleton method and an instance method' do
          src = ['class C',
                 '  def self.a',
                 '  end',
                 '',
                 '  def b',
                 '  end',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end

        it 'accepts a class with only a singleton method and inheritance' do
          src = ['class C < D',
                 '  def self.a',
                 '  end',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end

        it 'accepts an empty class' do
          src = ['class C',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
