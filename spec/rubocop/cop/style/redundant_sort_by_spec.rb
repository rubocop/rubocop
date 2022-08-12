# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantSortBy, :config do
  it 'autocorrects array.sort_by { |x| x }' do
    expect_offense(<<~RUBY)
      array.sort_by { |x| x }
            ^^^^^^^^^^^^^^^^^ Use `sort` instead of `sort_by { |x| x }`.
    RUBY

    expect_correction(<<~RUBY)
      array.sort
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'autocorrects array.sort_by { |x| x }' do
      expect_offense(<<~RUBY)
        array.sort_by { _1 }
              ^^^^^^^^^^^^^^ Use `sort` instead of `sort_by { _1 }`.
      RUBY

      expect_correction(<<~RUBY)
        array.sort
      RUBY
    end
  end

  it 'autocorrects array.sort_by { |y| y }' do
    expect_offense(<<~RUBY)
      array.sort_by { |y| y }
            ^^^^^^^^^^^^^^^^^ Use `sort` instead of `sort_by { |y| y }`.
    RUBY

    expect_correction(<<~RUBY)
      array.sort
    RUBY
  end

  it 'autocorrects array.sort_by do |x| x end' do
    expect_offense(<<~RUBY)
      array.sort_by do |x|
            ^^^^^^^^^^^^^^ Use `sort` instead of `sort_by { |x| x }`.
        x
      end
    RUBY

    expect_correction(<<~RUBY)
      array.sort
    RUBY
  end
end
