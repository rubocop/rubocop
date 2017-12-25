# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::MethodName, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'never accepted' do |enforced_style|
    it 'registers an offense for mixed snake case and camel case' do
      expect_offense(<<-RUBY.strip_indent)
        def visit_Arel_Nodes_SelectStatement
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
        end
      RUBY
    end

    it 'registers an offense for capitalized camel case' do
      expect_offense(<<-RUBY.strip_indent)
        class MyClass
          def MyMethod
              ^^^^^^^^ Use #{enforced_style} for method names.
          end
        end
      RUBY
    end

    it 'registers an offense for singleton upper case method without ' \
       'corresponding class' do
      expect_offense(<<-RUBY.strip_indent)
        module Sequel
          def self.Model(source)
                   ^^^^^ Use #{enforced_style} for method names.
          end
        end
      RUBY
    end
  end

  shared_examples 'always accepted' do
    it 'accepts one line methods' do
      expect_no_offenses("def body; '' end")
    end

    it 'accepts operator definitions' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def +(other)
          # ...
        end
      RUBY
    end

    it 'accepts unary operator definitions' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def ~@; end
      RUBY

      expect_no_offenses(<<-RUBY.strip_indent)
        def !@; end
      RUBY
    end

    %w[class module].each do |kind|
      it "accepts class emitter method in a #{kind}" do
        expect_no_offenses(<<-RUBY.strip_indent)
          #{kind} Sequel
            def self.Model(source)
            end

            class Model
            end
          end
        RUBY
      end

      it "accepts class emitter method in a #{kind}, even when it is " \
         'defined inside another method' do
        expect_no_offenses(<<-RUBY.strip_indent)
          module DPN
            module Flow
              module BaseFlow
                class Start
                end
                def self.included(base)
                  def base.Start(aws_env, *args)
                  end
                end
              end
            end
          end
        RUBY
      end
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it 'registers an offense for camel case in instance method name' do
      expect_offense(<<-RUBY.strip_indent)
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
          # ...
        end
      RUBY
    end

    it 'registers an offense for opposite + correct' do
      expect_offense(<<-RUBY.strip_indent)
        def my_method
        end
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
        end
      RUBY
    end

    it 'registers an offense for camel case in singleton method name' do
      expect_offense(<<-RUBY.strip_indent)
        def self.myMethod
                 ^^^^^^^^ Use snake_case for method names.
          # ...
        end
      RUBY
    end

    it 'accepts snake case in names' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_method
        end
      RUBY
    end

    it 'registers an offense for singleton camelCase method within class' do
      expect_offense(<<-RUBY.strip_indent)
        class Sequel
          def self.fooBar
                   ^^^^^^ Use snake_case for method names.
          end
        end
      RUBY
    end

    include_examples 'never accepted',  'snake_case'
    include_examples 'always accepted', 'snake_case'
  end

  context 'when configured for camelCase' do
    let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

    it 'accepts camel case in instance method name' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def myMethod
          # ...
        end
      RUBY
    end

    it 'accepts camel case in singleton method name' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.myMethod
          # ...
        end
      RUBY
    end

    it 'registers an offense for snake case in names' do
      expect_offense(<<-RUBY.strip_indent)
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
      RUBY
    end

    it 'registers an offense for correct + opposite' do
      expect_offense(<<-RUBY.strip_indent)
        def myMethod
        end
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
      RUBY
    end

    it 'registers an offense for singleton snake_case method within class' do
      expect_offense(<<-RUBY.strip_indent)
        class Sequel
          def self.foo_bar
                   ^^^^^^^ Use camelCase for method names.
          end
        end
      RUBY
    end

    include_examples 'always accepted', 'camelCase'
    include_examples 'never accepted',  'camelCase'
  end
end
