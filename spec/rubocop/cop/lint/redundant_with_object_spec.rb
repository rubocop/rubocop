# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantWithObject, :config do
  it 'registers an offense and corrects when using `ary.each_with_object { |v| v }`' do
    expect_offense(<<~RUBY)
      ary.each_with_object([]) { |v| v }
          ^^^^^^^^^^^^^^^^^^^^ Use `each` instead of `each_with_object`.
    RUBY

    expect_correction(<<~RUBY)
      ary.each { |v| v }
    RUBY
  end

  it 'registers an offense and corrects when using `ary.each.with_object([]) { |v| v }`' do
    expect_offense(<<~RUBY)
      ary.each.with_object([]) { |v| v }
               ^^^^^^^^^^^^^^^ Remove redundant `with_object`.
    RUBY

    expect_correction(<<~RUBY)
      ary.each { |v| v }
    RUBY
  end

  it 'registers an offense and corrects when using ary.each_with_object([]) do-end block' do
    expect_offense(<<~RUBY)
      ary.each_with_object([]) do |v|
          ^^^^^^^^^^^^^^^^^^^^ Use `each` instead of `each_with_object`.
        v
      end
    RUBY

    expect_correction(<<~RUBY)
      ary.each do |v|
        v
      end
    RUBY
  end

  it 'registers an offense and corrects when using ' \
     'ary.each_with_object do-end block without parentheses' do
    expect_offense(<<~RUBY)
      ary.each_with_object [] do |v|
          ^^^^^^^^^^^^^^^^^^^ Use `each` instead of `each_with_object`.
        v
      end
    RUBY

    expect_correction(<<~RUBY)
      ary.each do |v|
        v
      end
    RUBY
  end

  it 'an object is used as a block argument' do
    expect_no_offenses('ary.each_with_object([]) { |v, o| v; o }')
  end

  context 'when missing argument to `each_with_object`' do
    it 'does not register an offense when block has 2 arguments' do
      expect_no_offenses('ary.each_with_object { |v, o| v; o }')
    end

    it 'does not register an offense when block has 1 argument' do
      expect_no_offenses('ary.each_with_object { |v| v }')
    end
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers an offense and corrects when using `ary.each_with_object { _1 }`' do
      expect_offense(<<~RUBY)
        ary.each_with_object([]) { _1 }
            ^^^^^^^^^^^^^^^^^^^^ Use `each` instead of `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        ary.each { _1 }
      RUBY
    end

    it 'registers an offense and corrects when using `ary.each.with_object([]) { _1 }`' do
      expect_offense(<<~RUBY)
        ary.each.with_object([]) { _1 }
                 ^^^^^^^^^^^^^^^ Remove redundant `with_object`.
      RUBY

      expect_correction(<<~RUBY)
        ary.each { _1 }
      RUBY
    end
  end
end
