# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ConstantDefinitionInBlock do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

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
end
