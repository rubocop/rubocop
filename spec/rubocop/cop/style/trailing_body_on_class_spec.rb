# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingBodyOnClass, :config do
  let(:config) { RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 }) }

  it 'registers an offense when body trails after class definition' do
    expect_offense(<<~RUBY)
      class Foo; body
                 ^^^^ Place the first line of class body on its own line.
      end
      class Foo body
                ^^^^ Place the first line of class body on its own line.
      end
      class Bar; def bar; end
                 ^^^^^^^^^^^^ Place the first line of class body on its own line.
      end
      class Bar def bar; end
                ^^^^^^^^^^^^ Place the first line of class body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo#{trailing_whitespace}
        body
      end
      class Foo#{trailing_whitespace}
        body
      end
      class Bar#{trailing_whitespace}
        def bar; end
      end
      class Bar#{trailing_whitespace}
        def bar; end
      end
    RUBY
  end

  it 'registers an offense when body trails after singleton class definition' do
    expect_offense(<<~RUBY)
      class << self; body
                     ^^^^ Place the first line of class body on its own line.
      end
      class << self; def bar; end
                     ^^^^^^^^^^^^ Place the first line of class body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      class << self#{trailing_whitespace}
        body
      end
      class << self#{trailing_whitespace}
        def bar; end
      end
    RUBY
  end

  it 'registers offense with multi-line class' do
    expect_offense(<<~RUBY)
      class Foo; body
                 ^^^^ Place the first line of class body on its own line.
        def bar
          qux
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo#{trailing_whitespace}
        body
        def bar
          qux
        end
      end
    RUBY
  end

  it 'accepts regular class' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def no_op; end
      end
    RUBY
  end

  it 'accepts class inheritance' do
    expect_no_offenses(<<~RUBY)
      class Foo < Bar
      end
    RUBY
  end

  it 'autocorrects with comment after body' do
    expect_offense(<<~RUBY)
      class BarQux; foo # comment
                    ^^^ Place the first line of class body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      class BarQux#{trailing_whitespace}
        foo#{trailing_whitespace}
      end
    RUBY
  end

  context 'when class is not on first line of processed_source' do
    it 'autocorrect offense' do
      expect_offense(<<-RUBY.strip_margin('|'))
        |
        |  class Foo; body#{trailing_whitespace}
        |             ^^^^ Place the first line of class body on its own line.
        |  end
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
        |
        |  class Foo#{trailing_whitespace}
        |    body#{trailing_whitespace}
        |  end
      RUBY
    end
  end
end
