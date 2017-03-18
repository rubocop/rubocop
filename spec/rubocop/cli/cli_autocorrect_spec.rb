# frozen_string_literal: true

describe RuboCop::CLI, :isolated_environment do
  include_context 'cli spec behavior'

  subject(:cli) { described_class.new }

  it 'does not correct ExtraSpacing in a hash that would be changed back' do
    create_file('.rubocop.yml', ['Style/AlignHash:',
                                 '  EnforcedColonStyle: table'])
    source = ['hash = {',
              '  alice: {',
              '    age:  23,',
              "    role: 'Director'",
              '  },',
              '  bob:   {',
              '    age:  25,',
              "    role: 'Consultant'",
              '  }',
              '}']
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb')).to eq(source.join("\n") + "\n")
  end

  it 'does not correct SpaceAroundOperators in a hash that would be ' \
     'changed back' do
    create_file('.rubocop.yml', ['Style/HashSyntax:',
                                 '  EnforcedStyle: hash_rockets',
                                 '',
                                 'Style/AlignHash:',
                                 '  EnforcedHashRocketStyle: table'])
    source = ['a = { 1=>2, a => b }',
              'hash = {',
              '  :alice => {',
              '    :age  => 23,',
              "    :role => 'Director'",
              '  },',
              '  :bob   => {',
              '    :age  => 25,',
              "    :role => 'Consultant'",
              '  }',
              '}']
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(1)

    # 1=>2 is changed to 1 => 2. The rest is unchanged.
    # SpaceAroundOperators leaves it to AlignHash when the style is table.
    expect(IO.read('example.rb')).to eq(['a = { 1 => 2, a => b }',
                                         'hash = {',
                                         '  :alice => {',
                                         '    :age  => 23,',
                                         "    :role => 'Director'",
                                         '  },',
                                         '  :bob   => {',
                                         '    :age  => 25,',
                                         "    :role => 'Consultant'",
                                         '  }',
                                         '}'].join("\n") + "\n")
  end

  shared_examples 'trailing comma adder' do |comma_style, brace_configs, corr|
    Array(brace_configs).each do |brace_config|
      context "with #{comma_style} and #{brace_config} configuration" do
        it 'corrects TrailingCommaInLiteral and TrailingCommaInArguments ' \
           'without producing a double comma' do
          create_file('.rubocop.yml',
                      ['Style/TrailingCommaInArguments:',
                       "  EnforcedStyleForMultiline: #{comma_style}",
                       '',
                       'Style/TrailingCommaInLiteral:',
                       "  EnforcedStyleForMultiline: #{comma_style}",
                       '',
                       'Style/BracesAroundHashParameters:',
                       "  #{brace_config}"])
          source = ['func({',
                    '  @abc => 0,',
                    '  @xyz => 1',
                    '})',
                    'func(',
                    '  {',
                    '    abc: 0',
                    '  }',
                    ')',
                    'func(',
                    '  {},',
                    '  {',
                    '    xyz: 1',
                    '  }',
                    ')']
          create_file('example.rb', source)
          cli.run(['--auto-correct'])
          expect(IO.read('example.rb')).to eq(corr.join("\n") + "\n")
          expect($stderr.string).to eq('')
        end
      end
    end
  end

  it_behaves_like 'trailing comma adder', :comma, ['Enabled: false',
                                                   'AutoCorrect: false',
                                                   'EnforcedStyle: braces'],
                  ['func({',
                   '       @abc => 0,',
                   '       @xyz => 1,', # comma added
                   '     })',
                   'func(',
                   '  {',
                   '    abc: 0,', # comma added
                   '  },', # comma added
                   ')',
                   'func(',
                   '  {},',
                   '  {',
                   '    xyz: 1,', # comma added
                   '  },', # comma added
                   ')']
  it_behaves_like 'trailing comma adder', :comma, 'EnforcedStyle: no_braces',
                  ['func(@abc => 0,',
                   '     @xyz => 1)',
                   'func(',
                   '  abc: 0,', # comma added
                   ')',
                   'func(',
                   '  {},',
                   '  xyz: 1,', # comma added
                   ')']
  it_behaves_like 'trailing comma adder', :comma,
                  'EnforcedStyle: context_dependent',
                  ['func(@abc => 0,',
                   '     @xyz => 1)',
                   'func(',
                   '  abc: 0,', # comma added
                   ')',
                   'func(',
                   '  {},',
                   '  {',
                   '    xyz: 1,', # comma added
                   '  },', # comma added
                   ')']
  it_behaves_like 'trailing comma adder', :consistent_comma,
                  ['Enabled: false',
                   'AutoCorrect: false',
                   'EnforcedStyle: braces'],
                  ['func({',
                   '       @abc => 0,',
                   '       @xyz => 1,', # comma added
                   '     },)', # comma added
                   'func(',
                   '  {',
                   '    abc: 0,', # comma added
                   '  },', # comma added
                   ')',
                   'func(',
                   '  {},',
                   '  {',
                   '    xyz: 1,', # comma added
                   '  },', # comma added
                   ')']
  it_behaves_like 'trailing comma adder', :consistent_comma,
                  'EnforcedStyle: no_braces',
                  ['func(@abc => 0,',
                   '     @xyz => 1,)', # comma added
                   'func(',
                   '  abc: 0,', # comma added
                   ')',
                   'func(',
                   '  {},',
                   '  xyz: 1,', # comma added
                   ')']
  it_behaves_like 'trailing comma adder', :consistent_comma,
                  'EnforcedStyle: context_dependent',
                  ['func(@abc => 0,',
                   '     @xyz => 1,)', # comma added
                   'func(',
                   '  abc: 0,', # comma added
                   ')',
                   'func(',
                   '  {},',
                   '  {',
                   '    xyz: 1,', # comma added
                   '  },', # comma added
                   ')']

  it 'corrects IndentationWidth, RedundantBegin, and ' \
     'RescueEnsureAlignment offenses' do
    source = ['def verify_section',
              '      begin',
              '      scroll_down_until_element_exists',
              '      rescue',
              '        scroll_down_until_element_exists',
              '        end',
              'end']
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = ['def verify_section',
                 '  scroll_down_until_element_exists',
                 'rescue',
                 '  scroll_down_until_element_exists',
                 'end',
                 '']
    expect(IO.read('example.rb')).to eq(corrected.join("\n"))
  end

  it 'corrects LineEndConcatenation offenses leaving the ' \
     'UnneededInterpolation offense unchanged' do
    # If we change string concatenation from plus to backslash, the string
    # literal that follows must remain a string literal.
    source = ["puts 'foo' +",
              '     "#{bar}"',
              "puts 'a' +",
              "  'b'",
              '"#{c}"']
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = ["puts 'foo' \\",
                 '     "#{bar}"',
                 # Expressions that need correction from only one of these cops
                 # are corrected as expected.
                 "puts 'a' \\",
                 "     'b'",
                 'c.to_s',
                 '']
    expect(IO.read('example.rb')).to eq(corrected.join("\n"))
  end

  %i(line_count_based semantic braces_for_chaining).each do |style|
    context "when BlockDelimiters has #{style} style" do
      it 'corrects SpaceBeforeBlockBraces, SpaceInsideBlockBraces offenses' do
        source = ['r = foo.map{|a|',
                  '  a.bar.to_s',
                  '}',
                  'foo.map{|a|',
                  '  a.bar.to_s',
                  '}.baz']
        create_file('example.rb', source)
        create_file('.rubocop.yml', ['Style/BlockDelimiters:',
                                     "  EnforcedStyle: #{style}"])
        expect(cli.run(['--auto-correct'])).to eq(1)
        corrected = case style
                    when :semantic
                      ['r = foo.map { |a|',
                       '  a.bar.to_s',
                       '}',
                       'foo.map { |a|',
                       '  a.bar.to_s',
                       '}.baz',
                       '']
                    when :braces_for_chaining
                      ['r = foo.map do |a|',
                       '  a.bar.to_s',
                       'end',
                       'foo.map { |a|',
                       '  a.bar.to_s',
                       '}.baz',
                       '']
                    when :line_count_based
                      ['r = foo.map do |a|',
                       '  a.bar.to_s',
                       'end',
                       'foo.map do |a|',
                       '  a.bar.to_s',
                       'end.baz',
                       '']
                    end
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb')).to eq(corrected.join("\n"))
      end
    end
  end

  it 'corrects InitialIndentation offenses' do
    source = ['  # comment 1',
              '',
              '  # comment 2',
              '  def func',
              '    begin',
              '      foo',
              '      bar',
              '    rescue',
              '      baz',
              '    end',
              '  end',
              ''].join("\n")
    create_file('example.rb', source)
    create_file('.rubocop.yml', ['Lint/DefEndAlignment:',
                                 '  AutoCorrect: true'])
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = ['# comment 1',
                 '',
                 '# comment 2',
                 'def func',
                 '  foo',
                 '  bar',
                 'rescue',
                 '  baz',
                 'end',
                 '']
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(corrected.join("\n"))
  end

  it 'corrects UnneededDisable offenses' do
    source = ['class A',
              '  # rubocop:disable Metrics/MethodLength',
              '  def func',
              '    x = foo # rubocop:disable Lint/UselessAssignment,Style/For',
              '    # rubocop:disable all',
              '    # rubocop:disable Style/ClassVars',
              '    @@bar = "3"',
              '  end',
              'end',
              ''].join("\n")
    create_file('example.rb', source)
    expect(cli.run(%w(--auto-correct --format simple))).to eq(1)
    expect($stdout.string)
      .to eq(['== example.rb ==',
              'C:  1:  1: Missing top-level class documentation comment.',
              'W:  2:  3: [Corrected] Unnecessary disabling of ' \
              'Metrics/MethodLength.',
              'W:  4: 54: [Corrected] Unnecessary disabling of Style/For.',
              'W:  6:  5: [Corrected] Unnecessary disabling of ' \
              'Style/ClassVars.',
              '',
              '1 file inspected, 4 offenses detected, 3 offenses corrected',
              ''].join("\n"))
    corrected = ['class A',
                 '  def func',
                 '    x = foo # rubocop:disable Lint/UselessAssignment',
                 '    # rubocop:disable all',
                 '    @@bar = "3"',
                 '  end',
                 'end',
                 '']
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(corrected.join("\n"))
  end

  it 'corrects RedundantBegin offenses and fixes indentation etc' do
    source = ['  def func',
              '    begin',
              '      foo',
              '      bar',
              '    rescue',
              '      baz',
              '    end',
              '  end',
              '',
              '  def func; begin; x; y; rescue; z end end',
              '',
              'def method',
              '  begin',
              '    BlockA do |strategy|',
              '      foo',
              '    end',
              '',
              '    BlockB do |portfolio|',
              '      foo',
              '    end',
              '',
              '  rescue => e # some problem',
              '    bar',
              '  end',
              'end',
              '',
              'def method',
              '  begin # comment 1',
              '    do_some_stuff',
              '  rescue # comment 2',
              '  end # comment 3',
              'end',
              ''].join("\n")
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(1)
    corrected = ['def func',
                 '  foo',
                 '  bar',
                 '  rescue',
                 '    baz',
                 '  end',
                 '',
                 'def func',
                 '  x; y; rescue; z',
                 'end',
                 '',
                 'def method',
                 '  BlockA do |_strategy|',
                 '    foo',
                 '  end',
                 '',
                 '  BlockB do |_portfolio|',
                 '    foo',
                 '  end',
                 'rescue => e # some problem',
                 '  bar',
                 'end',
                 '',
                 'def method',
                 '  # comment 1',
                 '  do_some_stuff',
                 'rescue # comment 2',
                 '  # comment 3',
                 'end',
                 '']
    expect(IO.read('example.rb')).to eq(corrected.join("\n"))
  end

  it 'corrects Tab and IndentationConsistency offenses' do
    source = ['  render_views',
              "    describe 'GET index' do",
              "\t    it 'returns http success' do",
              "\t    end",
              "\tdescribe 'admin user' do",
              '     before(:each) do',
              "\t    end",
              "\tend",
              '    end',
              '']
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = ['render_views',
                 "describe 'GET index' do",
                 "  it 'returns http success' do",
                 '  end',
                 "  describe 'admin user' do",
                 '    before(:each) do',
                 '    end',
                 '  end',
                 'end',
                 '']
    expect(IO.read('example.rb')).to eq(corrected.join("\n"))
  end

  it 'corrects IndentationWidth and IndentationConsistency offenses' do
    source = ["require 'spec_helper'",
              'describe ArticlesController do',
              '  render_views',
              '    describe "GET \'index\'" do',
              '            it "returns http success" do',
              '            end',
              '        describe "admin user" do',
              '             before(:each) do',
              '            end',
              '        end',
              '    end',
              'end']
    create_file('example.rb', source)
    expect(cli.run(['--auto-correct'])).to eq(0)
    corrected = ["require 'spec_helper'",
                 'describe ArticlesController do',
                 '  render_views',
                 "  describe \"GET 'index'\" do",
                 "    it 'returns http success' do",
                 '    end',
                 "    describe 'admin user' do",
                 '      before(:each) do',
                 '      end',
                 '    end',
                 '  end',
                 'end',
                 '']
    expect(IO.read('example.rb')).to eq(corrected.join("\n"))
  end

  it 'corrects SymbolProc and SpaceBeforeBlockBraces offenses' do
    source = ['foo.map{ |a| a.nil? }']
    create_file('example.rb', source)
    expect(cli.run(['-D', '--auto-correct'])).to eq(0)
    corrected = "foo.map(&:nil?)\n"
    expect(IO.read('example.rb')).to eq(corrected)
    uncorrected = $stdout.string.split($RS).select do |line|
      line.include?('example.rb:') && !line.include?('[Corrected]')
    end
    expect(uncorrected).to be_empty # Hence exit code 0.
  end

  it 'corrects only IndentationWidth without crashing' do
    source = ['foo = if bar',
              '  something',
              'elsif baz',
              '  other_thing',
              'else',
              '  raise',
              'end']
    create_file('example.rb', source)
    expect(cli.run(%w(--only IndentationWidth --auto-correct))).to eq(0)
    corrected = ['foo = if bar',
                 '        something',
                 'elsif baz',
                 '  other_thing',
                 'else',
                 '  raise',
                 'end',
                 ''].join("\n")
    expect(IO.read('example.rb')).to eq(corrected)
  end

  it 'corrects complicated cases conservatively' do
    # Two cops make corrections here; Style/BracesAroundHashParameters, and
    # Style/AlignHash. Because they make minimal corrections relating only
    # to their specific areas, and stay away from cleaning up extra
    # whitespace in the process, the combined changes don't interfere with
    # each other and the result is semantically the same as the starting
    # point.
    source = ['expect(subject[:address]).to eq({',
              "  street1:     '1 Market',",
              "  street2:     '#200',",
              "  city:        'Some Town',",
              "  state:       'CA',",
              "  postal_code: '99999-1111'",
              '})']
    create_file('example.rb', source)
    expect(cli.run(['-D', '--auto-correct'])).to eq(0)
    corrected =
      ["expect(subject[:address]).to eq(street1:     '1 Market',",
       "                                street2:     '#200',",
       "                                city:        'Some Town',",
       "                                state:       'CA',",
       "                                postal_code: '99999-1111')"]
    expect(IO.read('example.rb')).to eq(corrected.join("\n") + "\n")
  end

  it 'honors Exclude settings in individual cops' do
    source = 'puts %x(ls)'
    create_file('example.rb', source)
    create_file('.rubocop.yml', ['Style/CommandLiteral:',
                                 '  Exclude:',
                                 '    - example.rb'])
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect($stdout.string).to include('no offenses detected')
    expect(IO.read('example.rb')).to eq("#{source}\n")
  end

  it 'corrects code with indentation problems' do
    create_file('example.rb', ['module Bar',
                               'class Goo',
                               '  def something',
                               '    first call',
                               "      do_other 'things'",
                               '      if other > 34',
                               '        more_work',
                               '      end',
                               '  end',
                               'end',
                               'end',
                               '',
                               'module Foo',
                               'class Bar',
                               '',
                               '  stuff = [',
                               '            {',
                               "              some: 'hash',",
                               '            },',
                               '                 {',
                               "              another: 'hash',",
                               "              with: 'more'",
                               '            },',
                               '          ]',
                               'end',
                               'end'])
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb'))
      .to eq(['module Bar',
              '  class Goo',
              '    def something',
              '      first call',
              "      do_other 'things'",
              '      more_work if other > 34',
              '    end',
              '  end',
              'end',
              '',
              'module Foo',
              '  class Bar',
              '    stuff = [',
              '      {',
              "        some: 'hash'",
              '      },',
              '      {',
              "        another: 'hash',",
              "        with: 'more'",
              '      }',
              '    ]',
              '  end',
              'end',
              ''].join("\n"))
  end

  it 'can change block comments and indent them' do
    create_file('example.rb', ['module Foo',
                               'class Bar',
                               '=begin',
                               'This is a nice long',
                               'comment',
                               'which spans a few lines',
                               '=end',
                               '  def baz',
                               '    do_something',
                               '  end',
                               'end',
                               'end'])
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb'))
      .to eq(['module Foo',
              '  class Bar',
              '    # This is a nice long',
              '    # comment',
              '    # which spans a few lines',
              '    def baz',
              '      do_something',
              '    end',
              '  end',
              'end',
              ''].join("\n"))
  end

  it 'can correct two problems with blocks' do
    # {} should be do..end and space is missing.
    create_file('example.rb', ['(1..10).each{ |i|',
                               '  puts i',
                               '}'])
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(['(1..10).each do |i|',
              '  puts i',
              'end',
              ''].join("\n"))
  end

  it 'can handle spaces when removing braces' do
    create_file('example.rb',
                ["assert_post_status_code 400, 's', {:type => 'bad'}"])
    expect(cli.run(%w(--auto-correct --format emacs))).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(["assert_post_status_code 400, 's', type: 'bad'",
              ''].join("\n"))
    e = abs('example.rb')
    expect($stdout.string)
      .to eq(["#{e}:1:35: C: [Corrected] Redundant curly braces around " \
              'a hash parameter.',
              # TODO: Don't report that a problem is corrected when it
              # actually went away due to another correction.
              "#{e}:1:35: C: [Corrected] Space inside { missing.",
              "#{e}:1:36: C: [Corrected] Use the new Ruby 1.9 hash " \
              'syntax.',
              "#{e}:1:50: C: [Corrected] Space inside } missing.",
              ''].join("\n"))
  end

  # A case where two cops, EmptyLinesAroundBody and EmptyLines, try to
  # remove the same line in autocorrect.
  it 'can correct two empty lines at end of class body' do
    create_file('example.rb', ['class Test',
                               '  def f',
                               '  end',
                               '',
                               '',
                               'end'])
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(['class Test',
                                         '  def f; end',
                                         'end',
                                         ''].join("\n"))
  end

  # A case where WordArray's correction can be clobbered by
  # AccessModifierIndentation's correction.
  it 'can correct indentation and another thing' do
    create_file('example.rb', ['class Dsl',
                               'private',
                               '  A = ["git", "path",]',
                               'end'])
    expect(cli.run(%w(--auto-correct --format emacs))).to eq(1)
    expect(IO.read('example.rb')).to eq(['class Dsl',
                                         '  private',
                                         '',
                                         '  A = %w(git path).freeze',
                                         'end',
                                         ''].join("\n"))
    e = abs('example.rb')
    expect($stdout.string)
      .to eq(["#{e}:1:1: C: Missing top-level class documentation " \
              'comment.',
              "#{e}:2:1: C: [Corrected] Indent access modifiers like " \
              '`private`.',
              "#{e}:2:1: C: [Corrected] Keep a blank line after `private`.",
              "#{e}:2:3: W: Useless `private` access modifier.",
              "#{e}:3:7: C: [Corrected] Freeze mutable objects assigned " \
              'to constants.',
              "#{e}:3:7: C: [Corrected] Use `%w` or `%W` " \
              'for an array of words.',
              "#{e}:3:8: C: [Corrected] Prefer single-quoted strings " \
              "when you don't need string interpolation or special " \
              'symbols.',
              "#{e}:3:15: C: [Corrected] Prefer single-quoted strings " \
              "when you don't need string interpolation or special " \
              'symbols.',
              "#{e}:3:21: C: [Corrected] Avoid comma after the last item " \
              'of an array.',
              "#{e}:4:7: C: [Corrected] Use `%w` or `%W` " \
              'for an array of words.',
              ''].join("\n"))
  end

  # A case where the same cop could try to correct an offense twice in one
  # place.
  it 'can correct empty line inside special form of nested modules' do
    create_file('example.rb', ['module A module B',
                               '',
                               'end end'])
    expect(cli.run(['--auto-correct'])).to eq(1)
    expect(IO.read('example.rb')).to eq(['module A module B',
                                         'end end',
                                         ''].join("\n"))
    uncorrected = $stdout.string.split($RS).select do |line|
      line.include?('example.rb:') && !line.include?('[Corrected]')
    end
    expect(uncorrected).not_to be_empty # Hence exit code 1.
  end

  it 'can correct single line methods' do
    create_file('example.rb', ['def func1; do_something end # comment',
                               'def func2() do_1; do_2; end'])
    expect(cli.run(%w(--auto-correct --format offenses))).to eq(0)
    expect(IO.read('example.rb')).to eq(['# comment',
                                         'def func1',
                                         '  do_something',
                                         'end',
                                         '',
                                         'def func2',
                                         '  do_1',
                                         '  do_2',
                                         'end',
                                         ''].join("\n"))
    expect($stdout.string).to eq(['',
                                  '6   Style/TrailingWhitespace',
                                  '3   Style/Semicolon',
                                  '2   Style/SingleLineMethods',
                                  '1   Style/DefWithParentheses',
                                  '1   Style/EmptyLineBetweenDefs',
                                  '--',
                                  '13  Total',
                                  '',
                                  ''].join("\n"))
  end

  # In this example, the auto-correction (changing "fail" to "raise")
  # creates a new problem (alignment of parameters), which is also
  # corrected automatically.
  it 'can correct a problems and the problem it creates' do
    create_file('example.rb',
                ['fail NotImplementedError,',
                 "     'Method should be overridden in child classes'"])
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(['raise NotImplementedError,',
              "      'Method should be overridden in child classes'",
              ''].join("\n"))
    expect($stdout.string)
      .to eq(['Inspecting 1 file',
              'C',
              '',
              'Offenses:',
              '',
              'example.rb:1:1: C: [Corrected] Always use raise ' \
              'to signal exceptions.',
              'fail NotImplementedError,',
              '^^^^',
              'example.rb:2:6: C: [Corrected] Align the parameters of a ' \
              'method call if they span more than one line.',
              "     'Method should be overridden in child classes'",
              '     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',
              '',
              '1 file inspected, 2 offenses detected, 2 offenses ' \
              'corrected',
              ''].join("\n"))
  end

  # Thanks to repeated auto-correction, we can get rid of the trailing
  # spaces, and then the extra empty line.
  it 'can correct two problems in the same place' do
    create_file('example.rb',
                ['# Example class.',
                 'class Klass',
                 '  ',
                 '  def f; end',
                 'end'])
    expect(cli.run(['--auto-correct'])).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(['# Example class.',
              'class Klass',
              '  def f; end',
              'end',
              ''].join("\n"))
    expect($stderr.string).to eq('')
    expect($stdout.string)
      .to eq(['Inspecting 1 file',
              'C',
              '',
              'Offenses:',
              '',
              'example.rb:3:1: C: [Corrected] Extra empty line detected ' \
              'at class body beginning.',
              'example.rb:3:1: C: [Corrected] Trailing whitespace ' \
              'detected.',
              '',
              '1 file inspected, 2 offenses detected, 2 offenses ' \
              'corrected',
              ''].join("\n"))
  end

  it 'can correct MethodDefParentheses and other offense' do
    create_file('example.rb',
                ['def primes limit',
                 '  1.upto(limit).select { |i| i.even? }',
                 'end'])
    expect(cli.run(%w(-D --auto-correct))).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb'))
      .to eq(['def primes(limit)',
              '  1.upto(limit).select(&:even?)',
              'end',
              ''].join("\n"))
    expect($stdout.string)
      .to eq(['Inspecting 1 file',
              'C',
              '',
              'Offenses:',
              '',
              'example.rb:1:12: C: [Corrected] ' \
              'Style/MethodDefParentheses: ' \
              'Use def with parentheses when there are parameters.',
              'def primes limit',
              '           ^^^^^',
              'example.rb:2:24: C: [Corrected] Style/SymbolProc: ' \
              'Pass &:even? as an argument to select instead of a block.',
              '  1.upto(limit).select { |i| i.even? }',
              '                       ^^^^^^^^^^^^^^^',
              '',
              '1 file inspected, 2 offenses detected, 2 offenses ' \
              'corrected',
              ''].join("\n"))
  end

  it 'can correct WordArray and SpaceAfterComma offenses' do
    create_file('example.rb',
                ["f(type: ['offline','offline_payment'],",
                 "  bar_colors: ['958c12','953579','ff5800','0085cc'])"])
    expect(cli.run(%w(-D --auto-correct --format o))).to eq(0)
    expect($stdout.string)
      .to eq(['',
              '4  Style/SpaceAfterComma',
              '2  Style/WordArray',
              '--',
              '6  Total',
              '',
              ''].join("\n"))
    expect(IO.read('example.rb'))
      .to eq(['f(type: %w(offline offline_payment),',
              '  bar_colors: %w(958c12 953579 ff5800 0085cc))',
              ''].join("\n"))
  end

  it 'can correct SpaceAfterComma and HashSyntax offenses' do
    create_file('example.rb',
                "I18n.t('description',:property_name => property.name)")
    expect(cli.run(%w(-D --auto-correct --format emacs))).to eq(0)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:21: C: [Corrected] " \
              'Style/SpaceAfterComma: Space missing after comma.',
              "#{abs('example.rb')}:1:22: C: [Corrected] " \
              'Style/HashSyntax: Use the new Ruby 1.9 hash syntax.',
              ''].join("\n"))
    expect(IO.read('example.rb'))
      .to eq("I18n.t('description', property_name: property.name)\n")
  end

  it 'can correct HashSyntax and SpaceAroundOperators offenses' do
    create_file('example.rb', '{ :b=>1 }')
    expect(cli.run(%w(-D --auto-correct --format emacs))).to eq(0)
    expect(IO.read('example.rb')).to eq("{ b: 1 }\n")
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:3: C: [Corrected] " \
              'Style/HashSyntax: Use the new Ruby 1.9 hash syntax.',
              "#{abs('example.rb')}:1:5: C: [Corrected] " \
              'Style/SpaceAroundOperators: Surrounding space missing for ' \
              'operator `=>`.',
              ''].join("\n"))
  end

  it 'can correct HashSyntax when --only is used' do
    create_file('example.rb', '{ :b=>1 }')
    expect(cli.run(%w(--auto-correct -f emacs
                      --only Style/HashSyntax))).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("{ b: 1 }\n")
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:3: C: [Corrected] Use the new " \
              'Ruby 1.9 hash syntax.',
              ''].join("\n"))
  end

  it 'can correct TrailingBlankLines and TrailingWhitespace offenses' do
    create_file('example.rb',
                ['# encoding: utf-8',
                 '',
                 '  ',
                 '',
                 ''])
    expect(cli.run(%w(--auto-correct --format emacs))).to eq(0)
    expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                         ''].join("\n"))
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:2:1: C: [Corrected] 3 trailing " \
              'blank lines detected.',
              "#{abs('example.rb')}:3:1: C: [Corrected] Trailing " \
              'whitespace detected.',
              ''].join("\n"))
  end

  it 'can correct MethodCallWithoutArgsParentheses and EmptyLiteral offenses' do
    create_file('example.rb', 'Hash.new()')
    expect(cli.run(%w(--auto-correct --format emacs))).to eq(0)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("{}\n")
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:1: C: [Corrected] Use hash " \
              'literal `{}` instead of `Hash.new`.',
              "#{abs('example.rb')}:1:9: C: [Corrected] Do not use " \
              'parentheses for method calls with no arguments.',
              ''].join("\n"))
  end

  it 'can correct IndentHash offenses with separator style' do
    create_file('example.rb',
                ['CONVERSION_CORRESPONDENCE = {',
                 '              match_for_should: :match,',
                 '          match_for_should_not: :match_when_negated,',
                 '    failure_message_for_should: :failure_message,',
                 'failure_message_for_should_not: :failure_message_when',
                 '}'])
    create_file('.rubocop.yml',
                ['Style/AlignHash:',
                 '  EnforcedColonStyle: separator'])
    expect(cli.run(%w(--auto-correct))).to eq(0)
    expect(IO.read('example.rb'))
      .to eq(['CONVERSION_CORRESPONDENCE = {',
              '                match_for_should: :match,',
              '            match_for_should_not: :match_when_negated,',
              '      failure_message_for_should: :failure_message,',
              '  failure_message_for_should_not: :failure_message_when',
              '}.freeze',
              ''].join("\n"))
  end

  it 'does not say [Corrected] if correction was avoided' do
    src = ['func a do b end',
           "Signal.trap('TERM') { system(cmd); exit }",
           'def self.some_method(foo, bar: 1)',
           '  log.debug(foo)',
           'end']
    corrected = ['func a do b end',
                 "Signal.trap('TERM') { system(cmd); exit }",
                 'def self.some_method(foo, bar: 1)',
                 '  log.debug(foo)',
                 'end']
    offenses =
      ['== example.rb ==',
       'C:  1:  8: Prefer {...} over do...end for single-line blocks.',
       'C:  2: 34: Do not use semicolons to terminate expressions.',
       'W:  3: 27: Unused method argument - bar.']
    summary = '1 file inspected, 3 offenses detected'
    create_file('.rubocop.yml', ['AllCops:',
                                 '  TargetRubyVersion: 2.1'])
    create_file('example.rb', src)
    expect(cli.run(%w(-a -f simple))).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(corrected.join("\n") + "\n")
    expect($stdout.string)
      .to eq((offenses + ['', summary, '']).join("\n"))
  end

  it 'does not hang SpaceAfterPunctuation and SpaceInsideParens' do
    create_file('example.rb', 'some_method(a, )')
    Timeout.timeout(10) do
      expect(cli.run(%w(--auto-correct))).to eq(0)
    end
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("some_method(a)\n")
  end

  it 'does not hang SpaceAfterPunctuation and SpaceInsideBrackets' do
    create_file('example.rb', 'puts [1, ]')
    Timeout.timeout(10) do
      expect(cli.run(%w(--auto-correct))).to eq(0)
    end
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("puts [1]\n")
  end

  it 'can be disabled for any cop in configuration' do
    create_file('example.rb', 'puts "Hello", 123456')
    create_file('.rubocop.yml', ['Style/StringLiterals:',
                                 '  AutoCorrect: false'])
    expect(cli.run(%w(--auto-correct))).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq("puts \"Hello\", 123_456\n")
  end

  it 'handles different SpaceInsideBlockBraces and ' \
     'SpaceInsideHashLiteralBraces' do
    create_file('example.rb', ['{foo: bar,',
                               ' bar: baz,}',
                               'foo.each {bar;}'])
    create_file('.rubocop.yml', [
                  'Style/SpaceInsideBlockBraces:',
                  '  EnforcedStyle: space',
                  'Style/SpaceInsideHashLiteralBraces:',
                  '  EnforcedStyle: no_space',
                  'Style/TrailingCommaInLiteral:',
                  '  EnforcedStyleForMultiline: consistent_comma'
                ])
    expect(cli.run(%w(--auto-correct))).to eq(1)
    expect($stderr.string).to eq('')
    expect(IO.read('example.rb')).to eq(['{foo: bar,',
                                         ' bar: baz,}',
                                         'foo.each { bar; }',
                                         ''].join("\n"))
  end

  it 'corrects BracesAroundHashParameters offenses leaving the ' \
     'MultilineHashBraceLayout offense unchanged' do
    create_file('example.rb', ['def method_a',
                               '  do_something({ a: 1,',
                               '  })',
                               'end',
                               ''])

    expect($stderr.string).to eq('')
    expect(cli.run(%w(--auto-correct))).to eq(0)
    expect(IO.read('example.rb')).to eq(['def method_a',
                                         '  do_something(a: 1)',
                                         'end',
                                         ''].join("\n"))
  end
end
