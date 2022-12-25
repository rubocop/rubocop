# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAroundKeyword, :config do
  shared_examples 'missing before' do |highlight, expr, correct|
    it "registers an offense for missing space before keyword in `#{expr}`" do
      h_index = expr.index(highlight)
      expect_offense(<<~RUBY)
        #{expr}
        #{' ' * h_index}#{'^' * highlight.size} Space before keyword `#{highlight}` is missing.
      RUBY

      expect_correction("#{correct}\n")
    end
  end

  shared_examples 'missing after' do |highlight, expr, correct|
    it "registers an offense for missing space after keyword in `#{expr}` and autocorrects" do
      h_index = expr.index(highlight)
      expect_offense(<<~RUBY)
        #{expr}
        #{' ' * h_index}#{'^' * highlight.size} Space after keyword `#{highlight}` is missing.
      RUBY

      expect_correction("#{correct}\n")
    end
  end

  shared_examples 'accept before' do |after, expr|
    it "accepts `#{after}` before keyword in `#{expr}`" do
      expect_no_offenses(expr)
    end
  end

  shared_examples 'accept after' do |after, expr|
    it "accepts `#{after}` after keyword in `#{expr}`" do
      expect_no_offenses(expr)
    end
  end

  shared_examples 'accept around' do |after, expr|
    it "accepts `#{after}` around keyword in `#{expr}`" do
      expect_no_offenses(expr)
    end
  end

  it_behaves_like 'missing after', 'BEGIN', 'BEGIN{}', 'BEGIN {}'
  it_behaves_like 'missing after', 'END', 'END{}', 'END {}'
  it_behaves_like 'missing before', 'and', '1and 2', '1 and 2'
  it_behaves_like 'missing after', 'and', '1 and(2)', '1 and (2)'
  it_behaves_like 'missing after', 'begin', 'begin"" end', 'begin "" end'
  it_behaves_like 'missing after', 'break', 'break""', 'break ""'
  it_behaves_like 'accept after', '(', 'break(1)'
  it_behaves_like 'missing after', 'case', 'case"" when 1; end', 'case "" when 1; end'
  context '>= Ruby 2.7', :ruby27 do # rubocop:disable RSpec/RepeatedExampleGroupDescription
    it_behaves_like 'missing after', 'case', 'case""; in 1; end', 'case ""; in 1; end'
  end

  it_behaves_like 'missing before', 'do', 'a "b"do end', 'a "b" do end'
  it_behaves_like 'missing after', 'do', 'a do|x| end', 'a do |x| end'
  it_behaves_like 'missing before', 'do', 'while 1do end', 'while 1 do end'
  it_behaves_like 'missing after', 'do', 'while 1 do"x" end', 'while 1 do "x" end'
  it_behaves_like 'missing before', 'do', 'until 1do end', 'until 1 do end'
  it_behaves_like 'missing after', 'do', 'until 1 do"x" end', 'until 1 do "x" end'
  it_behaves_like 'missing before', 'do', 'for x in []do end', 'for x in [] do end'
  it_behaves_like 'missing after', 'do', 'for x in [] do"x" end', 'for x in [] do "x" end'

  it_behaves_like 'missing before', 'end', 'begin "a"end', 'begin "a" end'
  it_behaves_like 'missing before', 'end', 'if a; "b"end', 'if a; "b" end'
  it_behaves_like 'missing before', 'end', 'a do "a"end', 'a do "a" end'
  it_behaves_like 'missing before', 'end', 'while 1 do "x"end', 'while 1 do "x" end'
  it_behaves_like 'missing before', 'end', 'until 1 do "x"end', 'until 1 do "x" end'
  it_behaves_like 'missing before', 'end', 'for x in [] do "x"end', 'for x in [] do "x" end'
  it_behaves_like 'accept after', '.', 'begin end.inspect'

  it_behaves_like 'missing before', 'else', 'if a; ""else end', 'if a; "" else end'
  it_behaves_like 'missing after', 'else', 'if a; else"" end', 'if a; else "" end'
  it_behaves_like 'missing before', 'else', 'begin rescue; ""else end', 'begin rescue; "" else end'
  it_behaves_like 'missing after', 'else', 'begin rescue; else"" end', 'begin rescue; else "" end'
  it_behaves_like 'missing before', 'else', 'case a; when b; ""else end',
                  'case a; when b; "" else end'
  it_behaves_like 'missing after', 'else', 'case a; when b; else"" end',
                  'case a; when b; else "" end'
  context '>= Ruby 2.7', :ruby27 do # rubocop:disable RSpec/RepeatedExampleGroupDescription
    it_behaves_like 'missing before', 'else', 'case a; in b; ""else end',
                    'case a; in b; "" else end'
    it_behaves_like 'missing after', 'else', 'case a; in b; else"" end', 'case a; in b; else "" end'

    it_behaves_like 'missing before', 'if', 'case a; in "pattern"if "condition"; else "" end',
                    'case a; in "pattern" if "condition"; else "" end'
    it_behaves_like 'missing after', 'if', 'case a; in "pattern" if"condition"; else "" end',
                    'case a; in "pattern" if "condition"; else "" end'
    it_behaves_like 'missing before', 'unless', 'case a; in "pattern"unless "condition"; else "" end',
                    'case a; in "pattern" unless "condition"; else "" end'
    it_behaves_like 'missing after', 'unless', 'case a; in "pattern" unless"condition"; else "" end',
                    'case a; in "pattern" unless "condition"; else "" end'
  end

  it_behaves_like 'missing before', 'elsif', 'if a; ""elsif b; end', 'if a; "" elsif b; end'
  it_behaves_like 'missing after', 'elsif', 'if a; elsif""; end', 'if a; elsif ""; end'

  it_behaves_like 'missing before', 'ensure', 'begin ""ensure end', 'begin "" ensure end'
  it_behaves_like 'missing after', 'ensure', 'begin ensure"" end', 'begin ensure "" end'

  it_behaves_like 'missing after', 'if', 'if""; end', 'if ""; end'
  it_behaves_like 'missing after', 'next', 'next""', 'next ""'
  it_behaves_like 'accept after', '(', 'next(1)'
  it_behaves_like 'missing after', 'not', 'not""', 'not ""'
  it_behaves_like 'accept after', '(', 'not(1)'
  it_behaves_like 'missing before', 'or', '1or 2', '1 or 2'
  it_behaves_like 'missing after', 'or', '1 or(2)', '1 or (2)'

  it_behaves_like 'missing before', 'rescue', '""rescue a', '"" rescue a'
  it_behaves_like 'missing after', 'rescue', 'a rescue""', 'a rescue ""'
  it_behaves_like 'accept after', 'rescue', 'begin; rescue(Error); end', 'begin; rescue(Error); end'
  it_behaves_like 'missing after', 'return', 'return""', 'return ""'
  it_behaves_like 'accept after', '(', 'return(1)'
  it_behaves_like 'missing after', 'super', 'super""', 'super ""'
  it_behaves_like 'accept after', '(', 'super(1)'
  it_behaves_like 'missing after', 'super', 'super{}', 'super {}'
  it_behaves_like 'accept after', '(', 'defined?(1)'
  it_behaves_like 'missing after', 'defined?', 'defined?1', 'defined? 1'

  it_behaves_like 'missing before', 'then', 'if ""then a end', 'if "" then a end'
  it_behaves_like 'missing after', 'then', 'if a then"" end', 'if a then "" end'
  it_behaves_like 'missing after', 'unless', 'unless""; end', 'unless ""; end'
  it_behaves_like 'missing before', 'until', '1until ""', '1 until ""'
  it_behaves_like 'missing after', 'until', '1 until""', '1 until ""'
  it_behaves_like 'missing before', 'when', 'case ""when a; end', 'case "" when a; end'
  it_behaves_like 'missing after', 'when', 'case a when""; end', 'case a when ""; end'
  context '>= Ruby 2.7', :ruby27 do # rubocop:disable RSpec/RepeatedExampleGroupDescription
    # TODO: `case ""in a; end` is syntax error in Ruby 3.0.1.
    #       This syntax is confirmed: https://bugs.ruby-lang.org/issues/17925
    #       The answer will determine whether to enable or discard the test in the future.
    # it_behaves_like 'missing before', 'in', 'case ""in a; end', 'case "" in a; end'
    it_behaves_like 'missing after', 'in', 'case a; in""; end', 'case a; in ""; end'

    it_behaves_like 'missing before', 'in', '""in a', '"" in a'
    it_behaves_like 'missing after', 'in', 'a in""', 'a in ""'
  end

  context '>= Ruby 3.0', :ruby30 do
    it_behaves_like 'accept before', '=>', '""=> a'
    it_behaves_like 'accept after', '=>', 'a =>""'
  end

  it_behaves_like 'missing before', 'while', '1while ""', '1 while ""'
  it_behaves_like 'missing after', 'while', '1 while""', '1 while ""'
  it_behaves_like 'missing after', 'yield', 'yield""', 'yield ""'
  it_behaves_like 'accept after', '(', 'yield(1)'

  it_behaves_like 'accept after', '+', '+begin end'
  it_behaves_like 'missing after', 'begin', 'begin+1 end', 'begin +1 end'

  # Common exceptions
  it_behaves_like 'accept after', '\\', "test do\\\nend"
  it_behaves_like 'accept after', '\n', "test do\nend"
  it_behaves_like 'accept around', '()', '(next)'
  it_behaves_like 'accept before', '!', '!yield'
  it_behaves_like 'accept after', '.', 'yield.method'
  it_behaves_like 'accept before', '!', '!yield.method'
  it_behaves_like 'accept before', '!', '!super.method'
  it_behaves_like 'accept after', '::', 'super::ModuleName'

  context '&.' do
    it_behaves_like 'accept after', '&.', 'super&.foo'
    it_behaves_like 'accept after', '&.', 'yield&.foo'
  end

  it_behaves_like 'accept after', '[', 'super[1]'
  it_behaves_like 'accept after', '[', 'yield[1]'

  # Layout/SpaceAroundBlockParameters
  it_behaves_like 'accept before', '|', 'loop { |x|break }'

  # Layout/SpaceInsideRangeLiteral
  it_behaves_like 'accept before', '..', '1..super.size'
  it_behaves_like 'accept before', '...', '1...super.size'

  # Layout/SpaceAroundOperators
  it_behaves_like 'accept before', '=', 'a=begin end'
  it_behaves_like 'accept before', '==', 'a==begin end'
  it_behaves_like 'accept before', '+', 'a+begin end'
  it_behaves_like 'accept before', '+', 'a+begin; end.method'
  it_behaves_like 'accept before', '-', 'a-begin end'
  it_behaves_like 'accept before', '*', 'a*begin end'
  it_behaves_like 'accept before', '**', 'a**begin end'
  it_behaves_like 'accept before', '/', 'a/begin end'
  it_behaves_like 'accept before', '<', 'a<begin end'
  it_behaves_like 'accept before', '>', 'a>begin end'
  it_behaves_like 'accept before', '&&', 'a&&begin end'
  it_behaves_like 'accept before', '||', 'a||begin end'
  it_behaves_like 'accept before', '=*', 'a=*begin end'

  # Layout/SpaceBeforeBlockBraces
  it_behaves_like 'accept after', '{', 'loop{}'

  # Layout/SpaceBeforeComma, Layout/SpaceAfterComma
  it_behaves_like 'accept around', ',', 'a 1,next,1'

  # Layout/SpaceBeforeComment
  it_behaves_like 'accept after', '#', 'next#comment'

  # Layout/SpaceBeforeSemicolon, Layout/SpaceAfterSemicolon
  it_behaves_like 'accept around', ';', 'test do;end'

  # Layout/SpaceInsideArrayLiteralBrackets
  it_behaves_like 'accept around', '[]', '[begin end]'

  # Layout/SpaceInsideBlockBraces
  it_behaves_like 'accept around', '{}', 'loop {next}'

  # Layout/SpaceInsideHashLiteralBraces
  it_behaves_like 'accept around', '{}', '{a: begin end}'

  # Layout/SpaceInsideReferenceBrackets
  it_behaves_like 'accept around', '[]', 'a[begin end]'

  # Layout/SpaceInsideStringInterpolation
  it_behaves_like 'accept around', '{}', '"#{begin end}"'
end
