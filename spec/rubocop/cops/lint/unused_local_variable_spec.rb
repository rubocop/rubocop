# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe UnusedLocalVariable do
        subject(:cop) { UnusedLocalVariable.new }

        context 'when a variable is assigned and unreferenced in a method' do
          let(:source) do
            [
              'class SomeClass',
              '  foo = 1',
              '  puts foo',
              '  def some_method',
              '    foo = 2',
              '    bar = 3',
              '    puts bar',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(5)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned and unreferenced ' +
                'in a singleton method defined with self keyword' do
          let(:source) do
            [
              'class SomeClass',
              '  foo = 1',
              '  puts foo',
              '  def self.some_method',
              '    foo = 2',
              '    bar = 3',
              '    puts bar',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(5)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned and unreferenced ' +
                'in a singleton method defined with variable name' do
          let(:source) do
            [
              '1.times do',
              '  foo = 1',
              '  puts foo',
              '  instance = Object.new',
              '  def instance.some_method',
              '    foo = 2',
              '    bar = 3',
              '    puts bar',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(6)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned and unreferenced in a class' do
          let(:source) do
            [
              '1.times do',
              '  foo = 1',
              '  puts foo',
              '  class SomeClass',
              '    foo = 2',
              '    bar = 3',
              '    puts bar',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(5)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned and unreferenced ' +
                'in a singleton class' do
          let(:source) do
            [
              '1.times do',
              '  foo = 1',
              '  puts foo',
              '  instance = Object.new',
              '  class << instance',
              '    foo = 2',
              '    bar = 3',
              '    puts bar',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(6)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned and unreferenced in a module' do
          let(:source) do
            [
              '1.times do',
              '  foo = 1',
              '  puts foo',
              '  module SomeModule',
              '    foo = 2',
              '    bar = 3',
              '    puts bar',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(5)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned and unreferenced in top level' do
          let(:source) do
            [
              'foo = 1',
              'bar = 2',
              'puts bar'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(1)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned multiple times ' +
                'but unreferenced' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  bar = 2',
              '  foo = 3',
              '  puts bar',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when an unreferenced variable is reassigned in a block' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  1.times do',
              '    foo = 2',
              '  end',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a referenced variable in reassigned in a block' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  puts foo',
              '  1.times do',
              '    foo = 2',
              '  end',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a block local variable is declared but not assigned' do
          let(:source) do
            [
              '1.times do |i; foo|',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(1)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a block local variable is assigned and unreferenced' do
          let(:source) do
            [
              '1.times do |i; foo|',
              '  foo = 2',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a named capture is unreferenced in top level' do
          let(:source) do
            [
              "/(?<foo>\w+)/ =~ 'FOO'",
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(1)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a named capture is unreferenced ' +
                'in other than top level' do
          let(:source) do
            [
              'def some_method',
              "  /(?<foo>\w+)/ =~ 'FOO'",
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(2)
          end

          # MRI 2.0 accepts this case, but I have no idea why it does so
          # and there's no convincing reason to conform to this behavior,
          # so RuboCop does not mimic MRI in this case.
        end

        context 'when a named capture is referenced' do
          let(:source) do
            [
              'def some_method',
              "  /(?<foo>\w+)/ =~ 'bar'",
              '  puts foo',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned in begin ' +
                'and referenced outside' do
          let(:source) do
            [
              'def some_method',
              '  begin',
              '    foo = 1',
              '  end',
              '  puts foo',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is shadowed by a block argument ' +
                'and unreferenced' do
          let(:source) do
            [
              'def some_method',
              '  foo = 1',
              '  1.times do |foo|',
              '    puts foo',
              '  end',
              'end'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(2)
          end

          include_examples 'mimics MRI 2.0', 'unused variable'
        end

        context 'when a variable is not used and the name starts with _' do
          let(:source) do
            [
              'def some_method',
              '  _foo = 1',
              '  bar = 2',
              '  puts bar',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a method argument is not used' do
          let(:source) do
            [
              'def some_method(arg)',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when an optional method argument is not used' do
          let(:source) do
            [
              'def some_method(arg = nil)',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a block method argument is not used' do
          let(:source) do
            [
              'def some_method(&block)',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a splat method argument is not used' do
          let(:source) do
            [
              'def some_method(*args)',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a optional keyword method argument is not used' do
          let(:source) do
            [
              'def some_method(name: value)',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a keyword splat method argument is used' do
          let(:source) do
            [
              'def some_method(name: value, **rest_keywords)',
              '  p rest_keywords',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a keyword splat method argument is not used' do
          let(:source) do
            [
              'def some_method(name: value, **rest_keywords)',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when a block argument is not used' do
          let(:source) do
            [
              '1.times do |i|',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end

        context 'when there is only one AST node and it is unused variable' do
          let(:source) do
            [
              'foo = 1'
            ]
          end

          it 'registers an offence' do
            inspect_source(cop, source)
            expect(cop.offences).to have(1).item
            expect(cop.offences.first.message)
              .to include('unused variable - foo')
            expect(cop.offences.first.line).to eq(1)
          end

          include_examples 'mimics MRI 2.0'
        end

        context 'when a variable is assigned ' +
                'while being passed to a method taking block' do

          context 'and the variable is used' do
            let(:source) do
              [
                'some_method(foo = 1) do',
                'end',
                'puts foo'
              ]
            end

            include_examples 'accepts'
            include_examples 'mimics MRI 2.0'
          end

          context 'and the variable is not used' do
            let(:source) do
              [
                'some_method(foo = 1) do',
                'end'
              ]
            end

            it 'registers an offence' do
              inspect_source(cop, source)
              expect(cop.offences).to have(1).item
              expect(cop.offences.first.message)
                .to include('unused variable - foo')
              expect(cop.offences.first.line).to eq(1)
            end

            include_examples 'mimics MRI 2.0'
          end
        end

        context 'when a variabled is assigned ' +
                'and passed to a method followed by method taking block'  do
          let(:source) do
            [
              "pattern = '*.rb'",
              'Dir.glob(pattern).map do |path|',
              'end'
            ]
          end

          include_examples 'accepts'
          include_examples 'mimics MRI 2.0'
        end
      end
    end
  end
end
