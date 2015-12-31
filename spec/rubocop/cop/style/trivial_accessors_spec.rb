# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::TrivialAccessors, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { {} }

  let(:trivial_reader) do
    ['def foo',
     '  @foo',
     'end']
  end

  let(:trivial_writer) do
    ['def foo=(val)',
     '  @foo = val',
     'end']
  end

  it 'registers an offense on instance reader' do
    inspect_source(cop, trivial_reader)
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense on instance writer' do
    inspect_source(cop, trivial_writer)
    expect(cop.offenses.size).to eq(1)
  end

  it 'show correct message on reader' do
    inspect_source(cop, trivial_reader)
    expect(cop.messages.first)
      .to eq('Use `attr_reader` to define trivial reader methods.')
  end

  it 'show correct message on writer' do
    inspect_source(cop, trivial_writer)
    expect(cop.messages.first)
      .to eq('Use `attr_writer` to define trivial writer methods.')
  end

  it 'registers an offense on class reader' do
    inspect_source(cop, ['def self.foo',
                         '  @foo',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense on class writer' do
    inspect_source(cop, ['def self.foo(val)',
                         '  @foo = val',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense on reader with braces' do
    inspect_source(cop, ['def foo()',
                         '  @foo',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense on writer without braces' do
    inspect_source(cop, ['def foo= val',
                         '  @foo = val',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense on one-liner reader' do
    inspect_source(cop, 'def foo; @foo; end')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense on one-liner writer' do
    inspect_source(cop, 'def foo(val); @foo=val; end')
    expect(cop.offenses.size).to eq(1)
  end

  it 'register an offense on DSL-style trivial writer' do
    inspect_source(cop,
                   ['def foo(val)',
                    ' @foo = val',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts non-trivial reader' do
    inspect_source(cop,
                   ['def test',
                    '  some_function_call',
                    '  @test',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts non-trivial writer' do
    inspect_source(cop,
                   ['def test(val)',
                    '  some_function_call(val)',
                    '  @test = val',
                    '  log(val)',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts splats' do
    inspect_source(cop,
                   ['def splatomatic(*values)',
                    '  @splatomatic = values',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts blocks' do
    inspect_source(cop,
                   ['def something(&block)',
                    '  @b = block',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts expressions within reader' do
    inspect_source(cop,
                   ['def bar',
                    '  @bar + foo',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts expressions within writer' do
    inspect_source(cop,
                   ['def bar(val)',
                    '  @bar = val + foo',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts an initialize method looking like a writer' do
    inspect_source(cop,
                   [' def initialize(value)',
                    '   @top = value',
                    ' end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts reader with different ivar name' do
    inspect_source(cop,
                   ['def foo',
                    '  @fo',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts writer with different ivar name' do
    inspect_source(cop,
                   ['def foo(val)',
                    '  @fo = val',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts writer in a module' do
    inspect_source(cop,
                   ['module Foo',
                    '  def bar=(bar)',
                    '    @bar = bar',
                    '  end',
                    'end'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts writer nested within a module' do
    inspect_source(cop,
                   ['module Foo',
                    '  begin',
                    '    if RUBY_VERSION > "2.0"',
                    '      def bar=(bar)',
                    '        @bar = bar',
                    '      end',
                    '    end',
                    '  end',
                    'end'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts reader nested within a module' do
    inspect_source(cop,
                   ['module Foo',
                    '  begin',
                    '    if RUBY_VERSION > "2.0"',
                    '      def bar',
                    '        @bar',
                    '      end',
                    '    end',
                    '  end',
                    'end'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts writer nested within an instance_eval call' do
    inspect_source(cop,
                   ['something.instance_eval do',
                    '  begin',
                    '    if RUBY_VERSION > "2.0"',
                    '      def bar=(bar)',
                    '        @bar = bar',
                    '      end',
                    '    end',
                    '  end',
                    'end'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts reader nested within an instance_eval calll' do
    inspect_source(cop,
                   ['something.instance_eval do',
                    '  begin',
                    '    if RUBY_VERSION > "2.0"',
                    '      def bar',
                    '        @bar',
                    '      end',
                    '    end',
                    '  end',
                    'end'])

    expect(cop.offenses).to be_empty
  end

  it 'flags a reader inside a class, inside an instance_eval call' do
    inspect_source(cop,
                   ['something.instance_eval do',
                    '  class << @blah',
                    '    begin',
                    '      def bar',
                    '        @bar',
                    '      end',
                    '    end',
                    '  end',
                    'end'])

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Use `attr_reader` to define trivial reader methods.'])
  end
  context 'exact name match disabled' do
    let(:cop_config) { { 'ExactNameMatch' => false } }

    it 'registers an offense when names mismatch in writer' do
      inspect_source(cop, ['def foo(val)',
                           '  @f = val',
                           'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense when names mismatch in reader' do
      inspect_source(cop, ['def foo',
                           '  @f',
                           'end'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'disallow predicates' do
    let(:cop_config) { { 'AllowPredicates' => false } }

    it 'does not accept predicate-like reader' do
      inspect_source(cop,
                     ['def foo?',
                      '  @foo',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'allow predicates' do
    let(:cop_config) { { 'AllowPredicates' => true } }

    it 'accepts predicate-like reader' do
      inspect_source(cop,
                     ['def foo?',
                      '  @foo',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'with whitelist' do
    let(:cop_config) { { 'Whitelist' => ['to_foo', 'bar='] } }

    it 'accepts whitelisted reader' do
      inspect_source(cop,
                     [' def to_foo',
                      '   @foo',
                      ' end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts whitelisted writer' do
      inspect_source(cop,
                     [' def bar=(bar)',
                      '   @bar = bar',
                      ' end'])
      expect(cop.offenses).to be_empty
    end

    context 'with AllowPredicates: false' do
      let(:cop_config) do
        { 'AllowPredicates' => false,
          'Whitelist' => ['foo?'] }
      end

      it 'accepts whitelisted predicate' do
        inspect_source(cop,
                       [' def foo?',
                        '   @foo',
                        ' end'])
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'with DSL allowed' do
    let(:cop_config) { { 'AllowDSLWriters' => true } }

    it 'accepts DSL-style writer' do
      inspect_source(cop,
                     ['def foo(val)',
                      ' @foo = val',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'ignore class methods' do
    let(:cop_config) { { 'IgnoreClassMethods' => true } }

    it 'accepts class reader' do
      inspect_source(cop,
                     ['def self.foo',
                      '  @foo',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts class writer' do
      inspect_source(cop,
                     ['def self.foo(val)',
                      '  @foo = val',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  describe '#autocorrect' do
    context 'trivial reader' do
      let(:source) { trivial_reader }

      let(:corrected_source) { 'attr_reader :foo' }

      it 'autocorrects' do
        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end

    context 'non-matching reader' do
      let(:cop_config) { { 'ExactNameMatch' => false } }

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

    context 'predicate reader, with AllowPredicates: false' do
      let(:cop_config) { { 'AllowPredicates' => false } }
      let(:source) do
        ['def foo?',
         '  @foo',
         'end']
      end

      it 'does not autocorrect' do
        expect(autocorrect_source(cop, source)).to eq(source.join("\n"))
        expect(cop.offenses.map(&:corrected?)).to eq [false]
      end
    end

    context 'trivial writer' do
      let(:source) { trivial_writer }

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
