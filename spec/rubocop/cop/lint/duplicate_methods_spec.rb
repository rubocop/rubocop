# frozen_string_literal: true

describe RuboCop::Cop::Lint::DuplicateMethods do
  subject(:cop) { described_class.new }

  shared_examples 'in scope' do |type, opening_line|
    it "registers an offense for duplicate method in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  def some_method',
                      '    implement 1',
                      '  end',
                      '  def some_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "doesn't register an offense for non-duplicate method in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  def some_method',
                      '    implement 1',
                      '  end',
                      '  def any_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it "registers an offense for duplicate class methods in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  def self.some_method',
                      '    implement 1',
                      '  end',
                      '  def self.some_method',
                      '    implement 2',
                      '  end',
                      'end'], 'src.rb')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Method `A.some_method` is defined at both src.rb:2 and src.rb:5.']
      )
    end

    it "doesn't register offense for non-duplicate class methods in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  def self.some_method',
                      '    implement 1',
                      '  end',
                      '  def self.any_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it "recognizes difference between instance and class methods in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  def some_method',
                      '    implement 1',
                      '  end',
                      '  def self.some_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it "registers an offense for duplicate private methods in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  private def some_method',
                      '    implement 1',
                      '  end',
                      '  private def some_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for duplicate private self methods in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  private def self.some_method',
                      '    implement 1',
                      '  end',
                      '  private def self.some_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "doesn't register an offense for different private methods in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  private def some_method',
                      '    implement 1',
                      '  end',
                      '  private def any_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it "registers an offense for duplicate protected methods in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  protected def some_method',
                      '    implement 1',
                      '  end',
                      '  protected def some_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers 2 offenses for pair of duplicate methods in #{type}" do
      inspect_source(cop,
                     [opening_line,
                      '  def some_method',
                      '    implement 1',
                      '  end',
                      '  def some_method',
                      '    implement 2',
                      '  end',
                      '  def any_method',
                      '    implement 1',
                      '  end',
                      '  def any_method',
                      '    implement 2',
                      '  end',
                      'end'], 'dups.rb')
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages).to contain_exactly(
        'Method `A#any_method` is defined at both dups.rb:8 and dups.rb:11.',
        'Method `A#some_method` is defined at both dups.rb:2 and dups.rb:5.'
      )
    end

    it 'registers an offense for a duplicate instance method in separate ' \
       "#{type} blocks" do
      inspect_source(cop,
                     [opening_line,
                      '  def some_method',
                      '    implement 1',
                      '  end',
                      'end',
                      opening_line,
                      '  def some_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for a duplicate class method in separate ' \
       "#{type} blocks" do
      inspect_source(cop,
                     [opening_line,
                      '  def self.some_method',
                      '    implement 1',
                      '  end',
                      'end',
                      opening_line,
                      '  def self.some_method',
                      '    implement 2',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers offense for a duplicate instance method in separate files' do
      inspect_source(cop,
                     [opening_line,
                      '  def some_method',
                      '    implement 1',
                      '  end',
                      'end'], 'first.rb')
      inspect_source(cop,
                     [opening_line,
                      '  def some_method',
                      '    implement 2',
                      '  end',
                      'end'], 'second.rb')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Method `A#some_method` is defined at both ' \
                                  'first.rb:2 and second.rb:2.'])
    end

    it 'understands class << self' do
      inspect_source(cop,
                     [opening_line,
                      '  class << self',
                      '    def some_method',
                      '      implement 1',
                      '    end',
                      '    def some_method',
                      '      implement 2',
                      '    end',
                      '  end',
                      'end'], 'test.rb')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Method `A.some_method` is defined at both test.rb:3 and test.rb:6.']
      )
    end

    it 'understands nested modules' do
      inspect_source(cop,
                     ['module B',
                      "  #{opening_line}",
                      '    def some_method',
                      '      implement 1',
                      '    end',
                      '    def some_method',
                      '      implement 2',
                      '    end',
                      '    def self.another',
                      '    end',
                      '    def self.another',
                      '    end',
                      '  end',
                      'end'], 'test.rb')
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages).to eq(
        ['Method `B::A#some_method` is defined at both test.rb:3 and ' \
         'test.rb:6.',
         'Method `B::A.another` is defined at both test.rb:9 and test.rb:11.']
      )
    end

    it "doesn't register an offense when class << exp is used" do
      inspect_source(cop,
                     [opening_line,
                      '  class << blah',
                      '    def some_method',
                      '      implement 1',
                      '    end',
                      '    def some_method',
                      '      implement 2',
                      '    end',
                      '  end',
                      'end'], 'test.rb')
      expect(cop.offenses).to be_empty
    end
  end

  include_examples('in scope', 'class', 'class A')
  include_examples('in scope', 'module', 'module A')
  include_examples('in scope', 'dynamic class', 'A = Class.new do')
  include_examples('in scope', 'dynamic module', 'A = Module.new do')
  include_examples('in scope', 'class_eval block', 'A.class_eval do')

  it 'registers an offense for duplicate methods at top level' do
    inspect_source(cop,
                   ['  def some_method',
                    '    implement 1',
                    '  end',
                    '  def some_method',
                    '    implement 2',
                    '  end'], 'toplevel.rb')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Method `Object#some_method` is defined at both toplevel.rb:1 and ' \
       'toplevel.rb:4.']
    )
  end

  it 'understands class << A' do
    inspect_source(cop,
                   ['class << A',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def some_method',
                    '    implement 2',
                    '  end',
                    'end'], 'test.rb')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Method `A.some_method` is defined at both test.rb:2 and test.rb:5.']
    )
  end

  it 'handles class_eval with implicit receiver' do
    inspect_source(cop, ['module A',
                         '  class_eval do',
                         '    def some_method',
                         '      implement 1',
                         '    end',
                         '    def some_method',
                         '      implement 2',
                         '    end',
                         '  end',
                         'end'], 'test.rb')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Method `A#some_method` is defined at both test.rb:3 and test.rb:6.']
    )
  end

  it 'ignores method definitions in RSpec `describe` blocks' do
    inspect_source(cop,
                   ['describe "something" do',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def some_method',
                    '    implement 2',
                    '  end',
                    'end'], 'test.rb')
    expect(cop.offenses).to be_empty
  end

  it 'ignores Class.new blocks which are assigned to local variables' do
    inspect_source(cop, ['a = Class.new do',
                         '  def foo',
                         '  end',
                         'end',
                         'b = Class.new do',
                         '  def foo',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
