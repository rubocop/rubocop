# frozen_string_literal: true

describe RuboCop::Cop::Lint::NestedMethodDefinition do
  subject(:cop) { described_class.new }

  it 'registers an offense for a nested method definition' do
    inspect_source(cop, 'def x; def y; end; end')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a nested singleton method definition' do
    inspect_source(cop, ['class Foo',
                         'end',
                         'foo = Foo.new',
                         'def foo.bar',
                         '  def baz',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a nested method definition inside lambda' do
    inspect_source(cop, ['def foo',
                         '  bar = -> { def baz; puts; end }',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a nested class method definition' do
    inspect_source(cop, ['class Foo',
                         '  def self.x',
                         '    def self.y',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for a lambda definition inside method' do
    inspect_source(cop, ['def foo',
                         '  bar = -> { puts  }',
                         '  bar.call',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for nested definition inside instance_eval' do
    inspect_source(cop, ['class Foo',
                         '  def x(obj)',
                         '    obj.instance_eval do',
                         '      def y',
                         '      end',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for nested definition inside instance_exec' do
    inspect_source(cop, ['class Foo',
                         '  def x(obj)',
                         '    obj.instance_exec do',
                         '      def y',
                         '      end',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for definition of method on local var' do
    inspect_source(cop, ['class Foo',
                         '  def x(obj)',
                         '    def obj.y',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for nested definition inside class_eval' do
    inspect_source(cop, ['class Foo',
                         '  def x(klass)',
                         '    klass.class_eval do',
                         '      def y',
                         '      end',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for nested definition inside class_exec' do
    inspect_source(cop, ['class Foo',
                         '  def x(klass)',
                         '    klass.class_exec do',
                         '      def y',
                         '      end',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for nested definition inside module_eval' do
    inspect_source(cop, ['class Foo',
                         '  def self.define(mod)',
                         '    mod.module_eval do',
                         '      def y',
                         '      end',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for nested definition inside module_eval' do
    inspect_source(cop, ['class Foo',
                         '  def self.define(mod)',
                         '    mod.module_exec do',
                         '      def y',
                         '      end',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for nested definition inside Class.new' do
    ['(S)', ''].each do |constructor_args|
      inspect_source(cop, ['class Foo',
                           '  def self.define',
                           "    Class.new#{constructor_args} do",
                           '      def y',
                           '      end',
                           '    end',
                           '  end',
                           'end'])
      expect(cop.offenses).to be_empty
    end
  end

  it 'does not register offense for nested definition inside Module.new' do
    inspect_source(cop, ['class Foo',
                         '  def self.define',
                         '    Module.new do',
                         '      def y',
                         '      end',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for nested definition inside Struct.new' do
    ['(:name)', ''].each do |constructor_args|
      inspect_source(cop, ['class Foo',
                           '  def self.define',
                           "    Struct.new#{constructor_args} do",
                           '      def y',
                           '      end',
                           '    end',
                           '  end',
                           'end'])
      expect(cop.offenses).to be_empty
    end
  end
end
