# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::WithIndexOffset, :config do
  # each_with_index with index + N

  it 'registers an offense when using `index + 1` inside `each_with_index`' do
    expect_offense(<<~RUBY)
      array.each_with_index do |item, index|
            ^^^^^^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
        puts index + 1
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(1) do |item, index|
        puts index
      end
    RUBY
  end

  it 'registers an offense when using `1 + index` inside `each_with_index`' do
    expect_offense(<<~RUBY)
      array.each_with_index do |item, index|
            ^^^^^^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
        puts 1 + index
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(1) do |item, index|
        puts index
      end
    RUBY
  end

  it 'registers an offense when using `index - 1` inside `each_with_index`' do
    expect_offense(<<~RUBY)
      array.each_with_index do |item, index|
            ^^^^^^^^^^^^^^^ Use `with_index(-1)` instead of manually computing the offset.
        puts index - 1
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(-1) do |item, index|
        puts index
      end
    RUBY
  end

  it 'registers an offense when using `index.succ` inside `each_with_index`' do
    expect_offense(<<~RUBY)
      array.each_with_index do |item, index|
            ^^^^^^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
        puts index.succ
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(1) do |item, index|
        puts index
      end
    RUBY
  end

  it 'registers an offense when using `index.next` inside `each_with_index`' do
    expect_offense(<<~RUBY)
      array.each_with_index do |item, index|
            ^^^^^^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
        puts index.next
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(1) do |item, index|
        puts index
      end
    RUBY
  end

  it 'registers an offense when using `index.pred` inside `each_with_index`' do
    expect_offense(<<~RUBY)
      array.each_with_index do |item, index|
            ^^^^^^^^^^^^^^^ Use `with_index(-1)` instead of manually computing the offset.
        puts index.pred
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(-1) do |item, index|
        puts index
      end
    RUBY
  end

  it 'registers an offense when using `index + 5` inside `each_with_index`' do
    expect_offense(<<~RUBY)
      array.each_with_index do |item, index|
            ^^^^^^^^^^^^^^^ Use `with_index(5)` instead of manually computing the offset.
        puts index + 5
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(5) do |item, index|
        puts index
      end
    RUBY
  end

  # each.with_index with index + N

  it 'registers an offense when using `index + 1` inside `each.with_index`' do
    expect_offense(<<~RUBY)
      array.each.with_index do |item, index|
                 ^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
        puts index + 1
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(1) do |item, index|
        puts index
      end
    RUBY
  end

  # each.with_index(0) with index + N

  it 'registers an offense when using `index + 1` inside `each.with_index(0)`' do
    expect_offense(<<~RUBY)
      array.each.with_index(0) do |item, index|
                 ^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
        puts index + 1
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(1) do |item, index|
        puts index
      end
    RUBY
  end

  # Multiple usages with same offset

  it 'registers an offense when all usages have the same offset' do
    expect_offense(<<~RUBY)
      array.each_with_index do |item, index|
            ^^^^^^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
        x = index + 1
        y = index + 1
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(1) do |item, index|
        x = index
        y = index
      end
    RUBY
  end

  # Safe navigation

  it 'registers an offense when using safe navigation' do
    expect_offense(<<~RUBY)
      array&.each_with_index do |item, index|
             ^^^^^^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
        puts index + 1
      end
    RUBY

    expect_correction(<<~RUBY)
      array&.each.with_index(1) do |item, index|
        puts index
      end
    RUBY
  end

  # Single-line block

  it 'registers an offense for single-line block with braces' do
    expect_offense(<<~RUBY)
      array.each_with_index { |item, index| puts index + 1 }
            ^^^^^^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index(1) { |item, index| puts index }
    RUBY
  end

  # No offense cases

  it 'does not register an offense when index is used without offset' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index do |item, index|
        puts index
      end
    RUBY
  end

  it 'does not register an offense for mixed usage (offset and bare)' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index do |item, index|
        puts index + 1
        log(index)
      end
    RUBY
  end

  it 'does not register an offense when different offsets are used' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index do |item, index|
        puts index + 1
        log(index + 2)
      end
    RUBY
  end

  it 'does not register an offense when `with_index` already has a non-zero argument' do
    expect_no_offenses(<<~RUBY)
      array.each.with_index(5) do |item, index|
        puts index + 1
      end
    RUBY
  end

  it 'does not register an offense when offset is a variable' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index do |item, index|
        puts index + n
      end
    RUBY
  end

  it 'does not register an offense when block has no body' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index do |item, index|
      end
    RUBY
  end

  it 'does not register an offense when block has only one argument' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index do |item|
        puts item
      end
    RUBY
  end

  it 'does not register an offense when index is not used' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index do |item, _index|
        puts item
      end
    RUBY
  end

  # Numbered parameter blocks (Ruby 2.7+)

  context 'Ruby 2.7', :ruby27 do
    it 'registers an offense when using `_2 + 1` inside `each_with_index` numblock' do
      expect_offense(<<~RUBY)
        array.each_with_index { puts _2 + 1 }
              ^^^^^^^^^^^^^^^ Use `with_index(1)` instead of manually computing the offset.
      RUBY

      expect_correction(<<~RUBY)
        array.each.with_index(1) { puts _2 }
      RUBY
    end

    it 'does not register an offense for numblock with mixed usage' do
      expect_no_offenses(<<~RUBY)
        array.each_with_index { puts _2 + 1; log(_2) }
      RUBY
    end
  end

  # it-block (Ruby 3.4+)

  context 'Ruby 3.4', :ruby34 do
    it 'does not register an offense for itblock (single implicit param cannot capture index)' do
      expect_no_offenses(<<~RUBY)
        array.each_with_index { puts it }
      RUBY
    end
  end
end
