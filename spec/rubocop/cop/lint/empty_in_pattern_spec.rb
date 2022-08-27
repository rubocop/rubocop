# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyInPattern, :config do
  let(:cop_config) { { 'AllowComments' => false } }

  context 'when a `in` body is missing', :ruby27 do
    it 'registers an offense for a missing `in` body' do
      expect_offense(<<~RUBY)
        case foo
        in [a] then 1
        in [a, b] # nothing
        ^^^^^^^^^ Avoid `in` branches without a body.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing `in` body followed by `else`' do
      expect_offense(<<~RUBY)
        case foo
        in [a] then 1
        in [a, b] # nothing
        ^^^^^^^^^ Avoid `in` branches without a body.
        else 3
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing `in` ... `then` body' do
      expect_offense(<<~RUBY)
        case foo
        in [a] then 1
        in [a, b] then # nothing
        ^^^^^^^^^ Avoid `in` branches without a body.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing `in` ... then `body` followed by `else`' do
      expect_offense(<<~RUBY)
        case foo
        in [a] then 1
        in [a, b] then # nothing
        ^^^^^^^^^ Avoid `in` branches without a body.
        else 3
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing `in` body with a comment' do
      expect_offense(<<~RUBY)
        case foo
        in [a]
          1
        in [a, b]
        ^^^^^^^^^ Avoid `in` branches without a body.
          # nothing
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing `in` body with a comment followed by `else`' do
      expect_offense(<<~RUBY)
        case foo
        in [a]
          1
        in [a, b]
        ^^^^^^^^^ Avoid `in` branches without a body.
          # nothing
        else
          3
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'when a `in` body is present', :ruby27 do
    it 'accepts `case` with `in` ... `then` statements' do
      expect_no_offenses(<<~RUBY)
        case foo
        in [a] then 1
        in [a, b] then 2
        end
      RUBY
    end

    it 'accepts `case` with `in` ... `then` statements and else clause' do
      expect_no_offenses(<<~RUBY)
        case foo
        in [a] then 1
        in [a, b] then 2
        else 3
        end
      RUBY
    end

    it 'accepts `case` with `in` bodies' do
      expect_no_offenses(<<~RUBY)
        case foo
        in [a]
          1
        in [a, b]
          2
        end
      RUBY
    end

    it 'accepts `case` with `in` bodies and `else` clause' do
      expect_no_offenses(<<~RUBY)
        case foo
        in [a]
          1
        in [a, b]
          2
        else
          3
        end
      RUBY
    end
  end

  context 'when `AllowComments: true`', :ruby27 do
    let(:cop_config) { { 'AllowComments' => true } }

    it 'registers an offense for empty `in` when comment is in another branch' do
      expect_offense(<<~RUBY)
        case condition
        in [a]
        ^^^^^^ Avoid `in` branches without a body.
        in [a, b]
          # do nothing
        end
      RUBY
    end

    it 'accepts an empty `in` body with a comment' do
      expect_no_offenses(<<~RUBY)
        case condition
        in [a]
          do_something
        in [a, b]
          # do nothing
        end
      RUBY
    end
  end

  context 'when `AllowComments: false`', :ruby27 do
    let(:cop_config) { { 'AllowComments' => false } }

    it 'registers an offense for empty `in` body with a comment' do
      expect_offense(<<~RUBY)
        case condition
        in [a]
          do_something
        in [a, b]
        ^^^^^^^^^ Avoid `in` branches without a body.
          # do nothing
        end
      RUBY

      expect_no_corrections
    end
  end
end
