# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OptionalBooleanParameter, :config do
  let(:cop_config) { { 'AllowedMethods' => [] } }

  it 'registers an offense when defining method with optional boolean arg' do
    expect_offense(<<~RUBY)
      def some_method(bar = false)
                      ^^^^^^^^^^^ Prefer keyword arguments for arguments with a boolean default value; use `bar: false` instead of `bar = false`.
      end
    RUBY
  end

  it 'registers an offense when defining method with optional boolean arg that has no space' do
    expect_offense(<<~RUBY)
      def some_method(bar=false)
                      ^^^^^^^^^ Prefer keyword arguments for arguments with a boolean default value; use `bar: false` instead of `bar=false`.
      end
    RUBY
  end

  it 'registers an offense when defining class method with optional boolean arg' do
    expect_offense(<<~RUBY)
      def self.some_method(bar = false)
                           ^^^^^^^^^^^ Prefer keyword arguments for arguments with a boolean default value; use `bar: false` instead of `bar = false`.
      end
    RUBY
  end

  it 'registers an offense when defining method with multiple optional boolean args' do
    expect_offense(<<~RUBY)
      def some_method(foo = true, bar = 1, baz = false, quux: true)
                      ^^^^^^^^^^ Prefer keyword arguments for arguments with a boolean default value; use `foo: true` instead of `foo = true`.
                                           ^^^^^^^^^^^ Prefer keyword arguments for arguments with a boolean default value; use `baz: false` instead of `baz = false`.
      end
    RUBY
  end

  it 'does not register an offense when defining method with keyword boolean arg' do
    expect_no_offenses(<<~RUBY)
      def some_method(bar: false)
      end
    RUBY
  end

  it 'does not register an offense when defining method without args' do
    expect_no_offenses(<<~RUBY)
      def some_method
      end
    RUBY
  end

  it 'does not register an offense when defining method with optional non-boolean arg' do
    expect_no_offenses(<<~RUBY)
      def some_method(bar = 'foo')
      end
    RUBY
  end

  context 'when AllowedMethods is not empty' do
    let(:cop_config) { { 'AllowedMethods' => %w[respond_to_missing?] } }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def respond_to_missing?(method, include_all = false)
        end
      RUBY
    end
  end
end
