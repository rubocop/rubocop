# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe Semicolon do
        subject(:cop) { Semicolon.new }
        let(:cop_config) do
          {
            'AllowAfterParameterListInOneLineMethods' => false,
            'AllowBeforeEndInOneLineMethods' => true
          }
        end

        it 'registers an offence for a single expression' do
          inspect_source(cop,
                         ['puts "this is a test";'])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for several expressions' do
          inspect_source(cop,
                         ['puts "this is a test"; puts "So is this"'])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for one line method with two statements' do
          inspect_source(cop,
                         ['def foo(a) x(1); y(2); z(3); end'])
          expect(cop.offences.size).to eq(1)
        end

        it 'accepts semicolon before end if so configured' do
          inspect_source(cop,
                         ['def foo(a) z(3); end'])
          expect(cop.offences).to be_empty
        end

        it 'accepts semicolon after params if so configured' do
          inspect_source(cop,
                         ['def foo(a); z(3) end'])
          expect(cop.offences).to be_empty
        end

        it 'accepts one line method definitions' do
          inspect_source(cop,
                         ['def foo1; x(3) end',
                          'def initialize(*_); end',
                          'def foo2() x(3); end',
                          'def foo3; x(3); end'])
          expect(cop.offences).to be_empty
        end

        it 'accepts one line empty class definitions' do
          inspect_source(cop,
                         ['# Prefer a single-line format for class ...',
                          'class Foo < Exception; end',
                          '',
                          'class Bar; end'])
          expect(cop.offences).to be_empty
        end

        it 'accepts one line empty method definitions' do
          inspect_source(cop,
                         ['# One exception to the rule are empty-body methods',
                          'def no_op; end',
                          '',
                          'def foo; end'])
          expect(cop.offences).to be_empty
        end

        it 'accepts one line empty module definitions' do
          inspect_source(cop,
                         ['module Foo; end'])
          expect(cop.offences).to be_empty
        end

        it 'registers an offence for semicolon at the end no matter what' do
          inspect_source(cop,
                         ['module Foo; end;'])
          expect(cop.offences.size).to eq(1)
        end

        it 'accept semicolons inside strings' do
          inspect_source(cop,
                         ['string = ";',
                          'multi-line string"'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
