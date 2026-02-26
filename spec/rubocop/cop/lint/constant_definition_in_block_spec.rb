# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ConstantDefinitionInBlock, :config do
  it 'does not register an offense for a top-level constant' do
    expect_no_offenses(<<~RUBY)
      FOO = 1
    RUBY
  end

  it 'does not register an offense for a top-level constant followed by another statement' do
    expect_no_offenses(<<~RUBY)
      FOO = 1
      bar
    RUBY
  end

  it 'registers an offense for a constant defined within a block' do
    expect_offense(<<~RUBY)
      describe do
        FOO = 1
        ^^^^^^^ Do not define constants this way within a block.
      end
    RUBY
  end

  it 'registers an offense for a constant defined within a block followed by another statement' do
    expect_offense(<<~RUBY)
      describe do
        FOO = 1
        ^^^^^^^ Do not define constants this way within a block.
        bar
      end
    RUBY
  end

  it 'does not register an offense for a top-level class' do
    expect_no_offenses(<<~RUBY)
      class Foo; end
    RUBY
  end

  it 'does not register an offense for a top-level class followed by another statement' do
    expect_no_offenses(<<~RUBY)
      class Foo; end
      bar
    RUBY
  end

  it 'registers an offense for a class defined within a block' do
    expect_offense(<<~RUBY)
      describe do
        class Foo; end
        ^^^^^^^^^^^^^^ Do not define constants this way within a block.
      end
    RUBY
  end

  it 'registers an offense for a class defined within a block followed by another statement' do
    expect_offense(<<~RUBY)
      describe do
        class Foo; end
        ^^^^^^^^^^^^^^ Do not define constants this way within a block.
        bar
      end
    RUBY
  end

  it 'does not register an offense for a top-level module' do
    expect_no_offenses(<<~RUBY)
      module Foo; end
    RUBY
  end

  it 'does not register an offense for a top-level module followed by another statement' do
    expect_no_offenses(<<~RUBY)
      module Foo; end
      bar
    RUBY
  end

  it 'registers an offense for a module defined within a block' do
    expect_offense(<<~RUBY)
      describe do
        module Foo; end
        ^^^^^^^^^^^^^^^ Do not define constants this way within a block.
      end
    RUBY
  end

  it 'registers an offense for a module defined within a block followed by another statement' do
    expect_offense(<<~RUBY)
      describe do
        module Foo; end
        ^^^^^^^^^^^^^^^ Do not define constants this way within a block.
        bar
      end
    RUBY
  end

  it 'does not register an offense for a constant with an explicit self scope' do
    expect_no_offenses(<<~RUBY)
      describe do
        self::FOO = 1
      end
    RUBY
  end

  it 'does not register an offense for a constant with an explicit self scope followed by another statement' do
    expect_no_offenses(<<~RUBY)
      describe do
        self::FOO = 1
        bar
      end
    RUBY
  end

  it 'does not register an offense for a constant with an explicit top-level scope' do
    expect_no_offenses(<<~RUBY)
      describe do
        ::FOO = 1
      end
    RUBY
  end

  it 'does not register an offense for a constant with an explicit top-level scope followed by another statement' do
    expect_no_offenses(<<~RUBY)
      describe do
        ::FOO = 1
        bar
      end
    RUBY
  end

  context 'when `AllowedMethods: [enums]`' do
    let(:cop_config) { { 'AllowedMethods' => ['enums'] } }

    it 'does not register an offense for a casign used within a block of `enums` method' do
      expect_no_offenses(<<~RUBY)
        class TestEnum < T::Enum
          enums do
            Foo = new("foo")
          end
        end
      RUBY
    end

    it 'does not register an offense for a class defined within a block of `enums` method' do
      expect_no_offenses(<<~RUBY)
        enums do
          class Foo
          end
        end
      RUBY
    end

    it 'does not register an offense for a module defined within a block of `enums` method' do
      expect_no_offenses(<<~RUBY)
        enums do
          module Foo
          end
        end
      RUBY
    end
  end

  context 'when `AllowedMethods: []`' do
    let(:cop_config) { { 'AllowedMethods' => [] } }

    it 'registers an offense for a casign used within a block of `enums` method' do
      expect_offense(<<~RUBY)
        class TestEnum < T::Enum
          enums do
            Foo = new("foo")
            ^^^^^^^^^^^^^^^^ Do not define constants this way within a block.
          end
        end
      RUBY
    end

    it 'registers an offense for a class defined within a block of `enums` method' do
      expect_offense(<<~RUBY)
        enums do
          class Foo
          ^^^^^^^^^ Do not define constants this way within a block.
          end
        end
      RUBY
    end

    it 'registers an offense for a module defined within a block of `enums` method' do
      expect_offense(<<~RUBY)
        enums do
          module Foo
          ^^^^^^^^^^ Do not define constants this way within a block.
          end
        end
      RUBY
    end
  end
end
