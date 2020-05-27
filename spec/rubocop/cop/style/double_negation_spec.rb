# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DoubleNegation, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  shared_examples 'common' do
    it 'does not register an offense for `!!` when not a return location' do
      expect_offense(<<~RUBY)
        def foo?
          foo
          !!test.something
          ^ Avoid the use of double negation (`!!`).
          bar
        end
      RUBY
    end

    it 'registers an offense for `!!`' do
      expect_offense(<<~RUBY)
        !!test.something
        ^ Avoid the use of double negation (`!!`).
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
  end

  context 'when `EnforcedStyle: forbidden`' do
    let(:enforced_style) { 'forbidden' }

    include_examples 'common'

    it 'registers an offense for `!!` when return location' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        end
      RUBY
    end

    it 'does not register an offense for `!!` when using `return` keyword' do
      expect_offense(<<~RUBY)
        def foo?
          return !!bar.do_something if condition
                 ^ Avoid the use of double negation (`!!`).
          baz
          !!bar
          ^ Avoid the use of double negation (`!!`).
        end
      RUBY
    end
  end
end
