# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyWhen, :config do
  let(:cop_config) { { 'AllowComments' => false } }

  context 'when a `when` body is missing' do
    it 'registers an offense for a missing when body' do
      expect_offense(<<~RUBY)
        case foo
        when :bar then 1
        when :baz # nothing
        ^^^^^^^^^ Avoid `when` branches without a body.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing when body followed by else' do
      expect_offense(<<~RUBY)
        case foo
        when :bar then 1
        when :baz # nothing
        ^^^^^^^^^ Avoid `when` branches without a body.
        else 3
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing when ... then body' do
      expect_offense(<<~RUBY)
        case foo
        when :bar then 1
        when :baz then # nothing
        ^^^^^^^^^ Avoid `when` branches without a body.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing when ... then body followed by else' do
      expect_offense(<<~RUBY)
        case foo
        when :bar then 1
        when :baz then # nothing
        ^^^^^^^^^ Avoid `when` branches without a body.
        else 3
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing when body with a comment' do
      expect_offense(<<~RUBY)
        case foo
        when :bar
          1
        when :baz
        ^^^^^^^^^ Avoid `when` branches without a body.
          # nothing
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for missing when body with a comment followed by else' do
      expect_offense(<<~RUBY)
        case foo
        when :bar
          1
        when :baz
        ^^^^^^^^^ Avoid `when` branches without a body.
          # nothing
        else
          3
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when case line has no expression' do
      expect_offense(<<~RUBY)
        case
        when :bar
          1
        when :baz
        ^^^^^^^^^ Avoid `when` branches without a body.
          # nothing
        else
          3
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'when a `when` body is present' do
    it 'accepts case with when ... then statements' do
      expect_no_offenses(<<~RUBY)
        case foo
        when :bar then 1
        when :baz then 2
        end
      RUBY
    end

    it 'accepts case with when ... then statements and else clause' do
      expect_no_offenses(<<~RUBY)
        case foo
        when :bar then 1
        when :baz then 2
        else 3
        end
      RUBY
    end

    it 'accepts case with when bodies' do
      expect_no_offenses(<<~RUBY)
        case foo
        when :bar
          1
        when :baz
          2
        end
      RUBY
    end

    it 'accepts case with when bodies and else clause' do
      expect_no_offenses(<<~RUBY)
        case foo
        when :bar
          1
        when :baz
          2
        else
          3
        end
      RUBY
    end

    it 'accepts with no case line expression' do
      expect_no_offenses(<<~RUBY)
        case
        when :bar
          1
        when :baz
          2
        else
          3
        end
      RUBY
    end
  end

  context 'when `AllowComments: true`' do
    let(:cop_config) { { 'AllowComments' => true } }

    it 'accepts an empty when body with a comment' do
      expect_no_offenses(<<~RUBY)
        case condition
        when foo
          do_something
        when bar
          # do nothing
        end
      RUBY
    end

    it 'registers an offense for missing when body without a comment' do
      expect_offense(<<~RUBY)
        case condition
        when foo
          42 # magic number
        when bar
        ^^^^^^^^ Avoid `when` branches without a body.
        when baz # more comments mixed
          21 # another magic number
        end
      RUBY
    end

    it 'accepts an empty when ... then body with a comment' do
      expect_no_offenses(<<~RUBY)
        case condition
        when foo
          do_something
        when bar then # do nothing
        end
      RUBY
    end
  end

  context 'when `AllowComments: false`' do
    let(:cop_config) { { 'AllowComments' => false } }

    it 'registers an offense for empty when body with a comment' do
      expect_offense(<<~RUBY)
        case condition
        when foo
          do_something
        when bar
        ^^^^^^^^ Avoid `when` branches without a body.
          # do nothing
        end
      RUBY

      expect_no_corrections
    end
  end
end
