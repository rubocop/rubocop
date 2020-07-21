# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::TopLevelReturnWithArgument, :config do
  context 'Code segment with only top-level return statement' do
    it 'Expects no offense from the return without arguments' do
      expect_no_offenses(<<~RUBY)
        return
      RUBY
    end

    it 'Expects offense from the return with arguments' do
      expect_offense(<<~RUBY)
        return 1, 2, 3 # Should raise a `top level return with argument detected` offense
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY
    end

    it 'Expects multiple offenses from the return with arguments statements' do
      expect_offense(<<~RUBY)
        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY
    end
  end

  context 'Code segment with block level returns other than the top-level return' do
    it 'Expects no offense from the return without arguments' do
      expect_no_offenses(<<~RUBY)
        foo

        [1, 2, 3, 4, 5].each { |n| return n }

        return # Should raise a `top level return with argument detected` offense

        bar
      RUBY
    end

    it 'Expects offense from the return with arguments' do
      expect_offense(<<~RUBY)
        foo

        [1, 2, 3, 4, 5].each { |n| return n }

        return 1, 2, 3 # Should raise a `top level return with argument detected` offense
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        bar
      RUBY
    end
  end

  context 'Code segment with method-level return statements' do
    it 'Expects no offense from the method-level return statement' do
      expect_no_offenses(<<~RUBY)
        def method
          return 'Hello World'
        end
      RUBY
    end

    it 'Expects offense when method-level & top-level return co-exist' do
      expect_offense(<<~RUBY)
        def method
          return 'Hello World'
        end

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY
    end
  end

  context 'Code segment with inline if along with top-level return' do
    it 'Expects no offense from the return without arguments' do
      expect_no_offenses(<<~RUBY)
        foo

        return if 1 == 1

        bar

        def method
          return "Hello World" if 1 == 1
        end
      RUBY
    end

    it 'Expects multiple offense from the return with arguments' do
      expect_offense(<<~RUBY)
        foo
        return 1, 2, 3 if 1 == 1
        ^^^^^^^^^^^^^^ Top level return with argument detected.
        bar
        return 2
        ^^^^^^^^ Top level return with argument detected.
        return 3
        ^^^^^^^^ Top level return with argument detected.

        def method
          return "Hello World" if 1 == 1
        end
      RUBY
    end
  end
end
