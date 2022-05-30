# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineMethodParameterLineBreaks, :config do
  context 'when one parameter on same line' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        def taz(abc)
        end
      RUBY
    end
  end

  context 'when there are no parameters' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        def taz
        end
      RUBY
    end
  end

  context 'when two parameters are on next line' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        def taz(
          foo, bar
        )
        end
      RUBY
    end
  end

  context 'when many parameter are on multiple lines, two on same line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        def taz(abc,
        foo, bar,
             ^^^ Each parameter in a multi-line method definition must start on a separate line.
        baz
        )
        end
      RUBY

      expect_correction(<<~RUBY)
        def taz(abc,
        foo,#{trailing_whitespace}
        bar,
        baz
        )
        end
      RUBY
    end
  end

  context 'when many parameters are on multiple lines, three on same line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        def taz(abc,
        foo, bar, barz,
                  ^^^^ Each parameter in a multi-line method definition must start on a separate line.
             ^^^ Each parameter in a multi-line method definition must start on a separate line.
        baz
        )
        end
      RUBY

      expect_correction(<<~RUBY)
        def taz(abc,
        foo,#{trailing_whitespace}
        bar,#{trailing_whitespace}
        barz,
        baz
        )
        end
      RUBY
    end
  end

  context 'when many parameters including hash are on multiple lines, three on same line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        def taz(abc,
        foo, bar, z: "barz",
                  ^^^^^^^^^ Each parameter in a multi-line method definition must start on a separate line.
             ^^^ Each parameter in a multi-line method definition must start on a separate line.
        x:
        )
        end
      RUBY

      expect_correction(<<~RUBY)
        def taz(abc,
        foo,#{trailing_whitespace}
        bar,#{trailing_whitespace}
        z: "barz",
        x:
        )
        end
      RUBY
    end
  end

  context 'when parameter\'s default value starts on same line but ends on different line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        def taz(abc, foo = {
                     ^^^^^^^ Each parameter in a multi-line method definition must start on a separate line.
          foo: "edf",
        })
        end
      RUBY

      expect_correction(<<~RUBY)
        def taz(abc,#{trailing_whitespace}
        foo = {
          foo: "edf",
        })
        end
      RUBY
    end
  end

  context 'when second parameter starts on same line as end of first' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        def taz(abc = {
          foo: "edf",
        }, bar:)
           ^^^^ Each parameter in a multi-line method definition must start on a separate line.
        end
      RUBY

      expect_correction(<<~RUBY)
        def taz(abc = {
          foo: "edf",
        },#{trailing_whitespace}
        bar:)
        end
      RUBY
    end
  end

  context 'when there are multiple parameters on the first line' do
    it 'registers an offense and corrects starting from the 2nd argument' do
      expect_offense(<<~RUBY)
        def do_something(foo, bar, baz,
                                   ^^^ Each parameter in a multi-line method definition must start on a separate line.
                              ^^^ Each parameter in a multi-line method definition must start on a separate line.
          quux)
        end
      RUBY

      expect_correction(<<~RUBY)
        def do_something(foo,#{trailing_whitespace}
        bar,#{trailing_whitespace}
        baz,
          quux)
        end
      RUBY
    end
  end

  context 'ignore last element' do
    let(:cop_config) { { 'AllowMultilineFinalElement' => true } }

    it 'ignores last parameter that value is a multiline hash' do
      expect_no_offenses(<<~RUBY)
        def foo(abc, foo, bar = {
          a: 1,
        })
        end
      RUBY
    end

    it 'registers and corrects arguments that are multiline hashes and not the last argument' do
      expect_offense(<<~RUBY)
        def foo(abc, foo, bar = {
                          ^^^^^^^ Each parameter in a multi-line method definition must start on a separate line.
                     ^^^ Each parameter in a multi-line method definition must start on a separate line.
          a: 1,
        }, buz)
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(abc,#{trailing_whitespace}
        foo,#{trailing_whitespace}
        bar = {
          a: 1,
        },#{trailing_whitespace}
        buz)
        end
      RUBY
    end

    it 'registers and corrects last argument that starts on a new line' do
      expect_offense(<<~RUBY)
        def foo(abc, foo, ghi,
                          ^^^ Each parameter in a multi-line method definition must start on a separate line.
                     ^^^ Each parameter in a multi-line method definition must start on a separate line.
        jkl)
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(abc,#{trailing_whitespace}
        foo,#{trailing_whitespace}
        ghi,
        jkl)
        end
      RUBY
    end
  end
end
