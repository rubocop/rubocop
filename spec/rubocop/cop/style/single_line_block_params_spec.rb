# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleLineBlockParams, :config do
  let(:cop_config) { { 'Methods' => [{ 'reduce' => %w[a e] }, { 'test' => %w[x y] }] } }

  it 'finds wrong argument names in calls with different syntax' do
    expect_offense(<<~RUBY)
      def m
        [0, 1].reduce { |c, d| c + d }
                        ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce{ |c, d| c + d }
                       ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5) { |c, d| c + d }
                           ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5){ |c, d| c + d }
                          ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce (5) { |c, d| c + d }
                            ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5) { |c, d| c + d }
                           ^^^^^^ Name `reduce` block params `|a, e|`.
        ala.test { |x, z| bala }
                   ^^^^^^ Name `test` block params `|x, y|`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m
        [0, 1].reduce { |a, e| a + e }
        [0, 1].reduce{ |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        [0, 1].reduce(5){ |a, e| a + e }
        [0, 1].reduce (5) { |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        ala.test { |x, y| bala }
      end
    RUBY
  end

  it 'allows calls with proper argument names' do
    expect_no_offenses(<<~RUBY)
      def m
        [0, 1].reduce { |a, e| a + e }
        [0, 1].reduce{ |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        [0, 1].reduce(5){ |a, e| a + e }
        [0, 1].reduce (5) { |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        ala.test { |x, y| bala }
      end
    RUBY
  end

  it 'allows an unused parameter to have a leading underscore' do
    expect_no_offenses('File.foreach(filename).reduce(0) { |a, _e| a + 1 }')
  end

  it 'finds incorrectly named parameters with leading underscores' do
    expect_offense(<<~RUBY)
      File.foreach(filename).reduce(0) { |_x, _y| }
                                         ^^^^^^^^ Name `reduce` block params `|_a, _e|`.
    RUBY

    expect_correction(<<~RUBY)
      File.foreach(filename).reduce(0) { |_a, _e| }
    RUBY
  end

  it 'ignores do..end blocks' do
    expect_no_offenses(<<~RUBY)
      def m
        [0, 1].reduce do |c, d|
          c + d
        end
      end
    RUBY
  end

  it 'ignores :reduce symbols' do
    expect_no_offenses(<<~RUBY)
      def m
        call_method(:reduce) { |a, b| a + b}
      end
    RUBY
  end

  it 'does not report when destructuring is used' do
    expect_no_offenses(<<~RUBY)
      def m
        test.reduce { |a, (id, _)| a + id}
      end
    RUBY
  end

  it 'does not report if no block arguments are present' do
    expect_no_offenses(<<~RUBY)
      def m
        test.reduce { true }
      end
    RUBY
  end

  it 'reports an offense if the names are partially correct' do
    expect_offense(<<~RUBY)
      test.reduce(x) { |a, b| foo(a, b) }
                       ^^^^^^ Name `reduce` block params `|a, e|`.
    RUBY

    expect_correction(<<~RUBY)
      test.reduce(x) { |a, e| foo(a, e) }
    RUBY
  end

  it 'reports an offense if the names are in reverse order' do
    expect_offense(<<~RUBY)
      test.reduce(x) { |e, a| foo(e, a) }
                       ^^^^^^ Name `reduce` block params `|a, e|`.
    RUBY

    expect_correction(<<~RUBY)
      test.reduce(x) { |a, e| foo(a, e) }
    RUBY
  end

  it 'does not report if the right names are used but not all arguments are given' do
    expect_no_offenses(<<~RUBY)
      test.reduce(x) { |a| foo(a) }
    RUBY
  end

  it 'reports an offense if the arguments names are wrong and not all arguments are given' do
    expect_offense(<<~RUBY)
      test.reduce(x) { |b| foo(b) }
                       ^^^ Name `reduce` block params `|a|`.
    RUBY

    expect_correction(<<~RUBY)
      test.reduce(x) { |a| foo(a) }
    RUBY
  end
end
