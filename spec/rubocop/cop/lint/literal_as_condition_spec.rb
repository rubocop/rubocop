# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::LiteralAsCondition, :config do
  %w(1 2.0 [1] {} :sym :"#{a}").each do |lit|
    it "registers an offense for literal #{lit} in if" do
      expect_offense(<<~RUBY, lit: lit)
        if %{lit}
           ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY
    end

    it "registers an offense for literal #{lit} in while" do
      expect_offense(<<~RUBY, lit: lit)
        while %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY
    end

    it "registers an offense for literal #{lit} in post-loop while" do
      expect_offense(<<~RUBY, lit: lit)
        begin
          top
        end while(%{lit})
                  ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY
    end

    it "registers an offense for literal #{lit} in until" do
      expect_offense(<<~RUBY, lit: lit)
        until %{lit}
              ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY
    end

    it "registers an offense for literal #{lit} in post-loop until" do
      expect_offense(<<~RUBY, lit: lit)
        begin
          top
        end until %{lit}
                  ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY
    end

    it "registers an offense for literal #{lit} in case" do
      expect_offense(<<~RUBY, lit: lit)
        case %{lit}
             ^{lit} Literal `#{lit}` appeared as a condition.
        when x then top
        end
      RUBY
    end

    it "registers an offense for literal #{lit} in a when " \
       'of a case without anything after case keyword' do
      expect_offense(<<~RUBY, lit: lit)
        case
        when %{lit} then top
             ^{lit} Literal `#{lit}` appeared as a condition.
        end
      RUBY
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
        expect_no_offenses(<<~RUBY, lit: lit)
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
      end

      it "accepts literal #{lit} in a when of a case match" do
        expect_no_offenses(<<~RUBY)
          case x
          in #{lit} then top
          end
        RUBY
      end
    end

    it "registers an offense for literal #{lit} in &&" do
      expect_offense(<<~RUBY, lit: lit)
        if x && %{lit}
                ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY
    end

    it "registers an offense for literal #{lit} in complex cond" do
      expect_offense(<<~RUBY, lit: lit)
        if x && !(a && %{lit}) && y && z
                       ^{lit} Literal `#{lit}` appeared as a condition.
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
    end

    it "registers an offense for literal #{lit} in complex !" do
      expect_offense(<<~RUBY, lit: lit)
        if !(x && (y && %{lit}))
                        ^{lit} Literal `#{lit}` appeared as a condition.
          top
        end
      RUBY
    end

    it "accepts literal #{lit} if it's not an and/or operand" do
      expect_no_offenses(<<~RUBY)
        if test(#{lit})
          top
        end
      RUBY
    end

    it "accepts literal #{lit} in non-toplevel and/or" do
      expect_no_offenses(<<~RUBY)
        if (a || #{lit}).something
          top
        end
      RUBY
    end

    it "registers an offense for `!#{lit}`" do
      expect_offense(<<~RUBY, lit: lit)
        !%{lit}
         ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY
    end

    it "registers an offense for `not #{lit}`" do
      expect_offense(<<~RUBY, lit: lit)
        not(%{lit})
            ^{lit} Literal `#{lit}` appeared as a condition.
      RUBY
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
end
