# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ItWithoutArgumentsInBlock, :config do
  it 'registers an offense when using `it` without arguments in the single line block' do
    expect_offense(<<~RUBY)
      0.times { it }
                ^^ `it` calls without arguments will refer to the first block param in Ruby 3.4; use `it()` or `self.it`.
    RUBY
  end

  it 'registers an offense when using `it` without arguments in the multiline block' do
    expect_offense(<<~RUBY)
      0.times do
        it
        ^^ `it` calls without arguments will refer to the first block param in Ruby 3.4; use `it()` or `self.it`.
        it = 1
        it
      end
    RUBY
  end

  it 'does not register an offense when using `it` with arguments in the single line block' do
    expect_no_offenses(<<~RUBY)
      0.times { it(42) }
    RUBY
  end

  it 'does not register an offense when using `it` with block argument in the single line block' do
    expect_no_offenses(<<~RUBY)
      0.times { it { do_something } }
    RUBY
  end

  it 'does not register an offense when using `it()` in the single line block' do
    expect_no_offenses(<<~RUBY)
      0.times { it() }
    RUBY
  end

  it 'does not register an offense when using `self.it` in the single line block' do
    expect_no_offenses(<<~RUBY)
      0.times { self.it }
    RUBY
  end

  it 'does not register an offense when using `it` with arguments in the multiline block' do
    expect_no_offenses(<<~RUBY)
      0.times do
        it(42)
        it = 1
        it
      end
    RUBY
  end

  it 'does not register an offense when using `it` with block argument in the multiline block' do
    expect_no_offenses(<<~RUBY)
      0.times do
        it { do_something }
        it = 1
        it
      end
    RUBY
  end

  it 'does not register an offense when using `it()` in the multiline block' do
    expect_no_offenses(<<~RUBY)
      0.times do
        it()
        it = 1
        it
      end
    RUBY
  end

  it 'does not register an offense when using `self.it` without arguments in the multiline block' do
    expect_no_offenses(<<~RUBY)
      0.times do
        self.it
        it = 1
        it
      end
    RUBY
  end

  it 'does not register an offense when using `it` without arguments in `if` body' do
    expect_no_offenses(<<~RUBY)
      if false
        it
      end
    RUBY
  end

  it 'does not register an offense when using `it` without arguments in `def` body' do
    expect_no_offenses(<<~RUBY)
      def foo
        it
      end
    RUBY
  end

  it 'does not register an offense when using `it` without arguments in the block with empty block parameter' do
    expect_no_offenses(<<~RUBY)
      0.times { ||
        it
      }
    RUBY
  end

  it 'does not register an offense when using `it` without arguments in the block with useless block parameter' do
    expect_no_offenses(<<~RUBY)
      0.times { |_n|
        it
      }
    RUBY
  end

  it 'does not register an offense when using `it` inner local variable in block' do
    expect_no_offenses(<<~RUBY)
      0.times do
        it = 1
        it
      end
    RUBY
  end

  it 'does not register an offense when using `it` outer local variable in block' do
    expect_no_offenses(<<~RUBY)
      it = 1
      0.times { it }
    RUBY
  end

  it 'does not register an offense when using empty block' do
    expect_no_offenses(<<~RUBY)
      0.times {}
    RUBY
  end
end
