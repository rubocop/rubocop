# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideParens, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense for spaces inside parens' do
      expect_offense(<<~RUBY)
        f( 3)
          ^ Space inside parentheses detected.
        g = (a + 3 )
                  ^ Space inside parentheses detected.
      RUBY

      expect_correction(<<~RUBY)
        f(3)
        g = (a + 3)
      RUBY
    end

    it 'accepts parentheses in block parameter list' do
      expect_no_offenses(<<~RUBY)
        list.inject(Tms.new) { |sum, (label, item)|
        }
      RUBY
    end

    it 'accepts parentheses with no spaces' do
      expect_no_offenses('split("\\n")')
    end

    it 'accepts parentheses with line break' do
      expect_no_offenses(<<~RUBY)
        f(
          1)
      RUBY
    end

    it 'accepts parentheses with comment and line break' do
      expect_no_offenses(<<~RUBY)
        f( # Comment
          1)
      RUBY
    end

    it 'accepts no spaces inside parens following a keyword argument' do
      expect_no_offenses(<<~RUBY)
        def a(foo:); end
      RUBY
    end

    it 'registers an offense for spaces inside parens ' \
      'following a keyword argument with a value' do
      expect_offense(<<~RUBY)
        def a(foo: nil ); end
                      ^ Space inside parentheses detected.
        a(foo: 7 )
                ^ Space inside parentheses detected.
      RUBY

      expect_correction(<<~RUBY)
        def a(foo: nil); end
        a(foo: 7)
      RUBY
    end
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it 'registers an offense for no spaces inside parens' do
      expect_offense(<<~RUBY)
        f( 3)
            ^ No space inside parentheses detected.
        g = (a + 3 )
             ^ No space inside parentheses detected.
        split("\\n")
              ^ No space inside parentheses detected.
                  ^ No space inside parentheses detected.
      RUBY

      expect_correction(<<~RUBY)
        f( 3 )
        g = ( a + 3 )
        split( "\\n" )
      RUBY
    end

    it 'registers an offense in block parameter list with no spaces' do
      expect_offense(<<~RUBY)
        list.inject( Tms.new ) { |sum, (label, item)|
                                        ^ No space inside parentheses detected.
                                                   ^ No space inside parentheses detected.
        }
      RUBY

      expect_correction(<<~RUBY)
        list.inject( Tms.new ) { |sum, ( label, item )|
        }
      RUBY
    end

    it 'accepts parentheses with spaces' do
      expect_no_offenses(<<~RUBY)
        f( 3 )
        g = ( a + 3 )
        split( "\\n" )
      RUBY
    end

    it 'accepts parentheses with line break' do
      expect_no_offenses(<<~RUBY)
        f(
          1 )
      RUBY
    end

    it 'accepts parentheses with comment and line break' do
      expect_no_offenses(<<~RUBY)
        f( # Comment
          1 )
      RUBY
    end

    it 'registers an offense for no spaces inside parens ' \
      'following a keyword argument' do
      expect_offense(<<~RUBY)
        def a(foo:); end
              ^ No space inside parentheses detected.
                  ^ No space inside parentheses detected.
        a(foo: 7)
                ^ No space inside parentheses detected.
          ^ No space inside parentheses detected.
      RUBY

      expect_correction(<<~RUBY)
        def a( foo: ); end
        a( foo: 7 )
      RUBY
    end

    it 'registers an offense for spaces inside parens ' \
      'following a keyword argument with a value' do
      expect_offense(<<~RUBY)
        def a(foo: nil ); end
              ^ No space inside parentheses detected.
        a(foo: 7 )
          ^ No space inside parentheses detected.
      RUBY

      expect_correction(<<~RUBY)
        def a( foo: nil ); end
        a( foo: 7 )
      RUBY
    end
  end

  context 'when EnforcedStyle is space_after_colon' do
    let(:cop_config) { { 'EnforcedStyle' => 'space_after_colon' } }

    it 'registers an offense for spaces inside parens' do
      expect_offense(<<~RUBY)
        f( 3)
          ^ Space inside parentheses detected.
        g = (a + 3 )
                  ^ Space inside parentheses detected.
      RUBY

      expect_correction(<<~RUBY)
        f(3)
        g = (a + 3)
      RUBY
    end

    it 'accepts parentheses in block parameter list' do
      expect_no_offenses(<<~RUBY)
        list.inject(Tms.new) { |sum, (label, item)|
        }
      RUBY
    end

    it 'accepts parentheses with no spaces' do
      expect_no_offenses('split("\\n")')
    end

    it 'accepts parentheses with line break' do
      expect_no_offenses(<<~RUBY)
        f(
          1)
      RUBY
    end

    it 'accepts parentheses with comment and line break' do
      expect_no_offenses(<<~RUBY)
        f( # Comment
          1)
      RUBY
    end

    it 'accepts spaces inside parens follwing a keyword argument' do
      expect_no_offenses('def a(foo: ); end')
    end

    it 'registers an offense for spaces inside parens ' \
      'following a keyword argument with a value' do
      expect_offense(<<~RUBY)
        def a(foo: nil ); end
                      ^ Space inside parentheses detected.
        a(foo: 7 )
                ^ Space inside parentheses detected.
      RUBY

      expect_correction(<<~RUBY)
        def a(foo: nil); end
        a(foo: 7)
      RUBY
    end

    it 'registers an offense for no spaces inside parens ' \
      'following a keyword argument' do
      expect_offense(<<~RUBY)
        def a(foo:); end
                  ^ No space after colon inside parentheses.
      RUBY

      expect_correction(<<~RUBY)
        def a(foo: ); end
      RUBY
    end
  end
end
