# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::UselessAccessModifier do
  subject(:cop) { described_class.new }

  context 'when an access modifier has no effect' do
    let(:source) do
      [
        'class SomeClass',
        '  def some_method',
        '    puts 10',
        '  end',
        '  private',
        '  def self.some_method',
        '    puts 10',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `private` access modifier.')
      expect(cop.offenses.first.line).to eq(5)
      expect(cop.highlights).to eq(['private'])
    end
  end

  context 'when an access modifier has no methods' do
    let(:source) do
      [
        'class SomeClass',
        '  def some_method',
        '    puts 10',
        '  end',
        '  protected',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `protected` access modifier.')
      expect(cop.offenses.first.line).to eq(5)
      expect(cop.highlights).to eq(['protected'])
    end
  end

  context 'when an access modifier is followed by attr_*' do
    let(:source) do
      [
        'class SomeClass',
        '  protected',
        '  attr_accessor :some_property',
        '  public',
        '  attr_reader :another_one',
        '  private',
        '  attr :yet_again, true',
        '  protected',
        '  attr_writer :just_for_good_measure',
        'end'
      ]
    end

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'when an access modifier is followed by a ' \
    'class method defined on constant' do
    let(:source) do
      [
        'class SomeClass',
        '  protected',
        '  def SomeClass.some_method',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `protected` access modifier.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['protected'])
    end
  end

  context 'when consecutive access modifiers' do
    let(:source) do
      [
        'class SomeClass',
        ' private',
        ' private',
        '  def some_method',
        '    puts 10',
        '  end',
        '  def some_other_method',
        '    puts 10',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `private` access modifier.')
      expect(cop.offenses.first.line).to eq(3)
      expect(cop.highlights).to eq(['private'])
    end
  end

  context 'when passing method as symbol' do
    let(:source) do
      [
        'class SomeClass',
        '  def some_method',
        '    puts 10',
        '  end',
        '  private :some_method',
        'end'
      ]
    end

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'when class is empty save modifier' do
    let(:source) do
      [
        'class SomeClass',
        '  private',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `private` access modifier.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['private'])
    end
  end

  context 'when multiple class definitions in file but only one has offense' do
    let(:source) do
      [
        'class SomeClass',
        '  private',
        'end',
        'class SomeOtherClass',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `private` access modifier.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['private'])
    end
  end

  if RUBY_ENGINE == 'ruby' && RUBY_VERSION.start_with?('2.1')
    context 'ruby 2.1 style modifiers' do
      let(:source) do
        [
          'class SomeClass',
          '  private def some_method',
          '    puts 10',
          '  end',
          'end'
        ]
      end

      it 'does not register an offense' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(0)
      end
    end
  end

  shared_examples 'at the top of the body' do |keyword|
    it 'registers an offense for `public`' do
      src = ["#{keyword} A",
             '  public',
             '  def method',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it "doesn't register an offense for `protected`" do
      src = ["#{keyword} A",
             '  protected',
             '  def method',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it "doesn't register an offense for `private`" do
      src = ["#{keyword} A",
             '  private',
             '  def method',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples 'repeated visibility modifiers' do |keyword, modifier|
    it "registers an offense when `#{modifier}` is repeated" do
      src = ["#{keyword} A",
             "  #{modifier == 'private' ? 'protected' : 'private'}",
             '  def method1',
             '  end',
             "  #{modifier}",
             "  #{modifier}",
             '  def method2',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end
  end

  shared_examples 'non-repeated visibility modifiers' do |keyword|
    it 'registers an offense even when `public` is not repeated' do
      src = ["#{keyword} A",
             '  def method1',
             '  end',
             '  public',
             '  def method2',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it "doesn't register an offense when `protected` is not repeated" do
      src = ["#{keyword} A",
             '  def method1',
             '  end',
             '  protected',
             '  def method2',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it "doesn't register an offense when `private` is not repeated" do
      src = ["#{keyword} A",
             '  def method1',
             '  end',
             '  private',
             '  def method2',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples 'at the end of the body' do |keyword, modifier|
    it "registers an offense for trailing `#{modifier}`" do
      src = ["#{keyword} A",
             '  def method1',
             '  end',
             '  def method2',
             '  end',
             "  #{modifier}",
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end
  end

  shared_examples 'nested in a begin..end block' do |keyword, modifier|
    it "still flags repeated `#{modifier}`" do
      src = ["#{keyword} A",
             "  #{modifier == 'private' ? 'protected' : 'private'}",
             '  def blah',
             '  end',
             '  begin',
             '    def method1',
             '    end',
             "    #{modifier}",
             "    #{modifier}",
             '    def method2',
             '    end',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end
  end

  shared_examples 'unused visibility modifiers' do |keyword|
    it 'registers an error when visibility is immediately changed ' \
       'without any intervening defs' do
      src = ["#{keyword} A",
             '  private',
             '  def method1',
             '  end',
             '  public', # bad
             '  private',
             '  def method2',
             '  end',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end
  end

  shared_examples 'access modifiers with argument' do |keyword|
    it "doesn't register an offense" do
      src = ["#{keyword} A",
             '  def method1',
             '  end',
             '  private :method1',
             '  def method2',
             '  end',
             '  public :method2',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end

  it_behaves_like('at the top of the body', 'class')
  it_behaves_like('repeated visibility modifiers', 'class', 'public')
  it_behaves_like('repeated visibility modifiers', 'class', 'protected')
  it_behaves_like('repeated visibility modifiers', 'class', 'private')
  it_behaves_like('non-repeated visibility modifiers', 'class')
  it_behaves_like('at the end of the body', 'class', 'public')
  it_behaves_like('at the end of the body', 'class', 'protected')
  it_behaves_like('at the end of the body', 'class', 'private')
  it_behaves_like('nested in a begin..end block', 'class', 'public')
  it_behaves_like('nested in a begin..end block', 'class', 'protected')
  it_behaves_like('nested in a begin..end block', 'class', 'private')
  it_behaves_like('unused visibility modifiers', 'class')

  it_behaves_like('at the top of the body', 'module')
  it_behaves_like('repeated visibility modifiers', 'module', 'public')
  it_behaves_like('repeated visibility modifiers', 'module', 'protected')
  it_behaves_like('repeated visibility modifiers', 'module', 'private')
  it_behaves_like('non-repeated visibility modifiers', 'module')
  it_behaves_like('at the end of the body', 'module', 'public')
  it_behaves_like('at the end of the body', 'module', 'protected')
  it_behaves_like('at the end of the body', 'module', 'private')
  it_behaves_like('nested in a begin..end block', 'module', 'public')
  it_behaves_like('nested in a begin..end block', 'module', 'protected')
  it_behaves_like('nested in a begin..end block', 'module', 'private')
  it_behaves_like('unused visibility modifiers', 'module')
end
