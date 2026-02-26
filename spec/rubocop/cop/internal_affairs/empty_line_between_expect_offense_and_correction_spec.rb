# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::EmptyLineBetweenExpectOffenseAndCorrection, :config do
  it 'registers and corrects an offense when using no empty line between `expect_offense` and `expect_correction` ' \
     'with heredoc argument' do
    expect_offense(<<~RUBY)
      expect_offense(<<~CODE)
        bad_method
      CODE
      ^^^^ Add empty line between `expect_offense` and `expect_correction`.
      expect_correction(<<~CODE)
        good_good
      CODE
    RUBY

    expect_correction(<<~RUBY)
      expect_offense(<<~CODE)
        bad_method
      CODE

      expect_correction(<<~CODE)
        good_good
      CODE
    RUBY
  end

  it 'registers and corrects an offense when using no empty line between `expect_offense` and `expect_correction`' \
     'with variable argument' do
    expect_offense(<<~RUBY)
      expect_offense(code)
      ^^^^^^^^^^^^^^^^^^^^ Add empty line between `expect_offense` and `expect_correction`.
      expect_correction(code)
    RUBY

    expect_correction(<<~RUBY)
      expect_offense(code)

      expect_correction(code)
    RUBY
  end

  it 'registers and corrects an offense when using no empty line between `expect_offense` and `expect_no_corrections`' do
    expect_offense(<<~RUBY)
      expect_offense('bad_method')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line between `expect_offense` and `expect_no_corrections`.
      expect_no_corrections
    RUBY

    expect_correction(<<~RUBY)
      expect_offense('bad_method')

      expect_no_corrections
    RUBY
  end

  it 'does not register an offense when using only `expect_offense`' do
    expect_no_offenses(<<~RUBY)
      expect_offense(<<~CODE)
        bad_method
      CODE
    RUBY
  end

  it 'does not register an offense when using empty line between `expect_offense` and `expect_correction` ' \
     'with heredoc argument' do
    expect_no_offenses(<<~RUBY)
      expect_offense(<<~CODE)
        bad_method
      CODE

      expect_correction(<<~CODE)
        good_method
      CODE
    RUBY
  end

  it 'does not register an offense when using empty line between `expect_offense` and `expect_correction`' \
     'with variable argument' do
    expect_no_offenses(<<~RUBY)
      expect_offense(bad_method)

      expect_correction(good_method)
    RUBY
  end

  it 'does not register an offense when using empty line between `expect_offense` and `expect_no_corrections`' do
    expect_no_offenses(<<~RUBY)
      expect_offense('bad_method')

      expect_no_corrections
    RUBY
  end
end
