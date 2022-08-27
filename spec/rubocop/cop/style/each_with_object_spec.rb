# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EachWithObject, :config do
  it 'finds inject and reduce with passed in and returned hash' do
    expect_offense(<<~RUBY)
      [].inject({}) { |a, e| a }
         ^^^^^^ Use `each_with_object` instead of `inject`.

      [].reduce({}) do |a, e|
         ^^^^^^ Use `each_with_object` instead of `reduce`.
        a[e] = 1
        a[e] = 1
        a
      end
    RUBY

    expect_correction(<<~RUBY)
      [].each_with_object({}) { |e, a|  }

      [].each_with_object({}) do |e, a|
        a[e] = 1
        a[e] = 1
      end
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'finds inject and reduce with passed in and returned hash and numblock' do
      expect_offense(<<~RUBY)
        [].reduce({}) do
           ^^^^^^ Use `each_with_object` instead of `reduce`.
          _1[_2] = 1
          _1
        end
      RUBY

      expect_correction(<<~RUBY)
        [].each_with_object({}) do
          _2[_1] = 1
          _2
        end
      RUBY
    end
  end

  it 'correctly autocorrects' do
    expect_offense(<<~RUBY)
      [1, 2, 3].inject({}) do |h, i|
                ^^^^^^ Use `each_with_object` instead of `inject`.
        h[i] = i
        h
      end
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].each_with_object({}) do |i, h|
        h[i] = i
      end
    RUBY
  end

  it 'correctly autocorrects with return value only' do
    expect_offense(<<~RUBY)
      [1, 2, 3].inject({}) do |h, i|
                ^^^^^^ Use `each_with_object` instead of `inject`.
        h
      end
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].each_with_object({}) do |i, h|
      end
    RUBY
  end

  it 'ignores inject and reduce with passed in, but not returned hash' do
    expect_no_offenses(<<~RUBY)
      [].inject({}) do |a, e|
        a + e
      end

      [].reduce({}) do |a, e|
        my_method e, a
      end
    RUBY
  end

  it 'ignores inject and reduce with empty body' do
    expect_no_offenses(<<~RUBY)
      [].inject({}) do |a, e|
      end

      [].reduce({}) { |a, e| }
    RUBY
  end

  it 'ignores inject and reduce with condition as body' do
    expect_no_offenses(<<~RUBY)
      [].inject({}) do |a, e|
        a = e if e
      end

      [].inject({}) do |a, e|
        if e
          a = e
        end
      end

      [].reduce({}) do |a, e|
        a = e ? e : 2
      end
    RUBY
  end

  it 'ignores inject and reduce passed in symbol' do
    expect_no_offenses('[].inject(:+)')
  end

  it 'does not blow up for reduce with no arguments' do
    expect_no_offenses('[1, 2, 3].inject { |a, e| a + e }')
  end

  it 'ignores inject/reduce with assignment to accumulator param in block' do
    expect_no_offenses(<<~RUBY)
      r = [1, 2, 3].reduce({}) do |memo, item|
        memo += item > 2 ? item : 0
        memo
      end
    RUBY
  end

  context 'when a simple literal is passed as initial value' do
    it 'ignores inject/reduce' do
      expect_no_offenses('array.reduce(0) { |a, e| a }')
    end
  end
end
