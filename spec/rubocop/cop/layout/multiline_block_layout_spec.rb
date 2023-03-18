# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineBlockLayout, :config do
  it 'registers an offense for missing newline in do/end block w/o params' do
    expect_offense(<<~RUBY)
      test do foo
              ^^^ Block body expression is on the same line as the block start.
      end
    RUBY

    expect_correction(<<~RUBY)
      test do#{trailing_whitespace}
        foo
      end
    RUBY
  end

  it 'registers an offense and corrects for missing newline in {} block w/o params' do
    expect_offense(<<~RUBY)
      test { foo
             ^^^ Block body expression is on the same line as the block start.
      }
    RUBY

    expect_correction(<<~RUBY)
      test {#{trailing_whitespace}
        foo
      }
    RUBY
  end

  it 'registers an offense and corrects for missing newline in do/end block with params' do
    expect_offense(<<~RUBY)
      test do |x| foo
                  ^^^ Block body expression is on the same line as the block start.
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x|#{trailing_whitespace}
        foo
      end
    RUBY
  end

  it 'registers an offense and corrects for missing newline in {} block with params' do
    expect_offense(<<~RUBY)
      test { |x| foo
                 ^^^ Block body expression is on the same line as the block start.
      }
    RUBY

    expect_correction(<<~RUBY)
      test { |x|#{trailing_whitespace}
        foo
      }
    RUBY
  end

  it 'does not register an offense for one-line do/end blocks' do
    expect_no_offenses('test do foo end')
  end

  it 'does not register an offense for one-line {} blocks' do
    expect_no_offenses('test { foo }')
  end

  it 'does not register offenses when there is a newline for do/end block' do
    expect_no_offenses(<<~RUBY)
      test do
        foo
      end
    RUBY
  end

  it 'does not register offenses when there are too many parameters to fit on one line' do
    expect_no_offenses(<<~RUBY)
      some_result = lambda do |
        so_many,
        parameters,
        it_will,
        be_too_long,
        for_one_line,
        line_length,
        has_increased,
        add_3_more|
        do_something
      end
    RUBY
  end

  it 'registers offenses when there are not too many parameters to fit on one line' do
    expect_offense(<<~RUBY)
      some_result = lambda do |
                              ^ Block argument expression is not on the same line as the block start.
        so_many,
        parameters,
        it_will,
        be_too_long,
        for_one_line,
        line_length,
        has_increased,
        add_3_mor|
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      some_result = lambda do |so_many, parameters, it_will, be_too_long, for_one_line, line_length, has_increased, add_3_mor|
        do_something
      end
    RUBY
  end

  it 'considers the extra space required to join the lines together' do
    expect_no_offenses(<<~RUBY)
      some_result = lambda do
        |so_many, parameters, it_will, be_too_long, for_one_line, line_length, has_increased, add_3_more|
        do_something
      end
    RUBY
  end

  it 'does not error out when the block is empty' do
    expect_no_offenses(<<~RUBY)
      test do |x|
      end
    RUBY
  end

  it 'does not register offenses when there is a newline for {} block' do
    expect_no_offenses(<<~RUBY)
      test {
        foo
      }
    RUBY
  end

  it 'registers offenses and corrects for lambdas' do
    expect_offense(<<~RUBY)
      -> (x) do foo
                ^^^ Block body expression is on the same line as the block start.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      -> (x) do#{trailing_whitespace}
        foo
        bar
      end
    RUBY
  end

  it 'registers offenses and corrects for new lambda literal syntax' do
    expect_offense(<<~RUBY)
      -> x do foo
              ^^^ Block body expression is on the same line as the block start.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      -> x do#{trailing_whitespace}
        foo
        bar
      end
    RUBY
  end

  it 'registers an offense and corrects line-break before arguments' do
    expect_offense(<<~RUBY)
      test do
        |x| play_with(x)
        ^^^ Block argument expression is not on the same line as the block start.
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x|
        play_with(x)
      end
    RUBY
  end

  it 'registers an offense and corrects line-break before arguments with empty block' do
    expect_offense(<<~RUBY)
      test do
        |x|
        ^^^ Block argument expression is not on the same line as the block start.
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x|
      end
    RUBY
  end

  it 'registers an offense and corrects line-break within arguments' do
    expect_offense(<<~RUBY)
      test do |x,
              ^^^ Block argument expression is not on the same line as the block start.
        y|
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x, y|
      end
    RUBY
  end

  it 'registers an offense and corrects a do/end block with a multi-line body' do
    expect_offense(<<~RUBY)
      test do |foo| bar
                    ^^^ Block body expression is on the same line as the block start.
        test
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |foo|#{trailing_whitespace}
        bar
        test
      end
    RUBY
  end

  it 'autocorrects in more complex case with lambda and assignment, and ' \
     'aligns the next line two spaces out from the start of the block' do
    expect_offense(<<~RUBY)
      x = -> (y) { foo
                   ^^^ Block body expression is on the same line as the block start.
        bar
      }
    RUBY

    expect_correction(<<~RUBY)
      x = -> (y) {#{trailing_whitespace}
            foo
        bar
      }
    RUBY
  end

  it 'registers an offense and corrects for missing newline before opening parenthesis `(` for block body' do
    expect_offense(<<~RUBY)
      foo do |o| (
                 ^ Block body expression is on the same line as the block start.
          bar
        )
      end
    RUBY

    expect_correction(<<~RUBY)
      foo do |o|#{trailing_whitespace}
        (
          bar
        )
      end
    RUBY
  end

  it 'registers an offense and corrects a line-break within arguments' do
    expect_offense(<<~RUBY)
      test do |x,
              ^^^ Block argument expression is not on the same line as the block start.
        y| play_with(x, y)
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x, y|
        play_with(x, y)
      end
    RUBY
  end

  it 'registers an offense and corrects a line break within destructured arguments' do
    expect_offense(<<~RUBY)
      test do |(x,
              ^^^^ Block argument expression is not on the same line as the block start.
        y)| play_with(x, y)
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |(x, y)|
        play_with(x, y)
      end
    RUBY
  end

  it "doesn't move end keyword in a way which causes infinite loop " \
     'in combination with Style/BlockEndNewLine' do
    expect_offense(<<~RUBY)
      def f
        X.map do |(a,
                 ^^^^ Block argument expression is not on the same line as the block start.
        b)|
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def f
        X.map do |(a, b)|
        end
      end
    RUBY
  end

  it 'does not remove a trailing comma when only one argument is present' do
    expect_offense(<<~RUBY)
      def f
        X.map do |
                 ^ Block argument expression is not on the same line as the block start.
          a,
        |
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def f
        X.map do |a,|
        end
      end
    RUBY
  end

  it 'autocorrects nested parens correctly' do
    expect_offense(<<~RUBY)
      def f
        X.map do |
                 ^ Block argument expression is not on the same line as the block start.
          (((a), b), c)
        |
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def f
        X.map do |(((a), b), c)|
        end
      end
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers an offense and corrects for missing newline in {} block w/o params' do
      expect_offense(<<~RUBY)
        test { _1
               ^^ Block body expression is on the same line as the block start.
        }
      RUBY

      expect_correction(<<~RUBY)
        test {#{trailing_whitespace}
          _1
        }
      RUBY
    end

    it 'registers an offense and corrects for missing newline in do/end block with params' do
      expect_offense(<<~RUBY)
        test do _1
                ^^ Block body expression is on the same line as the block start.
        end
      RUBY

      expect_correction(<<~RUBY)
        test do#{trailing_whitespace}
          _1
        end
      RUBY
    end
  end
end
