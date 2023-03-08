# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::MethodName, :config do
  shared_examples 'never accepted' do |enforced_style|
    it 'registers an offense for mixed snake case and camel case in attr.' do
      expect_offense(<<~RUBY)
        attr :visit_Arel_Nodes_SelectStatement
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_reader :visit_Arel_Nodes_SelectStatement
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_accessor :visit_Arel_Nodes_SelectStatement
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_writer :visit_Arel_Nodes_SelectStatement
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr 'visit_Arel_Nodes_SelectStatement'
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
      RUBY
    end

    it 'registers an offense for mixed snake case and camel case in attr.' do
      expect_offense(<<~RUBY)
        attr_reader :visit_Arel_Nodes_SelectStatement
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_reader 'visit_Arel_Nodes_SelectStatement'
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
      RUBY
    end

    it 'registers an offense for mixed snake case and camel case' do
      expect_offense(<<~RUBY)
        def visit_Arel_Nodes_SelectStatement
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
        end
      RUBY
    end

    it 'registers an offense for capitalized camel case name in attr.' do
      expect_offense(<<~RUBY)
        attr :MyMethod
             ^^^^^^^^^ Use #{enforced_style} for method names.

        attr_reader :MyMethod
                    ^^^^^^^^^ Use #{enforced_style} for method names.

        attr_accessor :MyMethod
                      ^^^^^^^^^ Use #{enforced_style} for method names.

        attr_writer :MyMethod
                    ^^^^^^^^^ Use #{enforced_style} for method names.
      RUBY
    end

    it 'registers an offense for capitalized camel case' do
      expect_offense(<<~RUBY)
        class MyClass
          def MyMethod
              ^^^^^^^^ Use #{enforced_style} for method names.
          end
        end
      RUBY
    end

    it 'registers an offense for singleton upper case method without corresponding class' do
      expect_offense(<<~RUBY)
        module Sequel
          def self.Model(source)
                   ^^^^^ Use #{enforced_style} for method names.
          end
        end
      RUBY
    end
  end

  shared_examples 'always accepted' do |enforced_style|
    it 'accepts one line methods' do
      expect_no_offenses("def body; '' end")
    end

    it 'accepts operator definitions' do
      expect_no_offenses(<<~RUBY)
        def +(other)
          # ...
        end
      RUBY
    end

    it 'accepts unary operator definitions' do
      expect_no_offenses(<<~RUBY)
        def ~@; end
      RUBY

      expect_no_offenses(<<~RUBY)
        def !@; end
      RUBY
    end

    %w[class module].each do |kind|
      it "accepts class emitter method in a #{kind}" do
        expect_no_offenses(<<~RUBY)
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
        expect_no_offenses(<<~RUBY)
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

    context 'when specifying `AllowedPatterns`' do
      let(:cop_config) do
        {
          'EnforcedStyle' => enforced_style,
          'AllowedPatterns' => [
            '\AonSelectionBulkChange\z',
            '\Aon_selection_cleared\z'
          ]
        }
      end

      it 'does not register an offense for camel case method name in attr.' do
        expect_no_offenses(<<~RUBY)
          attr_reader :onSelectionBulkChange
          attr_accessor :onSelectionBulkChange
          attr_writer :onSelectionBulkChange
        RUBY
      end

      it 'does not register an offense for camel case method name matching `AllowedPatterns`' do
        expect_no_offenses(<<~RUBY)
          def onSelectionBulkChange(arg)
          end
        RUBY
      end

      it 'does not register an offense for snake case method name in attr.' do
        expect_no_offenses(<<~RUBY)
          attr_reader :on_selection_cleared
          attr_accessor :on_selection_cleared
          attr_writer :on_selection_cleared
        RUBY
      end

      it 'does not register an offense for snake case method name matching `AllowedPatterns`' do
        expect_no_offenses(<<~RUBY)
          def on_selection_cleared(arg)
          end
        RUBY
      end
    end
  end

  shared_examples 'multiple attr methods' do |enforced_style|
    it 'registers an offense for camel case methods names in attr.' do
      expect_offense(<<~RUBY)
        attr :my_method, :myMethod
             ^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_reader :my_method, :myMethod
                    ^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_accessor :myMethod, :my_method
                      ^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_accessor 'myMethod', 'my_method'
                      ^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
      RUBY
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it 'registers an offense for camel case method names in attr.' do
      expect_offense(<<~RUBY)
        attr_reader :myMethod
                    ^^^^^^^^^ Use snake_case for method names.

        attr_accessor :myMethod
                      ^^^^^^^^^ Use snake_case for method names.

        attr_writer :myMethod
                    ^^^^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'registers an offense for camel case in instance method name' do
      expect_offense(<<~RUBY)
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
          # ...
        end
      RUBY
    end

    it 'registers an offense for opposite + correct' do
      expect_offense(<<~RUBY)
        def my_method
        end
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
        end
      RUBY
    end

    it 'registers an offense for camel case in singleton method name' do
      expect_offense(<<~RUBY)
        def self.myMethod
                 ^^^^^^^^ Use snake_case for method names.
          # ...
        end
      RUBY
    end

    it 'accepts snake case in attr.' do
      expect_no_offenses(<<~RUBY)
        attr_reader :my_method
        attr_accessor :my_method
        attr_writer :my_method
      RUBY
    end

    it 'accepts snake case in names' do
      expect_no_offenses(<<~RUBY)
        def my_method
        end
      RUBY
    end

    it 'registers an offense for singleton camelCase method within class' do
      expect_offense(<<~RUBY)
        class Sequel
          def self.fooBar
                   ^^^^^^ Use snake_case for method names.
          end
        end
      RUBY
    end

    include_examples 'never accepted',  'snake_case'
    include_examples 'always accepted', 'snake_case'
    include_examples 'multiple attr methods', 'snake_case'
  end

  context 'when configured for camelCase' do
    let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

    it 'accepts camel case names in attr.' do
      expect_no_offenses(<<~RUBY)
        attr_reader :myMethod
        attr_accessor :myMethod
        attr_writer :myMethod
      RUBY
    end

    it 'accepts camel case in instance method name' do
      expect_no_offenses(<<~RUBY)
        def myMethod
          # ...
        end
      RUBY
    end

    it 'accepts camel case in singleton method name' do
      expect_no_offenses(<<~RUBY)
        def self.myMethod
          # ...
        end
      RUBY
    end

    it 'registers an offense for snake case name in attr.' do
      expect_offense(<<~RUBY)
        attr_reader :my_method
                    ^^^^^^^^^^ Use camelCase for method names.

        attr_accessor :my_method
                      ^^^^^^^^^^ Use camelCase for method names.

        attr_writer :my_method
                    ^^^^^^^^^^ Use camelCase for method names.

        attr_writer 'my_method'
                    ^^^^^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it 'registers an offense for snake case in names' do
      expect_offense(<<~RUBY)
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
      RUBY
    end

    it 'registers an offense for correct + opposite' do
      expect_offense(<<~RUBY)
        def myMethod
        end
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
      RUBY
    end

    it 'registers an offense for singleton snake_case method within class' do
      expect_offense(<<~RUBY)
        class Sequel
          def self.foo_bar
                   ^^^^^^^ Use camelCase for method names.
          end
        end
      RUBY
    end

    include_examples 'always accepted', 'camelCase'
    include_examples 'never accepted',  'camelCase'
    include_examples 'multiple attr methods', 'camelCase'
  end

  it 'accepts for non-ascii characters' do
    expect_no_offenses(<<~RUBY)
      def última_vista; end
    RUBY
  end
end
