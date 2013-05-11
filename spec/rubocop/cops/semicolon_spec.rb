# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Semicolon do
      let(:s) { Semicolon.new }
      before do
        Semicolon.config = {
          'AllowAfterParameterListInOneLineMethods' => false,
          'AllowBeforeEndInOneLineMethods' => true
        }
      end

      it 'registers an offence for a single expression' do
        inspect_source(s,
                       'file.rb',
                       ['puts "this is a test";'])
        expect(s.offences.size).to eq(1)
        expect(s.offences.map(&:message)).to eq([Semicolon::ERROR_MESSAGE])
      end

      it 'registers an offence for several expressions' do
        inspect_source(s,
                       'file.rb',
                       ['puts "this is a test"; puts "So is this"'])
        expect(s.offences.size).to eq(1)
        expect(s.offences.map(&:message)).to eq([Semicolon::ERROR_MESSAGE])
      end

      it 'registers an offence for one line method with two statements' do
        inspect_source(s,
                       'file.rb',
                       ['def foo(a) x(1); y(2); z(3); end'])
        expect(s.offences.size).to eq(2)
      end

      it 'registers an offence for semicolon before end if so configured' do
        Semicolon.config['AllowBeforeEndInOneLineMethods'] = false
        inspect_source(s,
                       'file.rb',
                       ['def foo(a) z(3); end'])
        expect(s.offences.size).to eq(1)
      end

      it 'accepts semicolon before end if so configured' do
        inspect_source(s,
                       'file.rb',
                       ['def foo(a) z(3); end'])
        expect(s.offences).to be_empty
      end

      it 'registers an offence for semicolon after params if so configured' do
        inspect_source(s,
                       'file.rb',
                       ['def foo(a); y(2); z(3) end',
                        'def bar(a) y(2); z(3) end'])
        expect(s.offences.size).to eq(3)
      end

      it 'accepts semicolon after params if so configured' do
        Semicolon.config['AllowAfterParameterListInOneLineMethods'] = true
        inspect_source(s,
                       'file.rb',
                       ['def foo(a); z(3) end'])
        expect(s.offences).to be_empty
      end

      it 'accepts one line method definitions' do
        Semicolon.config['AllowAfterParameterListInOneLineMethods'] = true
        inspect_source(s,
                       'file.rb',
                       ['def foo1; x(3) end',
                        'def initialize(*_); end',
                        'def foo2() x(3); end',
                        'def foo3; x(3); end'])
        expect(s.offences).to be_empty
      end

      it 'accepts one line empty class definitions' do
        inspect_source(s,
                       'file.rb',
                       ['# Prefer a single-line format for class ...',
                        'class Foo < Exception; end',
                        '',
                        'class Bar; end'])
        expect(s.offences).to be_empty
      end

      it 'accepts one line empty method definitions' do
        inspect_source(s,
                       'file.rb',
                       ['# One exception to the rule are empty-body methods',
                        'def no_op; end',
                        '',
                        'def foo; end'])
        expect(s.offences).to be_empty
      end

      it 'accepts one line empty module definitions' do
        inspect_source(s,
                       'file.rb',
                       ['module Foo; end'])
        expect(s.offences).to be_empty
      end

      it 'registers an offence for semicolon at the end no matter what' do
        inspect_source(s,
                       'file.rb',
                       ['module Foo; end;'])
        expect(s.offences.size).to eq(1)
      end
    end
  end
end
