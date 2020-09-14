# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingMethodEndStatement do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 })
  end

  it 'register offense with trailing end on 2 line method' do
    expect_offense(<<~RUBY)
      def some_method
      foo; end
           ^^^ Place the end statement of a multi-line method on its own line.
    RUBY

    expect_correction(<<~RUBY)
      def some_method
      foo;#{trailing_whitespace}
      end
    RUBY
  end

  it 'register offense with trailing end on 3 line method' do
    expect_offense(<<~RUBY)
      def a
        b
      { foo: bar }; end
                    ^^^ Place the end statement of a multi-line method on its own line.
    RUBY

    expect_correction(<<~RUBY)
      def a
        b
      { foo: bar };#{trailing_whitespace}
      end
    RUBY
  end

  it 'register offense with trailing end on method with comment' do
    expect_offense(<<~RUBY)
      def c
        b = calculation
        [b] end # because b
            ^^^ Place the end statement of a multi-line method on its own line.
    RUBY

    expect_correction(<<~RUBY)
      def c
        b = calculation
        [b]#{trailing_whitespace}
      end # because b
    RUBY
  end

  it 'register offense with trailing end on method with block' do
    expect_offense(<<~RUBY)
      def d
        block do
          foo
        end end
            ^^^ Place the end statement of a multi-line method on its own line.
    RUBY

    expect_correction(<<~RUBY)
      def d
        block do
          foo
        end#{trailing_whitespace}
      end
    RUBY
  end

  it 'register offense with trailing end inside class' do
    expect_offense(<<~RUBY)
      class Foo
        def some_method
        foo; end
             ^^^ Place the end statement of a multi-line method on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        def some_method
        foo;#{trailing_whitespace}
        end
      end
    RUBY
  end

  it 'does not register on single line no op' do
    expect_no_offenses(<<~RUBY)
      def no_op; end
    RUBY
  end

  it 'does not register on single line method' do
    expect_no_offenses(<<~RUBY)
      def something; do_stuff; end
    RUBY
  end

  it 'auto-corrects all trailing ends for larger example' do
    expect_offense(<<~RUBY)
      class Foo
        def some_method
          [] end
             ^^^ Place the end statement of a multi-line method on its own line.
        def another_method
          {} end
             ^^^ Place the end statement of a multi-line method on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        def some_method
          []#{trailing_whitespace}
        end
        def another_method
          {}#{trailing_whitespace}
        end
      end
    RUBY
  end
end
