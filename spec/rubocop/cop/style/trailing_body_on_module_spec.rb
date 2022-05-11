# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingBodyOnModule, :config do
  let(:config) { RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 }) }

  it 'registers an offense when body trails after module definition' do
    expect_offense(<<~RUBY)
      module Foo body
                 ^^^^ Place the first line of module body on its own line.
      end
      module Bar extend self
                 ^^^^^^^^^^^ Place the first line of module body on its own line.
      end
      module Bar; def bar; end
                  ^^^^^^^^^^^^ Place the first line of module body on its own line.
      end
      module Bar def bar; end
                 ^^^^^^^^^^^^ Place the first line of module body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      module Foo#{trailing_whitespace}
        body
      end
      module Bar#{trailing_whitespace}
        extend self
      end
      module Bar#{trailing_whitespace}
        def bar; end
      end
      module Bar#{trailing_whitespace}
        def bar; end
      end
    RUBY
  end

  it 'registers offense with multi-line module' do
    expect_offense(<<~RUBY)
      module Foo body
                 ^^^^ Place the first line of module body on its own line.
        def bar
          qux
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module Foo#{trailing_whitespace}
        body
        def bar
          qux
        end
      end
    RUBY
  end

  it 'registers offense when module definition uses semicolon' do
    expect_offense(<<~RUBY)
      module Foo; do_stuff
                  ^^^^^^^^ Place the first line of module body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      module Foo#{trailing_whitespace}
        do_stuff
      end
    RUBY
  end

  it 'accepts regular module' do
    expect_no_offenses(<<~RUBY)
      module Foo
        def no_op; end
      end
    RUBY
  end

  it 'autocorrects with comment after body' do
    expect_offense(<<~RUBY)
      module BarQux; foo # comment
                     ^^^ Place the first line of module body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      module BarQux#{trailing_whitespace}
        foo#{trailing_whitespace}
      end
    RUBY
  end

  it 'autocorrects when there are multiple semicolons' do
    expect_offense(<<~RUBY)
      module Bar; def bar; end
                  ^^^^^^^^^^^^ Place the first line of module body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      module Bar#{trailing_whitespace}
        def bar; end
      end
    RUBY
  end

  context 'when module is not on first line of processed_source' do
    it 'autocorrects offense' do
      expect_offense(<<~RUBY)

        module Foo; body#{trailing_whitespace}
                    ^^^^ Place the first line of module body on its own line.
        end
      RUBY

      expect_correction(<<~RUBY)

        module Foo#{trailing_whitespace}
          body#{trailing_whitespace}
        end
      RUBY
    end
  end
end
