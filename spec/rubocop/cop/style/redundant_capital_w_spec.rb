# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantCapitalW, :config do
  it 'registers no offense for normal arrays of strings' do
    expect_no_offenses('["one", "two", "three"]')
  end

  it 'registers no offense for normal arrays of strings with interpolation' do
    expect_no_offenses('["one", "two", "th#{?r}ee"]')
  end

  it 'registers an offense for misused %W' do
    expect_offense(<<~RUBY)
      %W(cat dog)
      ^^^^^^^^^^^ Do not use `%W` unless interpolation is needed. If not, use `%w`.
    RUBY

    expect_correction(<<~RUBY)
      %w(cat dog)
    RUBY
  end

  it 'registers an offense for misused %W with different bracket' do
    expect_offense(<<~RUBY)
      %W[cat dog]
      ^^^^^^^^^^^ Do not use `%W` unless interpolation is needed. If not, use `%w`.
    RUBY

    expect_correction(<<~RUBY)
      %w[cat dog]
    RUBY
  end

  it 'registers no offense for %W with interpolation' do
    expect_no_offenses('%W(c#{?a}t dog)')
  end

  it 'registers no offense for %W with special characters' do
    expect_no_offenses(<<~'RUBY')
      def dangerous_characters
        %W(\000) +
        %W(\001) +
        %W(\027) +
        %W(\002) +
        %W(\003) +
        %W(\004) +
        %W(\005) +
        %W(\006) +
        %W(\007) +
        %W(\00) +
        %W(\a)
        %W(\s)
        %W(\n)
        %W(\!)
      end
    RUBY
  end

  it 'registers no offense for %w without interpolation' do
    expect_no_offenses('%w(cat dog)')
  end

  it 'registers no offense for %w with interpolation-like syntax' do
    expect_no_offenses('%w(c#{?a}t dog)')
  end

  it 'registers no offense for arrays with character constants' do
    expect_no_offenses('["one", ?\n]')
  end

  it 'does not register an offense for array of non-words' do
    expect_no_offenses('["one space", "two", "three"]')
  end

  it 'does not register an offense for array containing non-string' do
    expect_no_offenses('["one", "two", 3]')
  end

  it 'does not register an offense for array with one element' do
    expect_no_offenses('["three"]')
  end

  it 'does not register an offense for array with empty strings' do
    expect_no_offenses('["", "two", "three"]')
  end
end
