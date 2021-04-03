# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ConstantVisibility, :config do
  context 'when defining a constant in a class' do
    context 'with a single-statement body' do
      it 'registers an offense when not using a visibility declaration' do
        expect_offense(<<~RUBY)
          class Foo
            BAR = 42
            ^^^^^^^^ Explicitly make `BAR` public or private using either `#public_constant` or `#private_constant`.
          end
        RUBY
      end
    end

    context 'with a multi-statement body' do
      it 'registers an offense when not using a visibility declaration' do
        expect_offense(<<~RUBY)
          class Foo
            include Bar
            BAR = 42
            ^^^^^^^^ Explicitly make `BAR` public or private using either `#public_constant` or `#private_constant`.
          end
        RUBY
      end

      it 'registers an offense when there is no matching visibility declaration' do
        expect_offense(<<~RUBY)
          class Foo
            include Bar
            BAR = 42
            ^^^^^^^^ Explicitly make `BAR` public or private using either `#public_constant` or `#private_constant`.
            private_constant :FOO
          end
        RUBY
      end

      it 'does not register an offense when using a visibility declaration' do
        expect_no_offenses(<<~RUBY)
          class Foo
            BAR = 42
            private_constant :BAR
          end
        RUBY
      end
    end
  end

  context 'when defining a constant in a module' do
    it 'registers an offense when not using a visibility declaration' do
      expect_offense(<<~RUBY)
        module Foo
          BAR = 42
          ^^^^^^^^ Explicitly make `BAR` public or private using either `#public_constant` or `#private_constant`.
        end
      RUBY
    end

    it 'does not register an offense when using a visibility declaration' do
      expect_no_offenses(<<~RUBY)
        class Foo
          BAR = 42
          public_constant :BAR
        end
      RUBY
    end
  end

  it 'registers an offense for module definitions' do
    expect_offense(<<~RUBY)
      module Foo
        MyClass = Class.new()
        ^^^^^^^^^^^^^^^^^^^^^ Explicitly make `MyClass` public or private using either `#public_constant` or `#private_constant`.
      end
    RUBY
  end

  context 'IgnoreModules' do
    let(:cop_config) { { 'IgnoreModules' => true } }

    it 'does not register an offense for class definitions' do
      expect_no_offenses(<<~RUBY)
        class Foo
          SomeClass = Class.new()
          SomeModule = Module.new()
          SomeStruct = Struct.new()
        end
      RUBY
    end

    it 'registers an offense for constants' do
      expect_offense(<<~RUBY)
        module Foo
          BAR = 42
          ^^^^^^^^ Explicitly make `BAR` public or private using either `#public_constant` or `#private_constant`.
        end
      RUBY
    end
  end

  it 'does not register an offense when passing a string to the visibility declaration' do
    expect_no_offenses(<<~RUBY)
      class Foo
        BAR = 42
        private_constant "BAR"
      end
    RUBY
  end

  it 'does not register an offense in the top level scope' do
    expect_no_offenses(<<~RUBY)
      BAR = 42
    RUBY
  end
end
