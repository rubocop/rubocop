# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::DocumentationMethod do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/CommentAnnotation' => {
                          'Keywords' => %w(TODO FIXME OPTIMIZE HACK REVIEW)
                        },
                        'Style/DocumentationMethod' => {
                          'Enabled' => true
                        })
  end

  context 'declaring methods outside a class' do
    it 'registers an offense for non-empty method' do
      inspect_source(cop,
                     ['def method',
                      ' puts "method"',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts non-empty method with documentation' do
      inspect_source(cop,
                     ['# method comment',
                      'def method',
                      ' puts "method"',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for empty method' do
      inspect_source(cop,
                     ['def method',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts empty method with documentation' do
      inspect_source(cop,
                     ['# method comment',
                      'def method',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private non-empty method' do
      inspect_source(cop,
                     ['private',
                      '',
                      'def method',
                      ' puts "method"',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private empty method' do
      inspect_source(cop,
                     ['private',
                      '',
                      'def method',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private non-empty method' do
      inspect_source(cop,
                     ['private def method',
                      ' puts "method"',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private empty method' do
      inspect_source(cop,
                     ['private def method',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for combination of methods without
     documentation' do
      inspect_source(cop,
                     ['def method',
                      ' puts "method"',
                      'end',
                      '',
                      'private',
                      '',
                      'def method',
                      ' puts "method"',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not registers an offense for combination of methods with
     documentation' do
      inspect_source(cop,
                     ['# documentation comment',
                      'def method',
                      ' puts "method"',
                      'end',
                      '',
                      'private',
                      '',
                      'def method',
                      ' puts "method"',
                      'end',
                      '',
                      'class MyClass',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'declaring methods in a class' do
    it 'registers an offense for non-empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts non-empty method with documentation' do
      inspect_source(cop,
                     ['class MyClass',
                      '  # method comment',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      '  def method',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts empty method with documentation' do
      inspect_source(cop,
                     ['class MyClass',
                      '  # method comment',
                      '  def method',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private non-empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      '  private',
                      '',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private non-empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      '  private def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      '  private',
                      '',
                      '  def method',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      '  private def method',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for combination of methods without
     documentation' do
      inspect_source(cop,
                     ['class MyClass',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      '',
                      '  private',
                      '',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not registers an offense for combination of methods with
     documentation' do
      inspect_source(cop,
                     ['class MyClass',
                      '  # documentation comment',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      '',
                      '  private',
                      '',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'declaring methods in a module' do
    it 'registers an offense for non-empty method' do
      inspect_source(cop,
                     ['module MyModule',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts non-empty method with documentation' do
      inspect_source(cop,
                     ['module MyModule',
                      '  # method comment',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for empty method' do
      inspect_source(cop,
                     ['module MyModule',
                      '  def method',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts empty method with documentation' do
      inspect_source(cop,
                     ['module MyModule',
                      '  # method comment',
                      '  def method',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private non-empty method' do
      inspect_source(cop,
                     ['module MyModule',
                      '  private',
                      '',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private non-empty method' do
      inspect_source(cop,
                     ['module MyModule',
                      '  private def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private empty method' do
      inspect_source(cop,
                     ['module MyModule',
                      '  private',
                      '',
                      '  def method',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private empty method' do
      inspect_source(cop,
                     ['module MyModule',
                      '  private def method',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for combination of methods without
     documentation' do
      inspect_source(cop,
                     ['module MyModule',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      '',
                      '  private',
                      '',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not registers an offense for combination of methods with
     documentation' do
      inspect_source(cop,
                     ['module MyModule',
                      '  # documentation comment',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      '',
                      '  private',
                      '',
                      '  def method',
                      '    puts "method"',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'singleton methods' do
    it 'registers an offense for non-empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      'def my_class.method',
                      ' puts "method"',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      'def my_class.method',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts non-empty method with documentation' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      '# documentation comment',
                      'def my_class.method',
                      ' puts "method"',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts empty method with documentation' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      '# documentation comment',
                      'def my_class.method',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      'private',
                      '',
                      'def my_class.method',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private non-empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      'private',
                      '',
                      'def my_class.method',
                      '  puts "method"',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      'private def my_class.method',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not registers an offense for private non-empty method' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      'private def my_class.method',
                      '  puts "method"',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for combination of methods without
     documentation' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      'def my_class.method',
                      ' puts "method"',
                      'end',
                      '',
                      'private',
                      '',
                      'def my_class.method',
                      ' puts "method"',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not registers an offense for combination of methods with
     documentation' do
      inspect_source(cop,
                     ['class MyClass',
                      'end',
                      '',
                      'my_class = MyClass.new',
                      '',
                      '# documentation comment',
                      'def my_class.method',
                      ' puts "method"',
                      'end',
                      '',
                      'private',
                      '',
                      'def my_class.method',
                      ' puts "method"',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end
end
