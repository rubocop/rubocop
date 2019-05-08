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
  end

  it 'register offense with trailing end on 3 line method' do
    expect_offense(<<~RUBY)
      def a
        b
      { foo: bar }; end
                    ^^^ Place the end statement of a multi-line method on its own line.
    RUBY
  end

  it 'register offense with trailing end on method with comment' do
    expect_offense(<<~RUBY)
      def c
        b = calculation
        [b] end # because b
            ^^^ Place the end statement of a multi-line method on its own line.
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
  end

  it 'register offense with trailing end inside class' do
    expect_offense(<<~RUBY)
      class Foo
        def some_method
        foo; end
             ^^^ Place the end statement of a multi-line method on its own line.
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

  it 'auto-corrects trailing end in 2 line method' do
    corrected = autocorrect_source(<<~RUBY)
      def some_method
        []; end
    RUBY
    expect(corrected).to eq(<<~RUBY)
      def some_method
        [] 
        end
    RUBY
  end

  it 'auto-corrects trailing end in 3 line method' do
    corrected = autocorrect_source(<<~RUBY)
      def do_this(x)
        y = x + 5
        y / 2; end
    RUBY
    expect(corrected).to eq(<<~RUBY)
      def do_this(x)
        y = x + 5
        y / 2 
        end
    RUBY
  end

  it 'auto-corrects trailing end with comment' do
    corrected = autocorrect_source(<<~RUBY)
      def f(x, y)
        process(x)
        process(y) end # comment
    RUBY
    expect(corrected).to eq(<<~RUBY)
      def f(x, y)
        process(x)
        process(y) 
        end # comment
    RUBY
  end

  it 'auto-corrects trailing end on method with block' do
    corrected = autocorrect_source(<<~RUBY)
      def d
        block do
          foo
        end end
    RUBY
    expect(corrected).to eq(<<~RUBY)
      def d
        block do
          foo
        end 
        end
    RUBY
  end

  it 'auto-corrects trailing end for larger example' do
    corrected = autocorrect_source(<<~RUBY)
      class Foo
        def some_method
          []; end
      end
    RUBY
    expect(corrected).to eq(<<~RUBY)
      class Foo
        def some_method
          [] 
        end
      end
    RUBY
  end
end
