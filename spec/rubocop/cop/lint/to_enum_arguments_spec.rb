# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ToEnumArguments, :config do
  it 'registers an offense when required arg is missing' do
    expect_offense(<<~RUBY)
      def m(x)
        return to_enum(:m) unless block_given?
               ^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'registers an offense when optional arg is missing' do
    expect_offense(<<~RUBY)
      def m(x, y = 1)
        return to_enum(:m, x) unless block_given?
               ^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'registers an offense when splat arg is missing' do
    expect_offense(<<~RUBY)
      def m(x, y = 1, *args)
        return to_enum(:m, x, y) unless block_given?
               ^^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'registers an offense when required keyword arg is missing' do
    expect_offense(<<~RUBY)
      def m(x, y = 1, *args, required:)
        return to_enum(:m, x, y, *args) unless block_given?
               ^^^^^^^^^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'registers an offense when optional keyword arg is missing' do
    expect_offense(<<~RUBY)
      def m(x, y = 1, *args, required:, optional: true)
        return to_enum(:m, x, y, *args, required: required) unless block_given?
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'registers an offense when splat keyword arg is missing' do
    expect_offense(<<~RUBY)
      def m(x, y = 1, *args, required:, optional: true, **kwargs)
        return to_enum(:m, x, y, *args, required: required, optional: optional) unless block_given?
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'registers an offense when arguments are swapped' do
    expect_offense(<<~RUBY)
      def m(x, y = 1)
        return to_enum(:m, y, x) unless block_given?
               ^^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'registers an offense when other values are passed for keyword arguments' do
    expect_offense(<<~RUBY)
      def m(required:, optional: true)
        return to_enum(:m, required: something_else, optional: optional) unless block_given?
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'does not register an offense when not inside method definition' do
    expect_no_offenses(<<~RUBY)
      to_enum(:m)
    RUBY
  end

  it 'does not register an offense when method call has a receiver other than `self`' do
    expect_no_offenses(<<~RUBY)
      def m(x)
        return foo.to_enum(:m) unless block_given?
      end
    RUBY
  end

  it 'registers an offense when method is called on `self`' do
    expect_offense(<<~RUBY)
      def m(x)
        return self.to_enum(:m) unless block_given?
               ^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'ignores the block argument' do
    expect_no_offenses(<<~RUBY)
      def m(x, &block)
        return to_enum(:m, x) unless block_given?
      end
    RUBY
  end

  it 'registers an offense when enumerator is created for another method' do
    expect_offense(<<~RUBY)
      def m(x)
        return to_enum(:not_m) unless block_given?
               ^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'registers an offense when enumerator is created for `__method__` with missing arguments' do
    expect_offense(<<~RUBY)
      def m(x)
        return to_enum(__method__) unless block_given?
               ^^^^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
      end
    RUBY
  end

  it 'does not register an offense when enumerator is not created for `__method__` and `__callee__` methods' do
    expect_no_offenses(<<~RUBY)
      def m(x)
        return to_enum(never_nullable(value), x)
      end
    RUBY
  end

  it 'does not register an offense when enumerator is not created for `__method__` and `__callee__` methods ' \
     'and using safe navigation operator' do
    expect_no_offenses(<<~RUBY)
      def m(x)
        return to_enum(obj&.never_nullable(value), x)
      end
    RUBY
  end

  %w[:m __callee__ __method__].each do |code|
    it "does not register an offense when enumerator is created with `#{code}` and the correct arguments" do
      expect_no_offenses(<<~RUBY)
        def m(x, y = 1, *args, required:, optional: true, **kwargs, &block)
          return to_enum(#{code}, x, y, *args, required: required, optional: optional, **kwargs) unless block_given?
        end
      RUBY
    end
  end

  context 'arguments forwarding', :ruby30 do
    it 'registers an offense when enumerator is created with non matching arguments' do
      expect_offense(<<~RUBY)
        def m(...)
          return to_enum(:m, x, ...) unless block_given?
                 ^^^^^^^^^^^^^^^^^^^ Ensure you correctly provided all the arguments.
        end
      RUBY
    end

    it 'does not register an offense when enumerator is created with the correct arguments' do
      expect_no_offenses(<<~RUBY)
        def m(...)
          return to_enum(:m, ...) unless block_given?
        end
      RUBY
    end
  end
end
