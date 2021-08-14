# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DoubleNegation, :config do
  let(:cop_config) { { 'EnforcedStyle' => enforced_style } }

  shared_examples 'common' do
    it 'registers an offense and corrects for `!!` when not a return location' do
      expect_offense(<<~RUBY)
        def foo?
          foo
          !!test.something
          ^ Avoid the use of double negation (`!!`).
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          foo
          !test.something.nil?
          bar
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!`' do
      expect_offense(<<~RUBY)
        !!test.something
        ^ Avoid the use of double negation (`!!`).
      RUBY

      expect_correction(<<~RUBY)
        !test.something.nil?
      RUBY
    end

    it 'does not register an offense for !' do
      expect_no_offenses('!test.something')
    end

    it 'does not register an offense for `not not`' do
      expect_no_offenses('not not test.something')
    end
  end

  context 'when `EnforcedStyle: allowed_in_returns`' do
    let(:enforced_style) { 'allowed_in_returns' }

    include_examples 'common'

    it 'does not register an offense for `!!` when return location' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        end
      RUBY
    end

    it 'does not register an offense for `!!` when using `return` keyword' do
      expect_no_offenses(<<~RUBY)
        def foo?
          return !!bar.do_something if condition
          baz
          !!qux
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `rescue`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        rescue
          qux
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `ensure`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        ensure
          qux
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `rescue` and `ensure`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        rescue
          qux
        ensure
          corge
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `rescue`, `else`, and `ensure`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        rescue
          qux
        else
          quux
        ensure
          corge
        end
      RUBY
    end
  end

  context 'when `EnforcedStyle: forbidden`' do
    let(:enforced_style) { 'forbidden' }

    include_examples 'common'

    it 'registers an offense and corrects for `!!` when return location' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` when using `return` keyword' do
      expect_offense(<<~RUBY)
        def foo?
          return !!bar.do_something if condition
                 ^ Avoid the use of double negation (`!!`).
          baz
          !!bar
          ^ Avoid the use of double negation (`!!`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          return !bar.do_something.nil? if condition
          baz
          !bar.nil?
        end
      RUBY
    end

    it 'registers an offense for `!!` when return location and using `rescue`' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        rescue
          qux
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        rescue
          qux
        end
      RUBY
    end

    it 'registers an offense for `!!` when return location and using `ensure`' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        ensure
          qux
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        ensure
          qux
        end
      RUBY
    end

    it 'registers an offense for `!!` when return location and using `rescue` and `ensure`' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        rescue
          baz
        ensure
          qux
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        rescue
          baz
        ensure
          qux
        end
      RUBY
    end

    it 'registers an offense for `!!` when return location and using `rescue`, `else`, and `ensure`' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        rescue
          qux
        else
          quux
        ensure
          corge
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        rescue
          qux
        else
          quux
        ensure
          corge
        end
      RUBY
    end
  end
end
