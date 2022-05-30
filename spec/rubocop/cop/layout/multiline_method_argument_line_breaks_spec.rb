# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineMethodArgumentLineBreaks, :config do
  context 'when one argument on same line' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        taz("abc")
      RUBY
    end
  end

  context 'when bracket hash assignment on multiple lines' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        class Thing
          def call
            bar['foo'] = ::Time.zone.at(
                           huh['foo'],
                         )
          end
        end
      RUBY
    end
  end

  context 'when bracket hash assignment key on multiple lines' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        a['b',
            'c', 'd'] = e
      RUBY
    end
  end

  context 'when two arguments are on next line' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        taz(
          "abc", "foo"
        )
      RUBY
    end
  end

  context 'when many arguments are on multiple lines, two on same line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        taz("abc",
        "foo", "bar",
               ^^^^^ Each argument in a multi-line method call must start on a separate line.
        "baz"
        )
      RUBY

      expect_correction(<<~RUBY)
        taz("abc",
        "foo",\s
        "bar",
        "baz"
        )
      RUBY
    end
  end

  context 'when many arguments are on multiple lines, three on same line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        taz("abc",
        "foo", "bar", "barz",
                      ^^^^^^ Each argument in a multi-line method call must start on a separate line.
               ^^^^^ Each argument in a multi-line method call must start on a separate line.
        "baz"
        )
      RUBY

      expect_correction(<<~RUBY)
        taz("abc",
        "foo",\s
        "bar",\s
        "barz",
        "baz"
        )
      RUBY
    end
  end

  context 'when many arguments including hash are on multiple lines, three on same line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        taz("abc",
        "foo", "bar", z: "barz",
                      ^^^^^^^^^ Each argument in a multi-line method call must start on a separate line.
               ^^^^^ Each argument in a multi-line method call must start on a separate line.
        x: "baz"
        )
      RUBY

      expect_correction(<<~RUBY)
        taz("abc",
        "foo",\s
        "bar",\s
        z: "barz",
        x: "baz"
        )
      RUBY
    end
  end

  context 'when argument starts on same line but ends on different line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        taz("abc", {
                   ^ Each argument in a multi-line method call must start on a separate line.
          foo: "edf",
        })
      RUBY

      expect_correction(<<~RUBY)
        taz("abc",\s
        {
          foo: "edf",
        })
      RUBY
    end
  end

  context 'when second argument starts on same line as end of first' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        taz({
          foo: "edf",
        }, "abc")
           ^^^^^ Each argument in a multi-line method call must start on a separate line.
      RUBY

      expect_correction(<<~RUBY)
        taz({
          foo: "edf",
        },\s
        "abc")
      RUBY
    end
  end

  context 'when there are multiple arguments on the first line' do
    it 'registers an offense and corrects starting from the 2nd argument' do
      expect_offense(<<~RUBY)
        do_something(foo, bar, baz,
                               ^^^ Each argument in a multi-line method call must start on a separate line.
                          ^^^ Each argument in a multi-line method call must start on a separate line.
          quux)
      RUBY

      expect_correction(<<~RUBY)
        do_something(foo,#{trailing_whitespace}
        bar,#{trailing_whitespace}
        baz,
          quux)
      RUBY
    end
  end

  context 'ignore last element' do
    let(:cop_config) { { 'AllowMultilineFinalElement' => true } }

    it 'ignores last argument that is a multiline hash' do
      expect_no_offenses(<<~RUBY)
        foo(1, 2, 3, {
          a: 1,
        })
      RUBY
    end

    it 'registers and corrects arguments that are multiline hashes and not the last argument' do
      expect_offense(<<~RUBY)
        foo(1, 2, 3, {
                     ^ Each argument in a multi-line method call must start on a separate line.
                  ^ Each argument in a multi-line method call must start on a separate line.
               ^ Each argument in a multi-line method call must start on a separate line.
          a: 1,
        }, 4)
      RUBY

      expect_correction(<<~RUBY)
        foo(1,#{trailing_whitespace}
        2,#{trailing_whitespace}
        3,#{trailing_whitespace}
        {
          a: 1,
        },#{trailing_whitespace}
        4)
      RUBY
    end

    it 'registers and corrects last argument that starts on a new line' do
      expect_offense(<<~RUBY)
        foo(1, 2, 3,
                  ^ Each argument in a multi-line method call must start on a separate line.
               ^ Each argument in a multi-line method call must start on a separate line.
        4)
      RUBY

      expect_correction(<<~RUBY)
        foo(1,#{trailing_whitespace}
        2,#{trailing_whitespace}
        3,
        4)
      RUBY
    end
  end
end
