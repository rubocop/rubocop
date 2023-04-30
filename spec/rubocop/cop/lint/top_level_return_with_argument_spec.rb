# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::TopLevelReturnWithArgument, :config do
  context 'Code segment with only top-level return statement' do
    it 'expects no offense from the return without arguments' do
      expect_no_offenses(<<~RUBY)
        return
      RUBY
    end

    it 'expects offense from the return with arguments' do
      expect_offense(<<~RUBY)
        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY

      expect_correction(<<~RUBY)
        return
      RUBY
    end

    it 'expects multiple offenses from the return with arguments statements' do
      expect_offense(<<~RUBY)
        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY

      expect_correction(<<~RUBY)
        return

        return

        return
      RUBY
    end
  end

  context 'Code segment with block level returns other than the top-level return' do
    it 'expects no offense from the return without arguments' do
      expect_no_offenses(<<~RUBY)
        foo

        [1, 2, 3, 4, 5].each { |n| return n }

        return

        bar
      RUBY
    end

    it 'expects offense from the return with arguments' do
      expect_offense(<<~RUBY)
        foo

        [1, 2, 3, 4, 5].each { |n| return n }

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        bar
      RUBY

      expect_correction(<<~RUBY)
        foo

        [1, 2, 3, 4, 5].each { |n| return n }

        return

        bar
      RUBY
    end
  end

  context 'Code segment with method-level return statements' do
    it 'expects offense when method-level & top-level return co-exist' do
      expect_offense(<<~RUBY)
        def method
          return 'Hello World'
        end

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY

      expect_correction(<<~RUBY)
        def method
          return 'Hello World'
        end

        return
      RUBY
    end
  end

  context 'Code segment with inline if along with top-level return' do
    it 'expects no offense from the return without arguments' do
      expect_no_offenses(<<~RUBY)
        foo

        return if 1 == 1

        bar

        def method
          return "Hello World" if 1 == 1
        end
      RUBY
    end

    it 'expects multiple offense from the return with arguments' do
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

      expect_correction(<<~RUBY)
        foo
        return if 1 == 1
        bar
        return
        return

        def method
          return "Hello World" if 1 == 1
        end
      RUBY
    end
  end

  context 'Code segment containing semi-colon separated statements' do
    it 'expects an offense from the return with arguments and multi-line code' do
      expect_offense(<<~RUBY)
        foo

        if a == b; warn 'hey'; return 42; end
                               ^^^^^^^^^ Top level return with argument detected.

        bar
      RUBY

      expect_correction(<<~RUBY)
        foo

        if a == b; warn 'hey'; return; end

        bar
      RUBY
    end

    it 'expects no offense from the return with arguments and multi-line code' do
      expect_no_offenses(<<~RUBY)
        foo

        if a == b; warn 'hey'; return; end

        bar
      RUBY
    end
  end
end
