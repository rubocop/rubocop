# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyBlockParameter, :config do
  it 'registers an offense for an empty block parameter with do-end style' do
    expect_offense(<<~RUBY)
      a do ||
           ^^ Omit pipes for the empty block parameters.
      end
    RUBY

    expect_correction(<<~RUBY)
      a do
      end
    RUBY
  end

  it 'registers an offense for an empty block parameter with {} style' do
    expect_offense(<<~RUBY)
      a { || do_something }
          ^^ Omit pipes for the empty block parameters.
    RUBY

    expect_correction(<<~RUBY)
      a { do_something }
    RUBY
  end

  it 'registers an offense for an empty block parameter with super' do
    expect_offense(<<~RUBY)
      def foo
        super { || do_something }
                ^^ Omit pipes for the empty block parameters.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        super { do_something }
      end
    RUBY
  end

  it 'registers an offense for an empty block parameter with lambda' do
    expect_offense(<<~RUBY)
      lambda { || do_something }
               ^^ Omit pipes for the empty block parameters.
    RUBY

    expect_correction(<<~RUBY)
      lambda { do_something }
    RUBY
  end

  it 'accepts a block that is do-end style without parameter' do
    expect_no_offenses(<<~RUBY)
      a do
      end
    RUBY
  end

  it 'accepts a block that is {} style without parameter' do
    expect_no_offenses(<<~RUBY)
      a { }
    RUBY
  end

  it 'accepts a non-empty block parameter with do-end style' do
    expect_no_offenses(<<~RUBY)
      a do |x|
      end
    RUBY
  end

  it 'accepts a non-empty block parameter with {} style' do
    expect_no_offenses(<<~RUBY)
      a { |x| }
    RUBY
  end

  it 'accepts an empty block parameter with a lambda' do
    expect_no_offenses(<<~RUBY)
      -> () { do_something }
    RUBY
  end
end
