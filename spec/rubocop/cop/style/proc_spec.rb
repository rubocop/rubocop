# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Proc, :config do
  it 'registers an offense for a Proc.new call' do
    expect_offense(<<~RUBY)
      f = Proc.new { |x| puts x }
          ^^^^^^^^ Use `proc` instead of `Proc.new`.
    RUBY

    expect_correction(<<~RUBY)
      f = proc { |x| puts x }
    RUBY
  end

  it 'registers an offense for ::Proc.new' do
    expect_offense(<<~RUBY)
      f = ::Proc.new { |x| puts x }
          ^^^^^^^^^^ Use `proc` instead of `Proc.new`.
    RUBY

    expect_correction(<<~RUBY)
      f = proc { |x| puts x }
    RUBY
  end

  it 'accepts the Proc.new call without block' do
    expect_no_offenses('p = Proc.new')
  end

  it 'accepts the ::Proc.new call without block' do
    expect_no_offenses('p = ::Proc.new')
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers an offense for a Proc.new call' do
      expect_offense(<<~RUBY)
        f = Proc.new { puts _1 }
            ^^^^^^^^ Use `proc` instead of `Proc.new`.
      RUBY

      expect_correction(<<~RUBY)
        f = proc { puts _1 }
      RUBY
    end
  end
end
