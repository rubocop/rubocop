# frozen_string_literal: true

#   do_something if str.match(/regex/)
#   while regex.match('str')
#     do_something
#   end
#
#   @good
#   method(str.match(/regex/))
#   return regex.match('str')

describe RuboCop::Cop::Performance::RedundantMatch do
  subject(:cop) { described_class.new }

  it 'autocorrects .match in if condition' do
    new_source = autocorrect_source('something if str.match(/regex/)')
    expect(new_source).to eq 'something if str =~ /regex/'
  end

  it 'autocorrects .match in unless condition' do
    new_source = autocorrect_source('something unless str.match(/regex/)')
    expect(new_source).to eq 'something unless str =~ /regex/'
  end

  it 'autocorrects .match in while condition' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      while str.match(/regex/)
        do_something
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      while str =~ /regex/
        do_something
      end
    RUBY
  end

  it 'autocorrects .match in until condition' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      until str.match(/regex/)
        do_something
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      until str =~ /regex/
        do_something
      end
    RUBY
  end

  it 'autocorrects .match in method body (but not tail position)' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def method(str)
        str.match(/regex/)
        true
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      def method(str)
        str =~ /regex/
        true
      end
    RUBY
  end

  it 'does not autocorrect if .match has a string agrgument' do
    new_source = autocorrect_source('something if str.match("string")')
    expect(new_source).to eq 'something if str.match("string")'
  end

  it 'does not register an error when return value of .match is passed ' \
     'to another method' do
    inspect_source(<<-RUBY.strip_indent)
      def method(str)
       something(str.match(/regex/))
      end
    RUBY
    expect(cop.messages).to be_empty
  end

  it 'does not register an error when return value of .match is stored in an ' \
     'instance variable' do
    inspect_source(<<-RUBY.strip_indent)
      def method(str)
       @var = str.match(/regex/)
       true
      end
    RUBY
    expect(cop.messages).to be_empty
  end

  it 'does not register an error when return value of .match is returned from' \
     ' surrounding method' do
    inspect_source(<<-RUBY.strip_indent)
      def method(str)
       str.match(/regex/)
      end
    RUBY
    expect(cop.messages).to be_empty
  end

  it 'does not register an offense when match has a block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      /regex/.match(str) do |m|
        something(m)
      end
    RUBY
  end

  it 'does not register an error when there is no receiver to the match call' do
    expect_no_offenses('match("bar")')
  end

  it 'formats error message correctly for something if str.match(/regex/)' do
    expect_offense(<<-RUBY.strip_indent)
      something if str.match(/regex/)
                   ^^^^^^^^^^^^^^^^^^ Use `=~` in places where the `MatchData` returned by `#match` will not be used.
    RUBY
  end
end
