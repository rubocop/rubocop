# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

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
    new_source = autocorrect_source(cop, 'something if str.match(/regex/)')
    expect(new_source).to eq 'something if str =~ /regex/'
  end

  it 'autocorrects .match in unless condition' do
    new_source = autocorrect_source(cop, 'something unless str.match(/regex/)')
    expect(new_source).to eq 'something unless str =~ /regex/'
  end

  it 'autocorrects .match in while condition' do
    new_source = autocorrect_source(cop, ['while str.match(/regex/)',
                                          '  do_something',
                                          'end'])
    expect(new_source).to eq(['while str =~ /regex/',
                              '  do_something',
                              'end'].join("\n"))
  end

  it 'autocorrects .match in until condition' do
    new_source = autocorrect_source(cop, ['until str.match(/regex/)',
                                          '  do_something',
                                          'end'])
    expect(new_source).to eq(['until str =~ /regex/',
                              '  do_something',
                              'end'].join("\n"))
  end

  it 'autocorrects .match in method body (but not tail position)' do
    new_source = autocorrect_source(cop, ['def method(str)',
                                          '  str.match(/regex/)',
                                          '  true',
                                          'end'])
    expect(new_source).to eq(['def method(str)',
                              '  str =~ /regex/',
                              '  true',
                              'end'].join("\n"))
  end

  it 'does not register an error when return value of .match is passed ' \
     'to another method' do
    inspect_source(cop, ['def method(str)',
                         ' something(str.match(/regex/))',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'does not register an error when return value of .match is stored in an ' \
     'instance variable' do
    inspect_source(cop, ['def method(str)',
                         ' @var = str.match(/regex/)',
                         ' true',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'does not register an error when return value of .match is returned from' \
     ' surrounding method' do
    inspect_source(cop, ['def method(str)',
                         ' str.match(/regex/)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'does not register an offense when match has a block' do
    inspect_source(cop, ['/regex/.match(str) do |m|',
                         '  something(m)',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an error when there is no receiver to the match call' do
    inspect_source(cop, 'match("bar")')
    expect(cop.messages).to be_empty
  end

  it 'formats error message correctly for something if str.match(/regex/)' do
    inspect_source(cop, 'something if str.match(/regex/)')
    expect(cop.messages).to eq(['Use `=~` in places where the `MatchData` ' \
                                'returned by `#match` will not be used.'])
  end
end
