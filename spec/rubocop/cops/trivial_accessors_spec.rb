# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe TrivialAccessors do
      let(:trivial_accessors_finder) { TrivialAccessors.new }

      before :each do
        trivial_accessors_finder.offences.clear
      end

      it 'finds trivial reader' do
        inspect_source(trivial_accessors_finder, '',
                       ['def foo',
                        '  @foo',
                        'end',
                        '',
                        'def Foo',
                        '  @Foo',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(2)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([1, 5])
      end

      it 'finds trivial reader in a class' do
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

      it 'finds trivial reader in a nested class' do
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

      it 'finds trivial readers in a little less trivial class' do
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
                        '  def foo?',
                        '    foo.present?',
                        '  end',
                        '  def bar?',
                        '    !bar',
                        '  end',
                        '  def foobar',
                        '    foo? ? foo.value : "bar"',
                        '  end',
                        '  def bar',
                        '    foo.bar',
                        '  end',
                        '  def foo_required?',
                        '    super && !bar_required?',
                        '  end',
                        '  def self.from_omniauth(auth)',
                        '    foobars.each do |f|',
                        '      # do stuff',
                        '    end',
                        '  end',
                        '  def regex',
                        '    %r{\A#{visit node}\Z}',
                        '  end',
                        '  def array',
                        '    [foo, bar].join',
                        '  end',
                        '  def string',
                        '    "string"',
                        '  end',
                        '  def class',
                        '    Foo.class',
                        '  end',
                        ' def with_return',
                        '   return foo',
                        ' end',
                        ' def captures',
                        '   (length - 1).times.map { |i| self[i + 1] }',
                        ' end',
                        ' def foo val',
                        '   super',
                        '   @val',
                        ' end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(2)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([2, 8])
      end

      it 'finds trivial reader with braces' do
        inspect_source(trivial_accessors_finder, '',
                       ['class Test',
                        '  # trivial reader with braces',
                        '  def name()',
                        '    @name',
                        '  end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(1)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([3])
      end

      it 'finds trivial writer without braces' do
        inspect_source(trivial_accessors_finder, '',
                       ['class Test',
                        '  # trivial writer without braces',
                        '  def name= name',
                        '    @name = name',
                        '  end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(1)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([3])
      end

      it 'does not find trivial writer with function calls' do
        inspect_source(trivial_accessors_finder, '',
                       ['class TrivialTest',
                        ' def test=(val)',
                        '   @test = val',
                        '   some_function_call',
                        '   or_more_of_them',
                        ' end',
                        'end'])
        expect(trivial_accessors_finder.offences).to be_empty
      end

      it 'finds trivials with less peculiar methods' do
        inspect_source(trivial_accessors_finder, '',
                       ['class NilStats',
                        'def most_traded_pair',
                        'end',
                        'def win_ratio',
                        'end',
                        'def win_ratio_percentage()',
                        'end',
                        'def pips_won',
                        '  0.0',
                        'end',
                        'def gain_at(date)',
                        '  1',
                        'end',
                        'def gain= value',
                        '  @value = 0.1',
                        'end',
                        'def gain_percentage',
                        '  0',
                        'end',
                        'def gain_breakdown(options = {})',
                        '  []',
                        'end',
                        'def copy_to_all_ratio',
                        '  nil',
                        'end',
                        'def trade_population',
                        '  {}',
                        'end',
                        'def average_leverage',
                        '  1',
                        'end',
                        'def with_yield',
                        '  yield',
                        'rescue Error => e',
                        '  #do stuff',
                        'end',
                        'end'])
        expect(trivial_accessors_finder.offences).to be_empty
      end

      it 'finds oneliner trivials' do
        inspect_source(trivial_accessors_finder, '',
                       ['class Oneliner',
                        '  def foo; @foo; end',
                        '  def foo= foo; @foo = foo; end',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(2)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([2, 3])
      end

      it 'does not find a trivial reader' do
        inspect_source(trivial_accessors_finder, '',
                       ['def bar',
                        '  @bar + foo',
                        'end'])
        expect(trivial_accessors_finder.offences).to be_empty
      end

      it 'finds trivial writer' do
        inspect_source(trivial_accessors_finder, '',
                       ['def foo=(val)',
                        ' @foo = val',
                        'end'])
        expect(trivial_accessors_finder.offences.size).to eq(1)
        expect(trivial_accessors_finder.offences
                 .map(&:line_number).sort).to eq([1])
      end

      it 'finds trivial writer in a class' do
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

      it 'finds trivial accessors in a little less trivial class' do
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

      it 'finds trivial writers in a little less trivial class' do
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

      it 'does not find trivial writer with exceptions' do
        inspect_source(trivial_accessors_finder, '',
                       [' def expiration_formatted=(value)',
                        '   begin',
                        '     @expiration = foo_stuff',
                        '   rescue ArgumentError',
                        '     @expiration = nil',
                        '   end',
                        '   self[:expiration] = @expiration',
                        ' end'])
        expect(trivial_accessors_finder.offences).to be_empty
      end

    end # describe TrivialAccessors
  end # Cop
end # Rubocop
