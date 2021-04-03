# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyClass, :config do
  let(:cop_config) { { 'AllowComments' => false } }

  it 'registers an offense for empty class' do
    expect_offense(<<~RUBY)
      class Foo
      ^^^^^^^^^ Empty class detected.
      end
    RUBY
  end

  it 'registers an offense for empty class metaclass' do
    expect_offense(<<~RUBY)
      class Foo
        class << self
        ^^^^^^^^^^^^^ Empty metaclass detected.
        end
      end
    RUBY
  end

  it 'registers an offense for empty object metaclass' do
    expect_offense(<<~RUBY)
      class << obj
      ^^^^^^^^^^^^ Empty metaclass detected.
      end
    RUBY
  end

  it 'registers an offense when empty metaclass contains only comments' do
    expect_offense(<<~RUBY)
      class Foo
        class << self
        ^^^^^^^^^^^^^ Empty metaclass detected.
          # Comment.
        end
      end
    RUBY
  end

  it 'does not register an offense when class is not empty' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_reader :bar
      end
    RUBY
  end

  it 'does not register an offense when empty has a parent' do
    expect_no_offenses(<<~RUBY)
      class Child < Parent
      end
    RUBY
  end

  it 'does not register an offense when metaclass is not empty' do
    expect_no_offenses(<<~RUBY)
      class Foo
        class << self
          attr_reader :bar
        end
      end
    RUBY
  end

  context 'when AllowComments is true' do
    let(:cop_config) { { 'AllowComments' => true } }

    it 'does not register an offense when empty class contains only comments' do
      expect_no_offenses(<<~RUBY)
        class Foo
          # Comment.
        end
      RUBY
    end

    it 'does not register an offense when empty metaclass contains only comments' do
      expect_no_offenses(<<~RUBY)
        class Foo
          class << self
            # Comment.
          end
        end
      RUBY
    end
  end
end
