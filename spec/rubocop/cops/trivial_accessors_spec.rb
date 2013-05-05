# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe TrivialAccessors do
      let(:trivial_accessors_finder) { TrivialAccessors.new }

      before :each do
        trivial_accessors_finder.offences.clear
      end

      it 'find trivial reader' do
        inspect_source(trivial_accessors_finder, '',
                       ['def foo',
                        '  @foo',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(1)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([1])
      end

      it 'find trivial reader in a class' do
        inspect_source(trivial_accessors_finder, '',
                       ['class TrivialFoo',
                        '  def foo',
                        '    @foo',
                        '  end',
                        '  def bar',
                        '    !foo',
                        '  end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(1)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([2])
      end

      it 'find trivial reader in a nested class' do
        inspect_source(trivial_accessors_finder, '',
                       ['class TrivialFoo',
                        '  class Nested',
                        '    def foo',
                        '      @foo',
                        '    end',
                        '  end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(1)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([3])
      end

      it 'find trivial readers in a little less trivial class' do
        inspect_source(trivial_accessors_finder, '',
                       ['class TrivialFoo',
                        '  def foo',
                        '    @foo',
                        '  end',
                        '  def foo_and_bar',
                        '    @foo_bar = @foo + @bar',
                        '  end',
                        '  def foo_bar',
                        '    @foo_bar',
                        '  end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(2)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([2, 8])
      end

      it 'does not find a trivial reader' do
        inspect_source(trivial_accessors_finder, '',
                       ['def bar',
                        '  @bar + foo',
                        'end'])
        expect(trivial_accessors_finder.offences).to be_empty
      end

      it 'find trivial writer' do
        inspect_source(trivial_accessors_finder, '',
                       ['def foo=(val)',
                        ' @foo = val',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(1)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([1])
      end

      it 'find trivial writer in a class' do
        inspect_source(trivial_accessors_finder, '',
                       ['class TrivialFoo',
                        '  def foo=(val)',
                        '    @foo = val',
                        '  end',
                        '  def void(no_value)',
                        '  end',
                        '  def inspect(sexp)',
                        '    each(:def, sexp) do |item|',
                        '      #do stuff',
                        '    end',
                        '  end',
                        '  def if_method(foo)',
                        '    if true',
                        '      unless false',
                        '        #do stuff',
                        '      end',
                        '    end',
                        '  end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(1)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([2])
      end

      it 'find trivial accessors in a little less trivial class' do
        inspect_source(trivial_accessors_finder, '',
                       ['class TrivialFoo',
                        ' def foo',
                        ' @foo',
                        ' end',
                        ' def foo_and_bar',
                        ' @foo_bar = @foo + @bar',
                        ' end',
                        ' def foo_bar',
                        ' @foo_bar',
                        ' end',
                        ' def bar=(bar_value)',
                        ' @bar = bar_value',
                        ' end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(3)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([2, 8, 11])
      end

      it 'does not find a trivial writer' do
        inspect_source(trivial_accessors_finder, '',
                       ['def bar=(value)',
                        ' @bar = value + 42',
                        'end'])
        expect(trivial_accessors_finder.offences).to be_empty
      end

      it 'find trivial writers in a little less trivial class' do
        inspect_source(trivial_accessors_finder, '',
                       ['class TrivialFoo',
                        ' def foo_bar=(foo, bar)',
                        ' @foo_bar = foo + bar',
                        ' end',
                        ' def universal=(answer=42)',
                        ' @universal = answer',
                        ' end',
                        ' def bar=(bar_value)',
                        ' @bar = bar_value',
                        ' end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(2)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([5, 8])
      end

      it 'does not find trivial accessors with method calls' do
        inspect_source(trivial_accessors_finder, '',
                       ['class TrivialFoo',
                        ' def foo_bar(foo)',
                        '   foo_bar = foo + 42',
                        ' end',
                        ' def foo(value)',
                        '   foo = []',
                        '   # do stuff',
                        '   foo',
                        ' end',
                        ' def bar',
                        '   foo_method',
                        ' end',
                        'end'])
        expect(trivial_accessors_finder.offences).to be_empty
      end

    end
  end
end
