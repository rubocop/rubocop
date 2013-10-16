# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::TrivialAccessors, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { {} }

  it 'finds trivial reader' do
    inspect_source(cop,
                   ['def foo',
                    '  @foo',
                    'end',
                    '',
                    'def Foo',
                    '  @Foo',
                    'end'])
    expect(cop.offences.size).to eq(2)
    expect(cop.offences
             .map(&:line).sort).to eq([1, 5])
  end

  it 'finds trivial reader in a class' do
    inspect_source(cop,
                   ['class TrivialFoo',
                    '  def foo',
                    '    @foo',
                    '  end',
                    '  def bar',
                    '    !foo',
                    '  end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.offences
             .map(&:line).sort).to eq([2])
  end

  it 'finds trivial reader in a class method' do
    inspect_source(cop,
                   ['class TrivialFoo',
                    '  def self.foo',
                    '    @foo',
                    '  end',
                    '  def bar',
                    '    !foo',
                    '  end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.offences
             .map(&:line).sort).to eq([2])
  end

  it 'finds trivial reader in a nested class' do
    inspect_source(cop,
                   ['class TrivialFoo',
                    '  class Nested',
                    '    def foo',
                    '      @foo',
                    '    end',
                    '  end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.offences
             .map(&:line).sort).to eq([3])
  end

  it 'finds trivial readers in a little less trivial class' do
    inspect_source(cop,
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
    expect(cop.offences.size).to eq(2)
    expect(cop.offences
             .map(&:line).sort).to eq([2, 8])
  end

  it 'finds trivial reader with braces' do
    inspect_source(cop,
                   ['class Test',
                    '  # trivial reader with braces',
                    '  def name()',
                    '    @name',
                    '  end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.offences
             .map(&:line).sort).to eq([3])
  end

  it 'finds trivial writer without braces' do
    inspect_source(cop,
                   ['class Test',
                    '  # trivial writer without braces',
                    '  def name= name',
                    '    @name = name',
                    '  end',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.offences
             .map(&:line).sort).to eq([3])
  end

  it 'does not find trivial writer with function calls' do
    inspect_source(cop,
                   ['class TrivialTest',
                    ' def test=(val)',
                    '   @test = val',
                    '   some_function_call',
                    '   or_more_of_them',
                    ' end',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'finds trivials with less peculiar methods' do
    inspect_source(cop,
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
    expect(cop.offences).to be_empty
  end

  it 'treats splats as non-trivial' do
    inspect_source(cop,
                   [' def splatomatic(*values)',
                    '   @splatomatic = values',
                    ' end'])
    expect(cop.offences).to be_empty
  end

  it 'finds oneliner trivials' do
    inspect_source(cop,
                   ['class Oneliner',
                    '  def foo; @foo; end',
                    '  def foo= foo; @foo = foo; end',
                    'end'])
    expect(cop.offences.size).to eq(2)
    expect(cop.offences
             .map(&:line).sort).to eq([2, 3])
  end

  it 'does not find a trivial reader' do
    inspect_source(cop,
                   ['def bar',
                    '  @bar + foo',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'finds trivial writer' do
    inspect_source(cop,
                   ['def foo=(val)',
                    ' @foo = val',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.offences
             .map(&:line).sort).to eq([1])
  end

  it 'finds trivial writer in a class' do
    inspect_source(cop,
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
    expect(cop.offences.size).to eq(1)
    expect(cop.offences
             .map(&:line).sort).to eq([2])
  end

  it 'finds trivial accessors in a little less trivial class' do
    inspect_source(cop,
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
    expect(cop.offences.size).to eq(3)
    expect(cop.offences
             .map(&:line).sort).to eq([2, 8, 11])
  end

  it 'does not find a trivial writer' do
    inspect_source(cop,
                   ['def bar=(value)',
                    ' @bar = value + 42',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'finds trivial writers in a little less trivial class' do
    inspect_source(cop,
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
    expect(cop.offences.size).to eq(2)
    expect(cop.offences
             .map(&:line).sort).to eq([5, 8])
  end

  it 'does not find trivial accessors with method calls' do
    inspect_source(cop,
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
    expect(cop.offences).to be_empty
  end

  it 'does not find trivial writer with exceptions' do
    inspect_source(cop,
                   [' def expiration_formatted=(value)',
                    '   begin',
                    '     @expiration = foo_stuff',
                    '   rescue ArgumentError',
                    '     @expiration = nil',
                    '   end',
                    '   self[:expiration] = @expiration',
                    ' end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts an initialize method looking like a writer' do
    inspect_source(cop,
                   [' def initialize(value)',
                    '   @top = value',
                    ' end'])
    expect(cop.offences).to be_empty
  end

  context 'exact name match required' do
    let(:cop_config) { { 'ExactNameMatch' => true } }

    it 'finds only 1 trivial reader' do
      inspect_source(cop,
                     ['def foo',
                      '  @foo',
                      'end',
                      '',
                      'def bar',
                      '  @barr',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.offences
               .map(&:line).sort).to eq([1])
    end

    it 'finds only 1 trivial writer' do
      inspect_source(cop,
                     ['def foo=(foo)',
                      '  @foo = foo',
                      'end',
                      '',
                      'def bar=(bar)',
                      '  @barr = bar',
                      'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.offences
               .map(&:line).sort).to eq([1])
    end
  end

  context 'with predicates allowed' do
    let(:cop_config) { { 'AllowPredicates' => true } }

    it 'ignores accessors ending with a question mark' do
      inspect_source(cop,
                     [' def foo?',
                      '   @foo',
                      ' end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with whitelist defined' do
    let(:cop_config) { { 'Whitelist' => ['to_foo', 'bar='] } }

    it 'ignores accessors in the whitelist' do
      inspect_source(cop,
                     [' def to_foo',
                      '   @foo',
                      ' end'])
      expect(cop.offences).to be_empty
    end
    it 'ignores writers in the whitelist' do
      inspect_source(cop,
                     [' def bar=(bar)',
                      '   @bar = bar',
                      ' end'])
      expect(cop.offences).to be_empty
    end
  end
end
