# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingBodyOnClass do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 })
  end

  it 'registers an offense when body trails after class definition' do
    expect_offense(<<~RUBY)
      class Foo; body
                 ^^^^ Place the first line of class body on its own line.
      end
      class Bar; def bar; end
                 ^^^^^^^^^^^^ Place the first line of class body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo#{trailing_whitespace}
        body
      end
      class Bar#{trailing_whitespace}
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

  it 'auto-corrects with comment after body' do
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
    it 'auto-correct offense' do
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
