# encoding: utf-8
require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAroundKeyword do
  subject(:cop) { described_class.new }

  shared_examples 'missing before' do |highlight, expr, correct|
    it 'registers an offense for missing space before keyword in ' \
       "`#{expr}`" do
      inspect_source(cop, expr)
      expect(cop.messages)
        .to eq(["Space before keyword `#{highlight}` is missing."])
      expect(cop.highlights).to eq([highlight])
    end

    it 'auto-corrects' do
      expect(autocorrect_source(cop, expr)).to eq correct
    end
  end

  shared_examples 'missing after' do |highlight, expr, correct|
    it 'registers an offense for missing space after keyword in ' \
       "`#{expr}`" do
      inspect_source(cop, expr)
      expect(cop.messages)
        .to eq(["Space after keyword `#{highlight}` is missing."])
      expect(cop.highlights).to eq([highlight])
    end

    it 'auto-corrects' do
      expect(autocorrect_source(cop, expr)).to eq correct
    end
  end

  shared_examples 'accept before' do |after, expr|
    it "accepts `#{after}` before keyword in `#{expr}`" do
      inspect_source(cop, expr)
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples 'accept after' do |after, expr|
    it "accepts `#{after}` after keyword in `#{expr}`" do
      inspect_source(cop, expr)
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples 'accept around' do |after, expr|
    it "accepts `#{after}` around keyword in `#{expr}`" do
      inspect_source(cop, expr)
      expect(cop.offenses).to be_empty
    end
  end

  it_behaves_like 'missing after', 'BEGIN', 'BEGIN{}', 'BEGIN {}'
  it_behaves_like 'missing after', 'END', 'END{}', 'END {}'
  it_behaves_like 'missing before', 'and', '1and 2', '1 and 2'
  it_behaves_like 'missing after', 'and', '1 and(2)', '1 and (2)'
  it_behaves_like 'missing after', 'begin', 'begin"" end', 'begin "" end'
  it_behaves_like 'missing after', 'break', 'break""', 'break ""'
  it_behaves_like 'accept after', '(', 'break(1)'
  it_behaves_like 'missing after', 'case', 'case"" when 1; end',
                  'case "" when 1; end'

  it_behaves_like 'missing before', 'do', 'a "b"do end', 'a "b" do end'
  it_behaves_like 'missing after', 'do', 'a do|x| end', 'a do |x| end'
  it_behaves_like 'missing before', 'do', 'while 1do end', 'while 1 do end'
  it_behaves_like 'missing after', 'do', 'while 1 do"x" end',
                  'while 1 do "x" end'
  it_behaves_like 'missing before', 'do', 'until 1do end', 'until 1 do end'
  it_behaves_like 'missing after', 'do', 'until 1 do"x" end',
                  'until 1 do "x" end'
  it_behaves_like 'missing before', 'do', 'for x in []do end',
                  'for x in [] do end'
  it_behaves_like 'missing after', 'do', 'for x in [] do"x" end',
                  'for x in [] do "x" end'

  it_behaves_like 'missing before', 'end', 'begin "a"end', 'begin "a" end'
  it_behaves_like 'missing before', 'end', 'if a; "b"end', 'if a; "b" end'
  it_behaves_like 'missing before', 'end', 'a do "a"end', 'a do "a" end'
  it_behaves_like 'missing before', 'end', 'while 1 do "x"end',
                  'while 1 do "x" end'
  it_behaves_like 'missing before', 'end', 'until 1 do "x"end',
                  'until 1 do "x" end'
  it_behaves_like 'missing before', 'end', 'for x in [] do "x"end',
                  'for x in [] do "x" end'
  it_behaves_like 'accept after', '.', 'begin end.inspect'

  it_behaves_like 'missing before', 'else', 'if a; ""else end',
                  'if a; "" else end'
  it_behaves_like 'missing after', 'else', 'if a; else"" end',
                  'if a; else "" end'
  it_behaves_like 'missing before', 'else', 'begin rescue; ""else end',
                  'begin rescue; "" else end'
  it_behaves_like 'missing after', 'else', 'begin rescue; else"" end',
                  'begin rescue; else "" end'
  it_behaves_like 'missing before', 'else', 'case a; when b; ""else end',
                  'case a; when b; "" else end'
  it_behaves_like 'missing after', 'else', 'case a; when b; else"" end',
                  'case a; when b; else "" end'

  it_behaves_like 'missing before', 'elsif', 'if a; ""elsif b; end',
                  'if a; "" elsif b; end'
  it_behaves_like 'missing after', 'elsif', 'if a; elsif""; end',
                  'if a; elsif ""; end'

  it_behaves_like 'missing before', 'elsif', 'if a; ""elsif b; end',
                  'if a; "" elsif b; end'
  it_behaves_like 'missing after', 'elsif', 'if a; elsif""; end',
                  'if a; elsif ""; end'

  it_behaves_like 'missing before', 'ensure', 'begin ""ensure end',
                  'begin "" ensure end'
  it_behaves_like 'missing after', 'ensure', 'begin ensure"" end',
                  'begin ensure "" end'

  it_behaves_like 'missing after', 'if', 'if""; end', 'if ""; end'
  it_behaves_like 'missing after', 'next', 'next""', 'next ""'
  it_behaves_like 'accept after', '(', 'next(1)'
  it_behaves_like 'missing after', 'not', 'not""', 'not ""'
  it_behaves_like 'missing before', 'or', '1or 2', '1 or 2'
  it_behaves_like 'missing after', 'or', '1 or(2)', '1 or (2)'

  it_behaves_like 'missing before', 'rescue', '""rescue a', '"" rescue a'
  it_behaves_like 'missing after', 'rescue', 'a rescue""', 'a rescue ""'
  it_behaves_like 'missing after', 'return', 'return""', 'return ""'
  it_behaves_like 'accept after', '(', 'return(1)'
  it_behaves_like 'missing after', 'super', 'super""', 'super ""'
  it_behaves_like 'accept after', '(', 'super(1)'

  it_behaves_like 'missing before', 'then', 'if ""then a end',
                  'if "" then a end'
  it_behaves_like 'missing after', 'then', 'if a then"" end',
                  'if a then "" end'
  it_behaves_like 'missing after', 'unless', 'unless""; end', 'unless ""; end'
  it_behaves_like 'missing before', 'until', '1until ""', '1 until ""'
  it_behaves_like 'missing after', 'until', '1 until""', '1 until ""'
  it_behaves_like 'missing before', 'when', 'case ""when a; end',
                  'case "" when a; end'
  it_behaves_like 'missing after', 'when', 'case a when""; end',
                  'case a when ""; end'
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

  # Style/SpaceAroundBlockParameters
  it_behaves_like 'accept before', '|', 'loop { |x|break }'

  # Style/SpaceAroundOperators
  it_behaves_like 'accept before', '=', 'a=begin end'
  it_behaves_like 'accept before', '==', 'a==begin end'
  it_behaves_like 'accept before', '+', 'a+begin end'
  it_behaves_like 'accept before', '-', 'a-begin end'
  it_behaves_like 'accept before', '*', 'a*begin end'
  it_behaves_like 'accept before', '**', 'a**begin end'
  it_behaves_like 'accept before', '/', 'a/begin end'
  it_behaves_like 'accept before', '<', 'a<begin end'
  it_behaves_like 'accept before', '>', 'a>begin end'
  it_behaves_like 'accept before', '&&', 'a&&begin end'
  it_behaves_like 'accept before', '||', 'a||begin end'
  it_behaves_like 'accept before', '=*', 'a=*begin end'

  # Style/SpaceBeforeBlockBraces
  it_behaves_like 'accept after', '{', 'loop{}'

  # Style/SpaceBeforeComma, Style/SpaceAfterComma
  it_behaves_like 'accept around', ',', 'a 1,next,1'

  # Style/SpaceBeforeComment
  it_behaves_like 'accept after', '#', 'next#comment'

  # Style/SpaceBeforeSemicolon, Style/SpaceAfterSemicolon
  it_behaves_like 'accept around', ';', 'test do;end'

  # Style/SpaceInsideBlockBraces
  it_behaves_like 'accept around', '{}', 'loop {next}'

  # Style/SpaceInsideBrackets
  it_behaves_like 'accept around', '[]', '[begin end]'

  # Style/SpaceInsideHashLiteralBraces
  it_behaves_like 'accept around', '{}', '{a: begin end}'

  # Style/SpaceInsideStringInterpolation
  it_behaves_like 'accept around', '{}', '"#{begin end}"'
end
