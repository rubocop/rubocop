# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::TrivialAccessors, :config do
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
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses
            .map(&:line).sort).to eq([1, 5])
    expect(cop.messages)
      .to eq(['Use `attr_reader` to define trivial reader methods.'] * 2)
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
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
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
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
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
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
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
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses
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
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
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
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses .map(&:line).sort).to eq([3])
    expect(cop.messages)
      .to eq(['Use `attr_writer` to define trivial writer methods.'])
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
    expect(cop.offenses).to be_empty
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
    expect(cop.offenses).to be_empty
  end

  it 'treats splats as non-trivial' do
    inspect_source(cop,
                   [' def splatomatic(*values)',
                    '   @splatomatic = values',
                    ' end'])
    expect(cop.offenses).to be_empty
  end

  it 'finds oneliner trivials' do
    inspect_source(cop,
                   ['class Oneliner',
                    '  def foo; @foo; end',
                    '  def foo= foo; @foo = foo; end',
                    'end'])
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses
             .map(&:line).sort).to eq([2, 3])
  end

  it 'does not find a trivial reader' do
    inspect_source(cop,
                   ['def bar',
                    '  @bar + foo',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'finds trivial writer' do
    inspect_source(cop,
                   ['def foo=(val)',
                    ' @foo = val',
                    'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
             .map(&:line).sort).to eq([1])
  end

  it 'finds DSL-style trivial writer' do
    inspect_source(cop,
                   ['def foo(val)',
                    ' @foo = val',
                    'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
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
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
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
    expect(cop.offenses.size).to eq(3)
    expect(cop.offenses
             .map(&:line).sort).to eq([2, 8, 11])
  end

  it 'does not find a trivial writer' do
    inspect_source(cop,
                   ['def bar=(value)',
                    ' @bar = value + 42',
                    'end'])
    expect(cop.offenses).to be_empty
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
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses
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
    expect(cop.offenses).to be_empty
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
    expect(cop.offenses).to be_empty
  end

  it 'accepts an initialize method looking like a writer' do
    inspect_source(cop,
                   [' def initialize(value)',
                    '   @top = value',
                    ' end'])
    expect(cop.offenses).to be_empty
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
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses
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
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses
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
      expect(cop.offenses).to be_empty
    end
  end

  context 'with whitelist defined' do
    let(:cop_config) { { 'Whitelist' => ['to_foo', 'bar='] } }

    it 'ignores accessors in the whitelist' do
      inspect_source(cop,
                     [' def to_foo',
                      '   @foo',
                      ' end'])
      expect(cop.offenses).to be_empty
    end
    it 'ignores writers in the whitelist' do
      inspect_source(cop,
                     [' def bar=(bar)',
                      '   @bar = bar',
                      ' end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'with DSL writers allowed' do
    let(:cop_config) { { 'AllowDSLWriters' => true } }

    it 'does not find DSL-style writer' do
      inspect_source(cop,
                     ['def foo(val)',
                      ' @foo = val',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  describe '#autocorrect' do
    context 'matching reader' do
      let(:source) do
        ['def foo',
         '  @foo',
         'end']
      end

      let(:corrected_source) { 'attr_reader :foo' }

      it 'autocorrects' do
        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end

    context 'non-matching reader' do
      let(:source) do
        ['def foo',
         '  @bar',
         'end']
      end

      it 'does not autocorrect' do
        expect(autocorrect_source(cop, source))
          .to eq(source.join("\n"))
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'matching non-DSL writer' do
      let(:source) do
        ['def foo=(f)',
         '  @foo=f',
         'end']
      end

      let(:corrected_source) { 'attr_writer :foo' }

      it 'autocorrects' do
        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end

    context 'matching DSL-style writer' do
      let(:source) do
        ['def foo(f)',
         '  @foo=f',
         'end']
      end

      it 'does not autocorrect' do
        expect(autocorrect_source(cop, source))
          .to eq(source.join("\n"))
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'explicit receiver writer' do
      let(:source) do
        ['def derp.foo=(f)',
         '  @foo=f',
         'end']
      end

      it 'does not autocorrect' do
        expect(autocorrect_source(cop, source))
          .to eq(source.join("\n"))
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'class receiver reader' do
      let(:source) do
        ['class Foo',
         '  def self.foo',
         '    @foo',
         '  end',
         'end']
      end

      let(:corrected_source) do
        ['class Foo',
         '  class << self',
         '    attr_reader :foo',
         '  end',
         'end']
      end

      it 'autocorrects with class-level attr_reader' do
        expect(autocorrect_source(cop, source))
          .to eq(corrected_source.join("\n"))
      end
    end

    context 'class receiver writer' do
      let(:source) do
        ['class Foo',
         '  def self.foo=(f)',
         '    @foo = f',
         '  end',
         'end']
      end

      let(:corrected_source) do
        ['class Foo',
         '  class << self',
         '    attr_writer :foo',
         '  end',
         'end']
      end

      it 'autocorrects with class-level attr_writer' do
        expect(autocorrect_source(cop, source))
          .to eq(corrected_source.join("\n"))
      end
    end
  end
end
