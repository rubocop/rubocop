# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NestedDoubleQuotesInInterpolation, :config do
  context 'when outer string uses double quotes' do
    it 'registers an offense and corrects simple nested double quotes' do
      expect_offense(<<~'RUBY')
        "#{"foobar"}"
           ^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{'foobar'}"
      RUBY
    end

    it 'registers an offense and corrects nested double quotes with spaces' do
      expect_offense(<<~'RUBY')
        "Hello #{ "world" }"
                  ^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Hello #{ 'world' }"
      RUBY
    end

    it 'registers an offense and corrects nested double quotes in a method call argument' do
      expect_offense(<<~'RUBY')
        "Result: #{ calculate("value") }"
                              ^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Result: #{ calculate('value') }"
      RUBY
    end

    it 'registers an offense and corrects nested double quotes in a hash value' do
      expect_offense(<<~'RUBY')
        "User: #{ { name: "John" } }"
                          ^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "User: #{ { name: 'John' } }"
      RUBY
    end

    it 'registers an offense and corrects nested double quotes in a begin block' do
      expect_offense(<<~'RUBY')
        "Wrapped: #{ begin "value" end }"
                           ^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Wrapped: #{ begin 'value' end }"
      RUBY
    end

    it 'registers offenses and corrects nested double quotes in a ternary' do
      expect_offense(<<~RUBY, prefix: '"Tests: #{ success ? ', pass: '"PASS"', mid: ' : ', fail: '"FAIL"', suffix: ' }"') # rubocop:disable Layout/LineLength
        %{prefix}%{pass}%{mid}%{fail}%{suffix}
        _{prefix}^{pass} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
        _{prefix}_{pass}_{mid}^{fail} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Tests: #{ success ? 'PASS' : 'FAIL' }"
      RUBY
    end

    it 'registers offenses and corrects nested double quotes in a rescue' do
      expect_offense(<<~RUBY, prefix: '"Wrapped: #{ begin ', value: '"value"', mid: ' rescue ', fallback: '"fallback"', suffix: ' end }"') # rubocop:disable Layout/LineLength
        %{prefix}%{value}%{mid}%{fallback}%{suffix}
        _{prefix}^{value} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
        _{prefix}_{value}_{mid}^{fallback} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Wrapped: #{ begin 'value' rescue 'fallback' end }"
      RUBY
    end

    it 'registers an offense and corrects nested double quotes in an ensure' do
      expect_offense(<<~RUBY, prefix: '"Wrapped: #{ begin ', value: '"value"', suffix: ' ensure cleanup end }"') # rubocop:disable Layout/LineLength
        %{prefix}%{value}%{suffix}
        _{prefix}^{value} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Wrapped: #{ begin 'value' ensure cleanup end }"
      RUBY
    end

    it 'registers offenses and corrects nested double quotes in a rescue+ensure' do
      expect_offense(<<~RUBY, prefix: '"Wrapped: #{ begin ', value: '"value"', mid: ' rescue ', fallback: '"fallback"', suffix: ' ensure cleanup end }"') # rubocop:disable Layout/LineLength
        %{prefix}%{value}%{mid}%{fallback}%{suffix}
        _{prefix}^{value} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
        _{prefix}_{value}_{mid}^{fallback} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Wrapped: #{ begin 'value' rescue 'fallback' ensure cleanup end }"
      RUBY
    end

    it 'registers offenses and corrects multiple nesting levels' do
      expect_offense(<<~'RUBY')
        "Level 1: #{ "Level 2: #{ "Level 3" }" }"
                     ^^^^^^^^^^^^^^^^^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
                                  ^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Level 1: #{ %Q(Level 2: #{ 'Level 3' }) }"
      RUBY
    end

    it 'registers an offense for double quotes inside a multiple assignment within interpolation' do
      expect_offense(<<~'RUBY')
        "result: #{a, b = "x", "y"}"
                          ^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
                               ^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "result: #{a, b = 'x', 'y'}"
      RUBY
    end

    it 'registers an offense for double quotes inside an array literal within interpolation' do
      expect_offense(<<~'RUBY')
        "items: #{["foo", "bar"].join(", ")}"
                   ^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
                          ^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
                                      ^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "items: #{['foo', 'bar'].join(', ')}"
      RUBY
    end

    it 'registers an offense and corrects inside parentheses within interpolation' do
      expect_offense(<<~'RUBY')
        "#{ ("string") }"
             ^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{ ('string') }"
      RUBY
    end

    it 'registers offenses and corrects concatenated strings inside interpolation' do
      expect_offense(<<~'RUBY')
        "Name: #{ "John" + " " + "Doe" }"
                  ^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
                           ^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
                                 ^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Name: #{ 'John' + ' ' + 'Doe' }"
      RUBY
    end

    it 'registers an offense and corrects with a trailing comment inside interpolation' do
      expect_offense(<<~'RUBY')
        "#{ "foo" # comment
            ^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
        }"
      RUBY

      expect_correction(<<~'RUBY')
        "#{ 'foo' # comment
        }"
      RUBY
    end

    it 'registers an offense and corrects inside a lambda within interpolation' do
      expect_offense(<<~'RUBY')
        "Result: #{ -> { "value" }.call }"
                         ^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Result: #{ -> { 'value' }.call }"
      RUBY
    end

    it 'does not register an offense when single quotes are used inside interpolation' do
      expect_no_offenses(<<~'RUBY')
        "Hello #{ 'world' }"
      RUBY
    end

    it 'does not register an offense for a double-quoted string without interpolation' do
      expect_no_offenses('"\"foobar\""')
    end

    it 'does not register an offense for a single-quoted string with double quotes' do
      expect_no_offenses(<<~RUBY)
        'a "quoted" word'
      RUBY
    end

    it 'does not register an offense for escaped interpolation with double quotes' do
      expect_no_offenses(<<~'RUBY')
        "This is \#{ \"not interpolation\" }"
      RUBY
    end

    it 'does not register an offense for a plain string in a multi-statement context' do
      expect_no_offenses(<<~RUBY)
        x = 1
        "hello"
      RUBY
    end
  end

  context 'when the inner string cannot use single quotes' do
    it 'registers an offense and corrects with %Q when the inner string contains interpolation' do
      expect_offense(<<~'RUBY')
        "#{"#{foo}"}"
           ^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{%Q(#{foo})}"
      RUBY
    end

    it 'registers an offense and corrects with %Q when the inner string contains single quotes' do
      expect_offense(<<~'RUBY')
        "#{"foo'bar"}"
           ^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{%Q(foo'bar)}"
      RUBY
    end

    it 'registers an offense and corrects with %Q when the inner string contains a newline escape' do
      expect_offense(<<~'RUBY')
        "#{"\n"}"
           ^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{%Q(\n)}"
      RUBY
    end

    it 'registers an offense and corrects with %Q when the inner string contains an escaped backslash' do
      expect_offense(<<~'RUBY')
        "Path: #{ "C:\\Windows" }"
                  ^^^^^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Path: #{ %Q(C:\\Windows) }"
      RUBY
    end

    it 'registers an offense and corrects with %Q when the inner string in a method call contains single quotes' do
      expect_offense(<<~'RUBY')
        "Status: #{ "It's ok" }"
                    ^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Status: #{ %Q(It's ok) }"
      RUBY
    end
  end

  context 'when outer string is an interpolated symbol' do
    it 'registers an offense and corrects nested double quotes' do
      expect_offense(<<~'RUBY')
        :"#{"A"}"
            ^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        :"#{'A'}"
      RUBY
    end

    it 'registers an offense and corrects nested double quotes with spaces' do
      expect_offense(<<~'RUBY')
        :"symbol-#{ "name" }"
                    ^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        :"symbol-#{ 'name' }"
      RUBY
    end

    it 'registers an offense and corrects dynamic symbol keys in a hash' do
      expect_offense(<<~'RUBY')
        { "#{"key"}": val }
             ^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        { "#{'key'}": val }
      RUBY
    end
  end

  context 'when outer string is a backtick command literal' do
    it 'does not register an offense for backtick strings' do
      expect_no_offenses(<<~'RUBY')
        `cmd #{"arg"}`
      RUBY
    end
  end

  context 'when outer string is a heredoc' do
    it 'does not register an offense for interpolation inside a heredoc' do
      expect_no_offenses(<<~'RUBY')
        <<-EOS
        #{"foobar"}
        EOS
      RUBY
    end

    it 'does not register an offense for interpolation inside a squiggly heredoc' do
      expect_no_offenses(<<~'RUBY')
        <<~HTML
          <div class="#{ "active" }"></div>
        HTML
      RUBY
    end

    it 'does not register an offense for a heredoc with double-quoted identifier' do
      expect_no_offenses(<<~'RUBY')
        <<~"EOS"
          #{"foobar"}
        EOS
      RUBY
    end

    it 'does not register an offense for interpolation with a conditional inside a heredoc' do
      expect_no_offenses(<<~'RUBY')
        <<~HTML
          <div class="#{ "active" if active? }"></div>
        HTML
      RUBY
    end

    it 'does not register an offense for a heredoc inside interpolation' do
      expect_no_offenses(<<~'RUBY')
        "Message: #{ <<~TEXT
            hello
          TEXT
        }"
      RUBY
    end
  end

  context 'when outer string is a percent literal' do
    it 'does not register an offense for %{...}' do
      expect_no_offenses(<<~'RUBY')
        %{
        #{"foobar"}
        }
      RUBY
    end

    it 'does not register an offense for %Q(...)' do
      expect_no_offenses(<<~'RUBY')
        %Q(Text with #{ "interpolation" })
      RUBY
    end

    it 'does not register an offense for %Q[...]' do
      expect_no_offenses(<<~'RUBY')
        %Q[Text with #{ "interpolation" }]
      RUBY
    end

    it 'does not register an offense for %Q{...} with join' do
      expect_no_offenses(<<~'RUBY')
        %Q('#{elements.join("', '")}')
      RUBY
    end

    it 'registers an offense and corrects for %Q"..."' do
      expect_offense(<<~'RUBY')
        %Q"Text with #{ "interpolation" }"
                        ^^^^^^^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        %Q"Text with #{ 'interpolation' }"
      RUBY
    end
  end

  context 'when outer string is a %W array literal' do
    it 'does not register an offense for %W(...)' do
      expect_no_offenses(<<~'RUBY')
        %W(foo#{ "bar" })
      RUBY
    end

    it 'does not register an offense for %W[...]' do
      expect_no_offenses(<<~'RUBY')
        %W[foo#{ "bar" }]
      RUBY
    end

    it 'does not register an offense for %W{...}' do
      expect_no_offenses(<<~'RUBY')
        %W{foo#{ "bar" }}
      RUBY
    end

    it 'registers an offense and corrects for %W"..."' do
      expect_offense(<<~RUBY, prefix: '%W"foo #{ ', inner: '"bar"', suffix: ' }"')
        %{prefix}%{inner}%{suffix}
        _{prefix}^{inner} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        %W"foo #{ 'bar' }"
      RUBY
    end
  end

  context 'when outer string is a %I symbol array literal' do
    it 'does not register an offense for %I(...)' do
      expect_no_offenses(<<~'RUBY')
        %I(foo#{ "bar" })
      RUBY
    end

    it 'does not register an offense for %I[...]' do
      expect_no_offenses(<<~'RUBY')
        %I[foo#{ "bar" }]
      RUBY
    end

    it 'does not register an offense for %I{...}' do
      expect_no_offenses(<<~'RUBY')
        %I{foo#{ "bar" }}
      RUBY
    end

    it 'registers an offense and corrects for %I"..."' do
      expect_offense(<<~RUBY, prefix: '%I"foo #{ ', inner: '"bar"', suffix: ' }"')
        %{prefix}%{inner}%{suffix}
        _{prefix}^{inner} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        %I"foo #{ 'bar' }"
      RUBY
    end
  end

  context 'when outer string is a %x command literal' do
    it 'does not register an offense for %x(...)' do
      expect_no_offenses(<<~'RUBY')
        %x(cmd #{ "arg" })
      RUBY
    end

    it 'registers an offense and corrects for %x"..."' do
      expect_offense(<<~'RUBY')
        %x"cmd #{ "arg" }"
                  ^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        %x"cmd #{ 'arg' }"
      RUBY
    end
  end

  context 'when outer string is a %r regexp literal' do
    it 'does not register an offense for /.../' do
      expect_no_offenses(<<~'RUBY')
        /pattern-#{ "modifier" }/
      RUBY
    end

    it 'does not register an offense for %r(...)' do
      expect_no_offenses(<<~'RUBY')
        %r(foo#{"A"}bar)
      RUBY
    end

    it 'registers an offense and corrects for %r"..."' do
      expect_offense(<<~'RUBY', inner: '"A"')
        %r"foo#{%{inner}}bar"
                ^{inner} Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        %r"foo#{'A'}bar"
      RUBY
    end

    it 'registers an offense and corrects for %r"..." with spaces' do
      expect_offense(<<~'RUBY')
        %r"pattern-#{ "modifier" }"
                      ^^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        %r"pattern-#{ 'modifier' }"
      RUBY
    end
  end

  context 'when EnforcedStyle is percent_q' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_q' } }

    it 'corrects dstr with %Q(...)' do
      expect_offense(<<~'RUBY')
        "#{success? ? "yes #{name}" : "no"}"
                      ^^^^^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
                                      ^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{success? ? %Q(yes #{name}) : 'no'}"
      RUBY
    end

    it 'corrects dstr containing balanced parentheses' do
      expect_offense(<<~'RUBY')
        "#{"hello(#{name})"}"
           ^^^^^^^^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{%Q(hello(#{name}))}"
      RUBY
    end

    it 'registers an offense but does not correct dstr with unbalanced closing parenthesis' do
      expect_offense(<<~'RUBY')
        "#{"foo) #{bar}"}"
           ^^^^^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not correct dstr with unbalanced opening parenthesis' do
      expect_offense(<<~'RUBY')
        "#{"(foo #{bar}"}"
           ^^^^^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_no_corrections
    end
  end

  context 'when EnforcedStyle is double_quotes' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers an offense and corrects str with single quotes' do
      expect_offense(<<~'RUBY')
        "#{"foobar"}"
           ^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{'foobar'}"
      RUBY
    end

    it 'does not register an offense for dstr' do
      expect_no_offenses(<<~'RUBY')
        "#{"hello #{name}"}"
      RUBY
    end

    it 'registers an offense only for str in multiple nesting levels' do
      expect_offense(<<~'RUBY')
        "Level 1: #{ "Level 2: #{ "Level 3" }" }"
                                  ^^^^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "Level 1: #{ "Level 2: #{ 'Level 3' }" }"
      RUBY
    end

    it 'registers an offense but does not correct str with escape sequences' do
      expect_offense(<<~'RUBY')
        "#{"\n"}"
           ^^^^ Nesting double-quotes makes code hard to read; use single-quotes inside interpolations.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not correct str with single quotes' do
      expect_offense(<<~'RUBY')
        "#{"it's"}"
           ^^^^^^ Nesting double-quotes makes code hard to read; use single-quotes inside interpolations.
      RUBY

      expect_no_corrections
    end
  end

  context 'when the inner string is empty' do
    it 'registers an offense and corrects an empty double-quoted string' do
      expect_offense(<<~'RUBY')
        "#{""}"
           ^^ Nesting double-quotes makes code hard to read; use single-quotes or `%Q(...)` inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{''}"
      RUBY
    end
  end
end
