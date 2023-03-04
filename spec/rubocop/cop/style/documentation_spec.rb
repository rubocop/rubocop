# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Documentation, :config do
  let(:config) do
    RuboCop::Config.new('Style/CommentAnnotation' => {
                          'Keywords' => %w[TODO FIXME OPTIMIZE HACK REVIEW]
                        })
  end

  it 'registers an offense for non-empty class' do
    expect_offense(<<~RUBY)
      class MyClass
      ^^^^^^^^^^^^^ Missing top-level documentation comment for `class MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty cbase class' do
    expect_offense(<<~RUBY)
      class ::MyClass
      ^^^^^^^^^^^^^^^ Missing top-level documentation comment for `class ::MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class nested under self' do
    expect_offense(<<~RUBY)
      class self::MyClass
      ^^^^^^^^^^^^^^^^^^^ Missing top-level documentation comment for `class self::MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class nested under method call' do
    expect_offense(<<~RUBY)
      class my_method::MyClass
      ^^^^^^^^^^^^^^^^^^^^^^^^ Missing top-level documentation comment for `class my_method::MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class nested under safe navigation method call' do
    expect_offense(<<~RUBY)
      class obj&.my_method::MyClass
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing top-level documentation comment for `class obj&.my_method::MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class nested under local variable' do
    expect_offense(<<~RUBY)
      m = Module.new
      module m::N
      ^^^^^^^^^^^ Missing top-level documentation comment for `module m::N`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class nested under instance variable' do
    expect_offense(<<~RUBY)
      module @m::N
      ^^^^^^^^^^^^ Missing top-level documentation comment for `module @m::N`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class nested under class variable' do
    expect_offense(<<~RUBY)
      module @@m::N
      ^^^^^^^^^^^^^ Missing top-level documentation comment for `module @@m::N`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class nested under global variable' do
    expect_offense(<<~RUBY)
      module $m::N
      ^^^^^^^^^^^^ Missing top-level documentation comment for `module $m::N`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class nested under local variables' do
    expect_offense(<<~RUBY)
      m = Module.new
      n = Module.new
      module m::n::M
      ^^^^^^^^^^^^^^ Missing top-level documentation comment for `module m::n::M`.
        def method
        end
      end
    RUBY
  end

  it 'does not consider comment followed by empty line to be class documentation' do
    expect_offense(<<~RUBY)
      # Copyright 2014
      # Some company

      class MyClass
      ^^^^^^^^^^^^^ Missing top-level documentation comment for `class MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-namespace' do
    expect_offense(<<~RUBY)
      module MyModule
      ^^^^^^^^^^^^^^^ Missing top-level documentation comment for `module MyModule`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for empty module without documentation' do
    # Because why would you have an empty module? It requires some
    # explanation.
    expect_offense(<<~RUBY)
      module Test
      ^^^^^^^^^^^ Missing top-level documentation comment for `module Test`.
      end
    RUBY
  end

  it 'accepts non-empty class with documentation' do
    expect_no_offenses(<<~RUBY)
      # class comment
      class MyClass
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class with annotation comment' do
    expect_offense(<<~RUBY)
      # OPTIMIZE: Make this faster.
      class MyClass
      ^^^^^^^^^^^^^ Missing top-level documentation comment for `class MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class with directive comment' do
    expect_offense(<<~RUBY)
      # rubocop:disable Style/For
      class MyClass
      ^^^^^^^^^^^^^ Missing top-level documentation comment for `class MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers offense for non-empty class with frozen string comment' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      class MyClass
      ^^^^^^^^^^^^^ Missing top-level documentation comment for `class MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class with encoding comment' do
    expect_offense(<<~RUBY)
      # encoding: ascii-8bit
      class MyClass
      ^^^^^^^^^^^^^ Missing top-level documentation comment for `class MyClass`.
        def method
        end
      end
    RUBY
  end

  it 'accepts non-empty class with annotation comment followed by other comment' do
    expect_no_offenses(<<~RUBY)
      # OPTIMIZE: Make this faster.
      # Class comment.
      class MyClass
        def method
        end
      end
    RUBY
  end

  it 'accepts non-empty class with comment that ends with an annotation' do
    expect_no_offenses(<<~RUBY)
      # Does fooing.
      # FIXME: Not yet implemented.
      class Foo
        def initialize
        end
      end
    RUBY
  end

  it 'accepts non-empty module with documentation' do
    expect_no_offenses(<<~RUBY)
      # class comment
      module MyModule
        def method
        end
      end
    RUBY
  end

  it 'accepts empty class without documentation' do
    expect_no_offenses(<<~RUBY)
      class MyClass
      end
    RUBY
  end

  it 'accepts namespace module without documentation' do
    expect_no_offenses(<<~RUBY)
      module Test
        class A; end
        class B; end
      end
    RUBY
  end

  it 'accepts namespace class without documentation' do
    expect_no_offenses(<<~RUBY)
      class Test
        class A; end
        class B; end
      end
    RUBY
  end

  it 'accepts namespace class which defines constants' do
    expect_no_offenses(<<~RUBY)
      class Test
        A = Class.new
        B = Class.new(A)
        C = Class.new { call_method }
        D = 1
      end
    RUBY
  end

  it 'accepts namespace module which defines constants' do
    expect_no_offenses(<<~RUBY)
      module Test
        A = Class.new
        B = Class.new(A)
        C = Class.new { call_method }
        D = 1
      end
    RUBY
  end

  context 'without documentation' do
    context 'with non-empty module' do
      context 'with constants visibility declaration content' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            module Namespace
              class Private
              end

              private_constant :Private
            end
          RUBY
        end
      end
    end

    context 'with non-empty class' do
      context 'with constants visibility declaration content' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class Namespace
              class Private
              end

              private_constant :Private
            end
          RUBY
        end
      end
    end

    it 'registers offense with custom macro' do
      expect_offense(<<~RUBY)
        class Foo < ApplicationRecord
        ^^^^^^^^^ Missing top-level documentation comment for `class Foo`.
          belongs_to :bar
        end
      RUBY
    end

    context 'include statement-only class' do
      it 'does not register offense with single `include` statements' do
        expect_no_offenses(<<~RUBY)
          module Foo
            include Bar
          end
        RUBY
      end

      it 'does not register offense with single `extend` statements' do
        expect_no_offenses(<<~RUBY)
          module Foo
            extend Bar
          end
        RUBY
      end

      it 'does not register offense with single `prepend` statements' do
        expect_no_offenses(<<~RUBY)
          module Foo
            prepend Bar
          end
        RUBY
      end

      it 'does not register offense with multiple include macros' do
        expect_no_offenses(<<~RUBY)
          module Foo
            include A
            include B
            extend C
            prepend D
          end
        RUBY
      end

      it 'registers offense for include statement with other methods' do
        expect_offense(<<~RUBY)
          module Foo
          ^^^^^^^^^^ Missing top-level documentation comment for `module Foo`.
            extend B
            include C

            def foo; end
          end
        RUBY
      end
    end
  end

  it 'does not raise an error for an implicit match conditional' do
    expect do
      expect_offense(<<~RUBY)
        class Test
        ^^^^^^^^^^ Missing top-level documentation comment for `class Test`.
          if //
          end
        end
      RUBY
    end.not_to raise_error
  end

  it 'registers an offense if the comment line contains code' do
    expect_offense(<<~RUBY)
      module A # The A Module
        class B
        ^^^^^^^ Missing top-level documentation comment for `class A::B`.
          C = 1
          def method
          end
        end
      end
    RUBY
  end

  it 'registers an offense for compact-style nested module' do
    expect_offense(<<~RUBY)
      module A::B
      ^^^^^^^^^^^ Missing top-level documentation comment for `module A::B`.
        C = 1
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for compact-style nested class' do
    expect_offense(<<~RUBY)
      class A::B
      ^^^^^^^^^^ Missing top-level documentation comment for `class A::B`.
        C = 1
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for a deeply nested class' do
    expect_offense(<<~RUBY)
      module A::B
        module C
          class D
            class E::F
            ^^^^^^^^^^ Missing top-level documentation comment for `class A::B::C::D::E::F`.
              def method
              end
            end
          end
        end
      end
    RUBY
  end

  context 'sparse and trailing comments' do
    %w[class module].each do |keyword|
      it "ignores comments after #{keyword} node end" do
        expect_no_offenses(<<~RUBY)
          module TestModule
            # documentation comment
            #{keyword} Test
              def method
              end
            end # decorating comment
          end
        RUBY
      end

      it "ignores sparse comments inside #{keyword} node" do
        expect_offense(<<~RUBY, keyword: keyword)
          module TestModule
            %{keyword} Test
            ^{keyword}^^^^^ Missing top-level documentation comment for `#{keyword} TestModule::Test`.
              def method
              end
              # sparse comment
            end
          end
        RUBY
      end
    end
  end

  context 'with # :nodoc:' do
    %w[class module].each do |keyword|
      it "accepts non-namespace #{keyword} without documentation" do
        expect_no_offenses(<<~RUBY)
          #{keyword} Test #:nodoc:
            def method
            end
          end
        RUBY
      end

      it "accepts compact-style nested #{keyword} without documentation" do
        expect_no_offenses(<<~RUBY)
          #{keyword} A::B::Test #:nodoc:
            def method
            end
          end
        RUBY
      end

      it "registers an offense for nested #{keyword} without documentation" do
        expect_offense(<<~RUBY, keyword: keyword)
          module TestModule #:nodoc:
            TEST = 20
            %{keyword} Test
            ^{keyword}^^^^^ Missing top-level documentation comment for `#{keyword} TestModule::Test`.
              def method
              end
            end
          end
        RUBY
      end

      context 'with `all` modifier' do
        it "accepts nested #{keyword} without documentation" do
          expect_no_offenses(<<~RUBY)
            module A #:nodoc: all
              module B
                TEST = 20
                #{keyword} Test
                  TEST = 20
                end
              end
            end
          RUBY
        end
      end
    end

    context 'on a subclass' do
      it 'accepts non-namespace subclass without documentation' do
        expect_no_offenses(<<~RUBY)
          class Test < Parent #:nodoc:
            def method
            end
          end
        RUBY
      end

      it 'registers an offense for nested subclass without documentation' do
        expect_offense(<<~RUBY)
          module TestModule #:nodoc:
            TEST = 20
            class Test < Parent
            ^^^^^^^^^^ Missing top-level documentation comment for `class TestModule::Test`.
              def method
              end
            end
          end
        RUBY
      end

      context 'with `all` modifier' do
        it 'accepts nested subclass without documentation' do
          expect_no_offenses(<<~RUBY)
            module A #:nodoc: all
              module B
                TEST = 20
                class Test < Parent
                  TEST = 20
                end
              end
            end
          RUBY
        end
      end

      describe 'when AllowedConstants is configured' do
        before { config['Style/Documentation'] = { 'AllowedConstants' => ['ClassMethods'] } }

        it 'ignores the constants in the config' do
          expect_no_offenses(<<~RUBY)
            module A
              module ClassMethods
                def do_something
                end
              end
            end
          RUBY
        end
      end
    end
  end
end
