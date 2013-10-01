# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::IfUnlessModifier do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    hash = { 'LineLength' => { 'Max' => 79 } }
    Rubocop::Config.new(hash)
  end

  it 'registers an offence for multiline if that fits on one line' do
    # This if statement fits exactly on one line if written as a
    # modifier.
    condition = 'a' * 38
    body = 'b' * 35
    expect("  #{body} if #{condition}".length).to eq(79)

    inspect_source(cop,
                   ["  if #{condition}",
                    "    #{body}",
                    '  end'])
    expect(cop.messages).to eq(
      ['Favor modifier if/unless usage when you have a single-line' +
       ' body. Another good alternative is the usage of control flow' +
       ' &&/||.'])
  end

  it 'registers an offence for short multiline if near an else etc' do
    inspect_source(cop,
                   ['if x',
                    '  y',
                    'elsif x1',
                    '  y1',
                    'else',
                    '  z',
                    'end',
                    'n = a ? 0 : 1',
                    'm = 3 if m0',
                    '',
                    'if a',
                    '  b',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it "accepts multiline if that doesn't fit on one line" do
    check_too_long(cop, 'if')
  end

  it 'accepts multiline if whose body is more than one line' do
    check_short_multiline(cop, 'if')
  end

  it 'registers an offence for multiline unless that fits on one line' do
    inspect_source(cop, ['unless a',
                         '  b',
                         'end'])
    expect(cop.messages).to eq(
      ['Favor modifier if/unless usage when you have a single-line' +
       ' body. Another good alternative is the usage of control flow' +
       ' &&/||.'])
  end

  it 'accepts code with EOL comment since user might want to keep it' do
    inspect_source(cop, ['unless a',
                         '  b # A comment',
                         'end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts if-else-end' do
    inspect_source(cop,
                   ['if args.last.is_a? Hash then args.pop else ' +
                    'Hash.new end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts an empty condition' do
    check_empty(cop, 'if')
    check_empty(cop, 'unless')
  end

  it 'accepts if/elsif' do
    inspect_source(cop, ['if test',
                         '  something',
                         'elsif test2',
                         '  something_else',
                         'end'])
    expect(cop.offences).to be_empty
  end
end

describe Rubocop::Cop::Style::WhileUntilModifier do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    hash = { 'LineLength' => { 'Max' => 79 } }
    Rubocop::Config.new(hash)
  end

  it "accepts multiline unless that doesn't fit on one line" do
    check_too_long(cop, 'unless')
  end

  it 'accepts multiline unless whose body is more than one line' do
    check_short_multiline(cop, 'unless')
  end

  it 'registers an offence for multiline while that fits on one line' do
    check_really_short(cop, 'while')
  end

  it "accepts multiline while that doesn't fit on one line" do
    check_too_long(cop, 'while')
  end

  it 'accepts multiline while whose body is more than one line' do
    check_short_multiline(cop, 'while')
  end

  it 'registers an offence for multiline until that fits on one line' do
    check_really_short(cop, 'until')
  end

  it "accepts multiline until that doesn't fit on one line" do
    check_too_long(cop, 'until')
  end

  it 'accepts multiline until whose body is more than one line' do
    check_short_multiline(cop, 'until')
  end

  it 'accepts an empty condition' do
    check_empty(cop, 'while')
    check_empty(cop, 'until')
  end

  it 'accepts modifier while' do
    inspect_source(cop, ['ala while bala'])
    expect(cop.offences).to be_empty
  end

  it 'accepts modifier until' do
    inspect_source(cop, ['ala until bala'])
    expect(cop.offences).to be_empty
  end
end

def check_empty(cop, keyword)
  inspect_source(cop, ["#{keyword} cond",
                       'end'])
  expect(cop.offences).to be_empty
end

def check_really_short(cop, keyword)
  inspect_source(cop, ["#{keyword} a",
                       '  b',
                       'end'])
  expect(cop.messages).to eq(
    ['Favor modifier while/until usage when you have a single-line ' +
     'body.'])
  expect(cop.offences.map { |o| o.location.source }).to eq([keyword])
end

def check_too_long(cop, keyword)
  # This statement is one character too long to fit.
  condition = 'a' * (40 - keyword.length)
  body = 'b' * 36
  expect("  #{body} #{keyword} #{condition}".length).to eq(80)

  inspect_source(cop,
                 ["  #{keyword} #{condition}",
                  "    #{body}",
                  '  end'])

  expect(cop.offences).to be_empty
end

def check_short_multiline(cop, keyword)
  inspect_source(cop,
                 ["#{keyword} ENV['COVERAGE']",
                  "  require 'simplecov'",
                  '  SimpleCov.start',
                  'end'])
  expect(cop.messages).to be_empty
end
