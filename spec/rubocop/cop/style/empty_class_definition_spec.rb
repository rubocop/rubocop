# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyClassDefinition, :config do
  context 'when EnforcedStyle is class_definition' do
    let(:cop_config) { { 'EnforcedStyle' => 'class_definition' } }

    it 'registers an offense for Class.new assignment to constant' do
      expect_offense(<<~RUBY)
        FooError = Class.new(StandardError)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer a two-line class definition over `Class.new` for classes with no body.
      RUBY

      expect_correction(<<~RUBY)
        class FooError < StandardError
        end
      RUBY
    end

    it 'registers an offense for Class.new assignment to constant without parent class' do
      expect_offense(<<~RUBY)
        MyClass = Class.new
        ^^^^^^^^^^^^^^^^^^^ Prefer a two-line class definition over `Class.new` for classes with no body.
      RUBY

      expect_correction(<<~RUBY)
        class MyClass
        end
      RUBY
    end

    it 'registers an offense for indented Class.new assignment to constant' do
      expect_offense(<<~RUBY)
        module Foo
          BarError = Class.new(StandardError)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer a two-line class definition over `Class.new` for classes with no body.
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          class BarError < StandardError
          end
        end
      RUBY
    end

    it 'registers an offense for Class.new assignment to constant with namespaced parent class' do
      expect_offense(<<~RUBY)
        MyClass = Class.new(Alchemy::Admin::PreviewUrl)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer a two-line class definition over `Class.new` for classes with no body.
      RUBY

      expect_correction(<<~RUBY)
        class MyClass < Alchemy::Admin::PreviewUrl
        end
      RUBY
    end

    it 'registers an offense for Class.new assignment to constant with absolute parent class path' do
      expect_offense(<<~RUBY)
        MyClass = Class.new(::Safemode::Jail)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer a two-line class definition over `Class.new` for classes with no body.
      RUBY

      expect_correction(<<~RUBY)
        class MyClass < ::Safemode::Jail
        end
      RUBY
    end

    it 'does not register an offense for single-line class with inheritance' do
      expect_no_offenses(<<~RUBY)
        class FooError < StandardError; end
      RUBY
    end

    it 'does not register an offense for single-line class without inheritance' do
      expect_no_offenses(<<~RUBY)
        class MyClass; end
      RUBY
    end

    it 'does not register an offense for indented single-line class' do
      expect_no_offenses(<<~RUBY)
        module Foo
          class Bar < Baz; end
        end
      RUBY
    end

    it 'does not register an offense for two-line class with body' do
      expect_no_offenses(<<~RUBY)
        class FooError < StandardError
          def initialize(message)
            super
          end
        end
      RUBY
    end

    it 'does not register an offense for single-line class with body' do
      expect_no_offenses(<<~RUBY)
        class FooError < StandardError; def initialize; end; end
      RUBY
    end

    it 'does not register an offense for two-line class with inheritance' do
      expect_no_offenses(<<~RUBY)
        class FooError < StandardError
        end
      RUBY
    end

    it 'does not register an offense for two-line class without inheritance' do
      expect_no_offenses(<<~RUBY)
        class MyClass
        end
      RUBY
    end

    it 'does not register an offense for Class.new with block using do...end' do
      expect_no_offenses(<<~RUBY)
        Class.new(Settings::Base) do
          def repositories(*_args); end
        end
      RUBY
    end

    it 'does not register an offense for Class.new with block using curly braces' do
      expect_no_offenses(<<~RUBY)
        Class.new(Settings::Base) { setting :var }
      RUBY
    end

    it 'does not register an offense for Class.new with empty block using curly braces' do
      expect_no_offenses(<<~RUBY)
        MyClass = Class.new(StandardError) { }
      RUBY
    end

    it 'does not register an offense for Class.new with empty block using do...end' do
      expect_no_offenses(<<~RUBY)
        MyClass = Class.new(StandardError) do end
      RUBY
    end

    it 'does not register an offense for Class.new with block without parent class' do
      expect_no_offenses(<<~RUBY)
        Class.new do
          def method
          end
        end
      RUBY
    end

    it 'does not register an offense for Class.new assigned to variables (local, instance, class, global)' do
      expect_no_offenses(<<~RUBY)
        local_var = Class.new(Base)
        @instance_var = Class.new(Base)
        @@class_var = Class.new(Base)
        $global_var = Class.new(Base)
      RUBY
    end

    it 'does not register an offense for operator assignment with ||= for variables' do
      expect_no_offenses(<<~RUBY)
        local_var ||= Class.new(Base)
        @instance_var ||= Class.new(Base)
        @@class_var ||= Class.new(Base)
        $global_var ||= Class.new(Base)
      RUBY
    end

    it 'does not register an offense for Class.new in raise statement' do
      expect_no_offenses(<<~RUBY)
        raise Class.new(StandardError)
      RUBY
    end

    it 'does not register an offense for Class.new as method argument' do
      expect_no_offenses(<<~RUBY)
        foo(Class.new(Base))
      RUBY
    end

    it 'does not register an offense for Class.new in return statement' do
      expect_no_offenses(<<~RUBY)
        return Class.new(Error)
      RUBY
    end

    it 'does not register an offense for Class.new with tap block' do
      expect_no_offenses(<<~RUBY)
        Class.new(Resolvers::BaseResolver).tap do |c|
          c.const_set('MODEL_CLASS', model_class)
        end
      RUBY
    end

    it 'does not register an offense for Class.new in stub_const arguments' do
      expect_no_offenses(<<~RUBY)
        stub_const('FakeService', Class.new)

        stub_const("MicrosoftSync::TestErrorNotPublic", Class.new(StandardError))

        stub_const("MicrosoftSync::TestError",
                   Class.new(MicrosoftSync::Errors::PublicError) do
                     def self.public_message
                       I18n.t "oops, this is a public error"
                     end
                   end)
      RUBY
    end

    it 'does not register an offense for Class.new with variable as parent class' do
      expect_no_offenses(<<~RUBY)
        Class.new(local_var)
        Class.new(@instance_var)
        Class.new(@@class_var)
        Class.new($global_var)
      RUBY
    end

    it 'does not register an offense for Class.new with self as parent class' do
      expect_no_offenses(<<~RUBY)
        MyClass = Class.new(self)
      RUBY
    end

    it 'does not register an offense for constant assignment with ||= when node.expression is nil' do
      expect_no_offenses(<<~RUBY)
        CONST ||= %i{user port proxy}.freeze
      RUBY
    end

    it 'does not register an offense for constant assignment that is not Class.new' do
      expect_no_offenses(<<~RUBY)
        BOOLEAN = ActiveRecord::Type::Boolean.new
      RUBY
    end

    it 'does not register an offense for constant assignment with variable or method call' do
      expect_no_offenses(<<~RUBY)
        CONST = condition
        private_constant :CONST
      RUBY
    end

    it 'does not register an offense for Class.new chained with any method' do
      expect_no_offenses(<<~RUBY)
        MyClass = Class.new(Foreman::Renderer).send(:new)
        MyClass = Class.new(Foreman::Renderer).public_send(:new)
        MyClass = Class.new(StandardError).any_method
        MyClass = Class.new(StandardError).tap { }
        MyClass = Class.new(StandardError).send(:new).another_method
      RUBY
    end

    it 'does not register an offense for Class.new in let, let_it_be and subject blocks' do
      expect_no_offenses(<<~RUBY)
        let(:application_mailer) { Class.new(ActionMailer::Base) }
        let(:my_class) { Class.new }
        let(:view_component) do
          Class.new(ViewComponent::Base)
        end
        let_it_be(:custom_config_class) { Class.new }
        subject { Class.new(ViewComponent::Base) }
        let(:my_class) { Class.new do
          def method
          end
        end }
      RUBY
    end
  end

  context 'when EnforcedStyle is class_new' do
    let(:cop_config) { { 'EnforcedStyle' => 'class_new' } }

    it 'registers an offense for two-line class definition with inheritance' do
      expect_offense(<<~RUBY)
        class FooError < StandardError
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Class.new` over class definition for classes with no body.
        end
      RUBY

      expect_correction(<<~RUBY)
        FooError = Class.new(StandardError)
      RUBY
    end

    it 'registers an offense for single-line class definition with inheritance' do
      expect_offense(<<~RUBY)
        class FooError < StandardError; end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Class.new` over class definition for classes with no body.
      RUBY

      expect_correction(<<~RUBY)
        FooError = Class.new(StandardError)
      RUBY
    end

    it 'registers an offense for two-line class definition without inheritance' do
      expect_offense(<<~RUBY)
        class MyClass
        ^^^^^^^^^^^^^ Prefer `Class.new` over class definition for classes with no body.
        end
      RUBY

      expect_correction(<<~RUBY)
        MyClass = Class.new
      RUBY
    end

    it 'registers an offense for single-line class definition without inheritance' do
      expect_offense(<<~RUBY)
        class MyClass; end
        ^^^^^^^^^^^^^^^^^^ Prefer `Class.new` over class definition for classes with no body.
      RUBY

      expect_correction(<<~RUBY)
        MyClass = Class.new
      RUBY
    end

    it 'registers an offense for indented two-line class definition' do
      expect_offense(<<~RUBY)
        module Foo
          class BarError < StandardError
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Class.new` over class definition for classes with no body.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          BarError = Class.new(StandardError)
        end
      RUBY
    end

    it 'registers an offense for class definition with namespaced parent class' do
      expect_offense(<<~RUBY)
        class MyClass < Alchemy::Admin::PreviewUrl
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Class.new` over class definition for classes with no body.
        end
      RUBY

      expect_correction(<<~RUBY)
        MyClass = Class.new(Alchemy::Admin::PreviewUrl)
      RUBY
    end

    it 'registers an offense for class definition with absolute parent class path' do
      expect_offense(<<~RUBY)
        class MyClass < ::Safemode::Jail
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Class.new` over class definition for classes with no body.
        end
      RUBY

      expect_correction(<<~RUBY)
        MyClass = Class.new(::Safemode::Jail)
      RUBY
    end

    it 'does not register an offense for Class.new assignment' do
      expect_no_offenses(<<~RUBY)
        FooError = Class.new(StandardError)
      RUBY
    end

    it 'does not register an offense for Class.new without parent class' do
      expect_no_offenses(<<~RUBY)
        MyClass = Class.new
      RUBY
    end

    it 'registers an offense for indented single-line class definition' do
      expect_offense(<<~RUBY)
        module Foo
          class Bar < Baz; end
          ^^^^^^^^^^^^^^^^^^^^ Prefer `Class.new` over class definition for classes with no body.
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          Bar = Class.new(Baz)
        end
      RUBY
    end

    it 'does not register an offense for class with body' do
      expect_no_offenses(<<~RUBY)
        class FooError < StandardError
          def initialize(message)
            super
          end
        end
      RUBY
    end

    it 'does not register an offense for single-line class with body' do
      expect_no_offenses(<<~RUBY)
        class FooError < StandardError; def initialize; end; end
      RUBY
    end
  end
end
