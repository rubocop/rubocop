# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::LiteralAsCondition, :config do
  %w(1 2.0 [1] {} :sym :"#{a}").each do |lit|
    it "registers an offense for truthy literal #{lit} in if" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit}
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in if-else" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit}
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        else
          foo
        end
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in if-elsif" do
      expect_offense(<<~RUBY, lit: lit)
        if condition
          top
        elsif %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          foo
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          top
        else
          foo
        end
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in if-elsif-else" do
      expect_offense(<<~RUBY, lit: lit)
        if condition
          top
        elsif %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          foo
        else
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          top
        else
          foo
        end
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in if-elsif-else and preserves comments" do
      expect_offense(<<~RUBY, lit: lit)
        if condition
          top # comment 1
        elsif %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          foo # comment 2
        else
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          top # comment 1
        else
          foo # comment 2
        end
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in modifier if" do
      expect_offense(<<~RUBY, lit: lit)
        top if %{lit}
               ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in ternary" do
      expect_offense(<<~RUBY, lit: lit)
        %{lit} ? top : bar
        ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in unless" do
      expect_offense(<<~RUBY, lit: lit)
        unless %{lit}
               ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end

    it "registers an offense for truthy literal #{lit} in modifier unless" do
      expect_offense(<<~RUBY, lit: lit)
        top unless %{lit}
                   ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end

    it "registers an offense for truthy literal #{lit} in while" do
      expect_offense(<<~RUBY, lit: lit)
        while %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        while true
          top
        end
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in post-loop while" do
      expect_offense(<<~RUBY, lit: lit)
        begin
          top
        end while %{lit}
                  ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)
        begin
          top
        end while true
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in until" do
      expect_offense(<<~RUBY, lit: lit)
        until %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end

    it "registers an offense for truthy literal #{lit} in post-loop until" do
      expect_offense(<<~RUBY, lit: lit)
        begin
          top
        end until %{lit}
                  ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "registers an offense for literal #{lit} in case" do
      expect_offense(<<~RUBY, lit: lit)
        case %{lit}
             ^{lit} Literal `#{lit}` appeared as a condition.
        when x then top
        end
      RUBY

      expect_no_corrections
    end

    it "registers an offense for literal #{lit} in a when " \
       'of a case without anything after case keyword' do
      expect_offense(<<~RUBY, lit: lit)
        case
        when %{lit} then top
             ^{lit} Literal `#{lit}` appeared as a condition.
        end
      RUBY

      expect_no_corrections
    end

    it "accepts literal #{lit} in a when of a case with something after case keyword" do
      expect_no_offenses(<<~RUBY)
        case x
        when #{lit} then top
        end
      RUBY
    end

    context '>= Ruby 2.7', :ruby27 do
      it "accepts an offense for literal #{lit} in case match with a match var" do
        expect_no_offenses(<<~RUBY)
          case %{lit}
          in x then top
          end
        RUBY
      end

      it "registers an offense for literal #{lit} in case match without a match var" do
        expect_offense(<<~RUBY, lit: lit)
          case %{lit}
               ^{lit} Literal `#{lit}` appeared as a condition.
          in CONST then top
          end
        RUBY

        expect_no_corrections
      end

      it "accepts literal #{lit} in a when of a case match" do
        expect_no_offenses(<<~RUBY)
          case x
          in #{lit} then top
          end
        RUBY
      end
    end

    it "registers an offense for truthy literal #{lit} on the lhs of &&" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit} && x
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        if x
          top
        end
      RUBY
    end

    it "registers an offense for truthy literal #{lit} on the lhs of && with a truthy literal rhs" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit} && true
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "does not register an offense for truthy literal #{lit} on the rhs of &&" do
      expect_no_offenses(<<~RUBY)
        if x && %{lit}
          top
        end
      RUBY
    end

    it "registers an offense for truthy literal #{lit} in complex cond" do
      expect_offense(<<~RUBY, lit: lit)
        if x && !(%{lit} && a) && y && z
                  ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        if x && !(a) && y && z
          top
        end
      RUBY
    end

    it "registers an offense for literal #{lit} in !" do
      expect_offense(<<~RUBY, lit: lit)
        if !%{lit}
            ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_no_corrections
    end

    it "accepts literal #{lit} if it's not an and/or operand" do
      expect_no_offenses(<<~RUBY)
        if test(#{lit})
          top
        end
      RUBY
    end

    it "accepts literal #{lit} in non-toplevel and/or as an `if` condition" do
      expect_no_offenses(<<~RUBY)
        if (a || #{lit}).something
          top
        end
      RUBY
    end

    it "accepts literal #{lit} in non-toplevel and/or as a `case` condition" do
      expect_no_offenses(<<~RUBY)
        case a || #{lit}
        when b
          top
        end
      RUBY
    end

    it "registers an offense for `!#{lit}`" do
      expect_offense(<<~RUBY, lit: lit)
        !%{lit}
         ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_no_corrections
    end

    it "registers an offense for `not #{lit}`" do
      expect_offense(<<~RUBY, lit: lit)
        not(%{lit})
            ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_no_corrections
    end
  end

  it 'accepts array literal in case, if it has non-literal elements' do
    expect_no_offenses(<<~RUBY)
      case [1, 2, x]
      when [1, 2, 5] then top
      end
    RUBY
  end

  it 'accepts array literal in case, if it has nested non-literal element' do
    expect_no_offenses(<<~RUBY)
      case [1, 2, [x, 1]]
      when [1, 2, 5] then top
      end
    RUBY
  end

  it 'registers an offense for case with a primitive array condition' do
    expect_offense(<<~RUBY)
      case [1, 2, [3, 4]]
           ^^^^^^^^^^^^^^ Literal `[1, 2, [3, 4]]` appeared as a condition.
      when [1, 2, 5] then top
      end
    RUBY

    expect_no_corrections
  end

  it 'accepts dstr literal in case' do
    expect_no_offenses(<<~'RUBY')
      case "#{x}"
      when [1, 2, 5] then top
      end
    RUBY
  end

  context '>= Ruby 2.7', :ruby27 do
    it 'accepts array literal in case match, if it has non-literal elements' do
      expect_no_offenses(<<~RUBY)
        case [1, 2, x]
        in [1, 2, 5] then top
        end
      RUBY
    end

    it 'accepts array literal in case match, if it has nested non-literal element' do
      expect_no_offenses(<<~RUBY)
        case [1, 2, [x, 1]]
        in [1, 2, 5] then top
        end
      RUBY
    end

    it 'registers an offense for case match with a primitive array condition' do
      expect_offense(<<~RUBY)
        case [1, 2, [3, 4]]
             ^^^^^^^^^^^^^^ Literal `[1, 2, [3, 4]]` appeared as a condition.
        in [1, 2, 5] then top
        end
      RUBY

      expect_no_corrections
    end

    it 'accepts an offense for case match with a match var' do
      expect_no_offenses(<<~RUBY)
        case { a: 1, b: 2, c: 3 }
        in a: Integer => m
        end
      RUBY
    end

    it 'accepts dstr literal in case match' do
      expect_no_offenses(<<~'RUBY')
        case "#{x}"
        in [1, 2, 5] then top
        end
      RUBY
    end
  end

  it 'accepts `true` literal in `while`' do
    expect_no_offenses(<<~RUBY)
      while true
        break if condition
      end
    RUBY
  end

  it 'accepts `true` literal in post-loop `while`' do
    expect_no_offenses(<<~RUBY)
      begin
        break if condition
      end while true
    RUBY
  end

  it 'accepts `false` literal in `until`' do
    expect_no_offenses(<<~RUBY)
      until false
        break if condition
      end
    RUBY
  end

  it 'accepts `false` literal in post-loop `until`' do
    expect_no_offenses(<<~RUBY)
      begin
        break if condition
      end until false
    RUBY
  end

  %w[nil false].each do |lit|
    it "registers an offense for falsey literal #{lit} in `if`" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit}
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end

    it "registers an offense for falsey literal #{lit} in if-else" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit}
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        else
          foo
        end
      RUBY

      expect_correction(<<~RUBY)
        foo
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in if-elsif" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit}
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        elsif condition
          foo
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          foo
        end
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in if-elsif-else" do
      expect_offense(<<~RUBY, lit: lit)
        if condition
          top
        elsif %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          foo
        else
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          top
        else
          bar
        end
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in if-elsif-else and preserves comments" do
      expect_offense(<<~RUBY, lit: lit)
        if condition
          top # comment 1
        elsif %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          foo # comment 2
        else
          bar # comment 3
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          top # comment 1
        else
          bar # comment 3
        end
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in modifier `if`" do
      expect_offense(<<~RUBY, lit: lit)
        top if %{lit}
               ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end

    it "registers an offense for falsey literal #{lit} in ternary" do
      expect_offense(<<~RUBY, lit: lit)
        %{lit} ? top : bar
        ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)
        bar
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in `unless`" do
      expect_offense(<<~RUBY, lit: lit)
        unless %{lit}
               ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in modifier `unless`" do
      expect_offense(<<~RUBY, lit: lit)
        top unless %{lit}
                   ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in `while`" do
      expect_offense(<<~RUBY, lit: lit)
        while %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end

    it "registers an offense for falsey literal #{lit} in post-loop `while`" do
      expect_offense(<<~RUBY, lit: lit)
        begin
          top
        end while %{lit}
                  ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)
        top
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in complex post-loop `while`" do
      expect_offense(<<~RUBY, lit: lit)
        begin
          top
          foo
        end while %{lit}
                  ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY

      expect_correction(<<~RUBY)
        top
        foo
      RUBY
    end

    it "registers an offense for falsey literal #{lit} in `case`" do
      expect_offense(<<~RUBY, lit: lit)
        case %{lit}
             ^{lit} Literal `#{lit}` appeared as a condition.
        when x
          top
        end
      RUBY
    end

    it "registers an offense for falsey literal #{lit} on the lhs of ||" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit} || x
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        if x
          top
        end
      RUBY
    end
  end

  it 'registers an offense for `nil` literal in `until`' do
    expect_offense(<<~RUBY)
      until nil
            ^^^ Literal `nil` appeared as a condition.
        top
      end
    RUBY

    expect_correction(<<~RUBY)
      until false
        top
      end
    RUBY
  end

  it 'registers an offense for `nil` literal in post-loop `until`' do
    expect_offense(<<~RUBY)
      begin
        top
      end until nil
                ^^^ Literal `nil` appeared as a condition.
    RUBY

    expect_correction(<<~RUBY)
      begin
        top
      end until false
    RUBY
  end

  context 'void value expressions after autocorrect' do
    it 'registers an offense but does not autocorrect when `return` is used after `&&`' do
      expect_offense(<<~RUBY)
        def foo
          puts 123 && return if bar?
               ^^^ Literal `123` appeared as a condition.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not autocorrect when `return` is used after `||`' do
      expect_offense(<<~RUBY)
        def foo
          puts nil || return if bar?
               ^^^ Literal `nil` appeared as a condition.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not autocorrect when inside `if` and `return` is used after `&&`' do
      expect_offense(<<~RUBY)
        def foo
          baz? if 123 && return
                  ^^^ Literal `123` appeared as a condition.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not autocorrect when `break` is used after `&&`' do
      expect_offense(<<~RUBY)
        def foo
          bar do
            puts 123 && break if baz?
                 ^^^ Literal `123` appeared as a condition.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not autocorrect when `next` is used after `&&`' do
      expect_offense(<<~RUBY)
        def foo
          bar do
            puts 123 && next if baz?
                 ^^^ Literal `123` appeared as a condition.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when there is no body for `if` node' do
      expect_offense(<<~RUBY)
        if 42
           ^^ Literal `42` appeared as a condition.
        end
      RUBY

      expect_correction(<<~RUBY)

      RUBY
    end
  end
end
