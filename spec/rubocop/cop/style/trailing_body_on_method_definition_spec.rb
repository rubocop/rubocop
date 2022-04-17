# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingBodyOnMethodDefinition, :config do
  let(:config) { RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 }) }

  it 'registers an offense when body trails after method definition' do
    expect_offense(<<~RUBY)
      def some_method; body
                       ^^^^ Place the first line of a multi-line method definition's body on its own line.
      end
      def extra_large; { size: 15 };
                       ^^^^^^^^^^^^ Place the first line of a multi-line method definition's body on its own line.
      end
      def seven_times(stuff) 7.times { do_this(stuff) }
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Place the first line of a multi-line method definition's body on its own line.
      end
    RUBY

    expect_correction(<<~RUBY)
      def some_method#{trailing_whitespace}
        body
      end
      def extra_large#{trailing_whitespace}
        { size: 15 };
      end
      def seven_times(stuff)#{trailing_whitespace}
        7.times { do_this(stuff) }
      end
    RUBY
  end

  it 'registers when body starts on def line & continues one more line' do
    expect_offense(<<~RUBY)
      def some_method; foo = {}
                       ^^^^^^^^ Place the first line of a multi-line method definition's body on its own line.
        more_body(foo)
      end
    RUBY

    expect_correction(<<~RUBY)
      def some_method#{trailing_whitespace}
        foo = {}
        more_body(foo)
      end
    RUBY
  end

  it 'registers when body starts on def line & continues many more lines' do
    expect_offense(<<~RUBY)
      def do_stuff(thing) process(thing)
                          ^^^^^^^^^^^^^^ Place the first line of a multi-line method definition's body on its own line.
        8.times { thing + 9 }
        even_more(thing)
      end
    RUBY

    expect_correction(<<~RUBY)
      def do_stuff(thing)#{trailing_whitespace}
        process(thing)
        8.times { thing + 9 }
        even_more(thing)
      end
    RUBY
  end

  it 'accepts a method with one line of body' do
    expect_no_offenses(<<~RUBY)
      def some_method
        body
      end
    RUBY
  end

  it 'accepts a method with multiple lines of body' do
    expect_no_offenses(<<~RUBY)
      def stuff_method
        stuff
        9.times { process(stuff) }
        more_stuff
      end
    RUBY
  end

  it 'does not register offense with trailing body on method end' do
    expect_no_offenses(<<~RUBY)
      def some_method
        body
      foo; end
    RUBY
  end

  context 'Ruby 3.0 or higher', :ruby30 do
    it 'does not register offense when endless method definition body is after newline in opening parenthesis' do
      expect_no_offenses(<<~RUBY)
        def some_method = (
          body
        )
      RUBY
    end
  end

  it 'autocorrects with comment after body' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method; body # stuff
      |                   ^^^^ Place the first line of a multi-line method definition's body on its own line.
      |  end
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  # stuff
      |  def some_method#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end
    RUBY
  end

  it 'autocorrects body with method definition with args not in parens' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method arg1, arg2; body
      |                              ^^^^ Place the first line of a multi-line method definition's body on its own line.
      |  end
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def some_method arg1, arg2#{trailing_whitespace}
      |    body
      |  end
    RUBY
  end

  it 'removes semicolon from method definition but not body when autocorrecting' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method; body; more_body;
      |                   ^^^^ Place the first line of a multi-line method definition's body on its own line.
      |  end
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def some_method#{trailing_whitespace}
      |    body; more_body;
      |  end
    RUBY
  end

  context 'when method is not on first line of processed_source' do
    it 'autocorrects offense' do
      expect_offense(<<-RUBY.strip_margin('|'))
        |
        |  def some_method; body
        |                   ^^^^ Place the first line of a multi-line method definition's body on its own line.
        |  end
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
        |
        |  def some_method#{trailing_whitespace}
        |    body
        |  end
      RUBY
    end
  end
end
