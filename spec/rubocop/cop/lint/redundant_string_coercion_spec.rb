# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantStringCoercion, :config do
  it 'registers an offense and corrects `to_s` in interpolation' do
    expect_offense(<<~'RUBY')
      "this is the #{result.to_s}"
                            ^^^^ Redundant use of `Object#to_s` in interpolation.
      /regexp #{result.to_s}/
                       ^^^^ Redundant use of `Object#to_s` in interpolation.
      :"symbol #{result.to_s}"
                        ^^^^ Redundant use of `Object#to_s` in interpolation.
      `backticks #{result.to_s}`
                          ^^^^ Redundant use of `Object#to_s` in interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "this is the #{result}"
      /regexp #{result}/
      :"symbol #{result}"
      `backticks #{result}`
    RUBY
  end

  it 'registers an offense and corrects `to_s` in an interpolation with several expressions' do
    expect_offense(<<~'RUBY')
      "this is the #{top; result.to_s}"
                                 ^^^^ Redundant use of `Object#to_s` in interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "this is the #{top; result}"
    RUBY
  end

  it 'accepts #to_s with arguments in an interpolation' do
    expect_no_offenses('"this is a #{result.to_s(8)}"')
  end

  it 'accepts interpolation without #to_s' do
    expect_no_offenses('"this is the #{result}"')
  end

  it 'registers an offense and corrects an implicit receiver' do
    expect_offense(<<~'RUBY')
      "#{to_s}"
         ^^^^ Use `self` instead of `Object#to_s` in interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{self}"
    RUBY
  end

  it 'does not explode on empty interpolation' do
    expect_no_offenses('"this is #{} silly"')
  end

  it 'registers an offense and corrects `to_s` in `print` arguments' do
    expect_offense(<<~RUBY)
      print first.to_s, second.to_s
                  ^^^^ Redundant use of `Object#to_s` in `print`.
                               ^^^^ Redundant use of `Object#to_s` in `print`.
    RUBY

    expect_correction(<<~RUBY)
      print first, second
    RUBY
  end

  it 'registers an offense and corrects `to_s` in `print` arguments without receiver' do
    expect_offense(<<~RUBY)
      print to_s, to_s
            ^^^^ Use `self` instead of `Object#to_s` in `print`.
                  ^^^^ Use `self` instead of `Object#to_s` in `print`.
    RUBY

    expect_correction(<<~RUBY)
      print self, self
    RUBY
  end

  it 'registers an offense and corrects `to_s` in `puts` arguments' do
    expect_offense(<<~RUBY)
      puts first.to_s, second.to_s
                 ^^^^ Redundant use of `Object#to_s` in `puts`.
                              ^^^^ Redundant use of `Object#to_s` in `puts`.
    RUBY

    expect_correction(<<~RUBY)
      puts first, second
    RUBY
  end

  it 'registers an offense and corrects `to_s` in `warn` arguments' do
    expect_offense(<<~RUBY)
      warn first.to_s, second.to_s
                 ^^^^ Redundant use of `Object#to_s` in `warn`.
                              ^^^^ Redundant use of `Object#to_s` in `warn`.
    RUBY

    expect_correction(<<~RUBY)
      warn first, second
    RUBY
  end

  it 'registers an offense and corrects `to_s` in `puts` arguments without receiver' do
    expect_offense(<<~RUBY)
      puts to_s, to_s
           ^^^^ Use `self` instead of `Object#to_s` in `puts`.
                 ^^^^ Use `self` instead of `Object#to_s` in `puts`.
    RUBY

    expect_correction(<<~RUBY)
      puts self, self
    RUBY
  end

  it 'does not register an offense when not using `to_s` in `print` arguments' do
    expect_no_offenses(<<~RUBY)
      print obj.do_something
    RUBY
  end

  it 'does not register an offense when not using `to_s` in `puts` arguments' do
    expect_no_offenses(<<~RUBY)
      puts obj.do_something
    RUBY
  end

  it 'does not register an offense when using `to_s` in `p` arguments' do
    expect_no_offenses(<<~RUBY)
      p first.to_s, second.to_s
    RUBY
  end

  it 'does not register an offense when using `to_s` in `print` arguments with receiver' do
    expect_no_offenses(<<~RUBY)
      obj.print first.to_s, second.to_s
    RUBY
  end

  it 'does not register an offense when using `to_s(argument)` in `puts` argument' do
    expect_no_offenses(<<~RUBY)
      puts obj.to_s(argument)
    RUBY
  end
end
