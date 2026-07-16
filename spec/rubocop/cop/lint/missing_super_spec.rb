# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MissingSuper, :config do
  context 'constructor' do
    it 'registers an offense and does not autocorrect when no `super` call' do
      expect_offense(<<~RUBY)
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense and does not autocorrect when no `super` call and when defining some method' do
      expect_offense(<<~RUBY)
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end

          def do_something
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for the class without parent class' do
      expect_no_offenses(<<~RUBY)
        class Child
          def initialize
          end
        end
      RUBY
    end

    it 'does not register an offense for the class with stateless parent class' do
      expect_no_offenses(<<~RUBY)
        class Child < Object
          def initialize
          end
        end
      RUBY
    end

    it 'does not register an offense for the `Class.new` without parent class argument' do
      expect_no_offenses(<<~RUBY)
        class Child < Parent
          Class.new do
            def initialize
            end
          end
        end
      RUBY
    end

    it 'does not register an offense for the constructor-like method defined outside of a class' do
      expect_no_offenses(<<~RUBY)
        module M
          def initialize
          end
        end
      RUBY
    end

    it 'does not register an offense when there is a `super` call' do
      expect_no_offenses(<<~RUBY)
        class Child < Parent
          def initialize
            super
          end
        end
      RUBY
    end
  end

  context '`Class.new` block' do
    it 'registers an offense and does not autocorrect when no `super` call' do
      expect_offense(<<~RUBY)
        Class.new(Parent) do
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for the `Class.new` without parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new do
          def initialize
          end
        end
      RUBY
    end

    it 'does not register an offense for the `Class.new` with stateless parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new(Object) do
          def initialize
          end
        end
      RUBY
    end
  end

  context '`Class.new` numbered block', :ruby27 do
    it 'registers an offense and does not autocorrect when no `super` call' do
      expect_offense(<<~RUBY)
        Class.new(Parent) do
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end

          do_something(_1)
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for the `Class.new` without parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new do
          def initialize
          end

          do_something(_1)
        end
      RUBY
    end

    it 'does not register an offense for the `Class.new` with stateless parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new(Object) do
          def initialize
          end

          do_something(_1)
        end
      RUBY
    end
  end

  context '`Class.new` `it` block', :ruby34 do
    it 'registers an offense and does not autocorrect when no `super` call' do
      expect_offense(<<~RUBY)
        Class.new(Parent) do
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end

          do_something(it)
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for the `Class.new` without parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new do
          def initialize
          end

          do_something(it)
        end
      RUBY
    end

    it 'does not register an offense for the `Class.new` with stateless parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new(Object) do
          def initialize
          end

          do_something(it)
        end
      RUBY
    end
  end

  context 'callbacks' do
    it 'registers no offense when module callback without `super` call' do
      expect_no_offenses(<<~RUBY)
        module M
          def self.included(base)
          end
        end
      RUBY
    end

    it 'registers an offense and does not autocorrect when class callback without `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          def self.inherited(base)
          ^^^^^^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense and does not autocorrect when class callback within `self << class` and without `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          class << self
            def inherited(base)
            ^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
            end
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense and does not autocorrect when method callback is without `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          def method_added(*)
          ^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense when callback has a `super` call' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def self.inherited(base)
            do_something
            super
          end
        end
      RUBY
    end
  end

  context 'with custom AllowedParentClasses config' do
    let(:cop_config) { { 'AllowedParentClasses' => %w[Array] } }

    it 'does not register an offense for a class with custom stateless parent class' do
      expect_no_offenses(<<~RUBY)
        class Child < Array
          def initialize
          end
        end
      RUBY
    end
  end

  context 'with a project index', :project_index do
    def index_with_current(sources = {})
      build_index(sources.merge('file:///lib/current.rb' => current_source))
    end

    let(:current_source) do
      <<~RUBY
        class Child < Parent
          def initialize
            @foo = 1
          end
        end
      RUBY
    end

    it 'does not register an offense when no ancestor defines `initialize`' do
      cop.project_index = index_with_current('file:///lib/parent.rb' => "class Parent\nend\n")

      expect_no_offenses(current_source, '/lib/current.rb')
    end

    it 'registers an offense when the parent defines `initialize`' do
      cop.project_index = index_with_current(
        'file:///lib/parent.rb' => "class Parent\n  def initialize\n  end\nend\n"
      )

      expect_offense(<<~RUBY, '/lib/current.rb')
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
            @foo = 1
          end
        end
      RUBY
    end

    it 'registers an offense when a grandparent defines `initialize`' do
      cop.project_index = index_with_current(
        'file:///lib/parent.rb' => "class Parent < GrandParent\nend\n",
        'file:///lib/grand_parent.rb' => "class GrandParent\n  def initialize\n  end\nend\n"
      )

      expect_offense(<<~RUBY, '/lib/current.rb')
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
            @foo = 1
          end
        end
      RUBY
    end

    it 'registers an offense when an included module defines `initialize`' do
      cop.project_index = index_with_current(
        'file:///lib/parent.rb' => "class Parent\n  include Initializable\nend\n",
        'file:///lib/initializable.rb' => "module Initializable\n  def initialize\n  end\nend\n"
      )

      expect_offense(<<~RUBY, '/lib/current.rb')
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
            @foo = 1
          end
        end
      RUBY
    end

    it 'registers an offense when the parent is not in the index' do
      cop.project_index = index_with_current

      expect_offense(<<~RUBY, '/lib/current.rb')
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
            @foo = 1
          end
        end
      RUBY
    end

    it 'registers an offense when the ancestry contains an unresolvable superclass' do
      cop.project_index = index_with_current(
        'file:///lib/parent.rb' => "class Parent < SomeGemClass\nend\n"
      )

      expect_offense(<<~RUBY, '/lib/current.rb')
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
            @foo = 1
          end
        end
      RUBY
    end

    it 'registers an offense when the ancestry contains an unresolvable include' do
      cop.project_index = index_with_current(
        'file:///lib/parent.rb' => "class Parent\n  include SomeGemModule\nend\n"
      )

      expect_offense(<<~RUBY, '/lib/current.rb')
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
            @foo = 1
          end
        end
      RUBY
    end

    it 'does not register an offense when the ancestry contains only an unresolvable `extend`' do
      cop.project_index = index_with_current(
        'file:///lib/parent.rb' => "class Parent\n  extend SomeGemModule\nend\n"
      )

      expect_no_offenses(current_source, '/lib/current.rb')
    end

    it 'resolves the parent through the lexical nesting' do
      source = <<~RUBY
        module Wrap
          class Child < Parent
            def initialize
              @foo = 1
            end
          end
        end
      RUBY
      cop.project_index = build_index(
        'file:///lib/current.rb' => source,
        'file:///lib/parent.rb' => "module Wrap\n  class Parent\n  end\nend\n"
      )

      expect_no_offenses(source, '/lib/current.rb')
    end
  end
end
