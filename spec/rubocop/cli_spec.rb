# encoding: utf-8

require 'spec_helper'
require 'timeout'

describe RuboCop::CLI, :isolated_environment do
  include FileHelper

  subject(:cli) { described_class.new }

  before(:each) do
    $stdout = StringIO.new
    $stderr = StringIO.new
    RuboCop::ConfigLoader.debug = false

    # OPTIMIZE: Makes these specs faster. Work directory (the parent of
    # .rubocop_cache) is removed afterwards anyway.
    RuboCop::ResultCache.inhibit_cleanup = true
  end

  after(:each) do
    $stdout = STDOUT
    $stderr = STDERR
    RuboCop::ResultCache.inhibit_cleanup = false
  end

  def abs(path)
    File.expand_path(path)
  end

  describe 'option' do
    describe '--list-target-files' do
      context 'when there are no files' do
        it 'prints nothing with -L' do
          cli.run ['-L']
          expect($stdout.string).to be_empty
        end

        it 'prints nothing with --list-target-files' do
          cli.run ['--list-target-files']
          expect($stdout.string).to be_empty
        end
      end

      context 'when there are some files' do
        before(:each) do
          create_file('show.rabl', 'object @user => :person')
          create_file('app.rb', 'puts "hello world"')
          create_file('Gemfile', ['source "https://rubygems.org"',
                                  'gem "rubocop"'])
          create_file('lib/helper.rb', 'puts "helpful"')
        end

        context 'when there are no includes or excludes' do
          it 'prints known ruby files' do
            cli.run ['-L']
            expect($stdout.string.split("\n")).to match_array ['app.rb',
                                                               'Gemfile',
                                                               'lib/helper.rb']
          end
        end

        context 'when there is an include and exclude' do
          before(:each) do
            create_file('.rubocop.yml', ['AllCops:',
                                         '  Exclude:',
                                         '    - Gemfile',
                                         '  Include:',
                                         '    - "**/*.rabl"'])
          end

          it 'prints the included files and not the excluded ones' do
            cli.run ['--list-target-files']
            expect($stdout.string.split("\n")).to match_array ['app.rb',
                                                               'lib/helper.rb',
                                                               'show.rabl']
          end
        end
      end
    end

    describe '--version' do
      it 'exits cleanly' do
        expect(cli.run(['-v'])).to eq(0)
        expect(cli.run(['--version'])).to eq(0)
        expect($stdout.string).to eq((RuboCop::Version::STRING + "\n") * 2)
      end
    end

    describe '--auto-correct' do
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
                     '',
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
                  '  fail',
                  'end']
        create_file('example.rb', source)
        expect(cli.run(%w(--only IndentationWidth --auto-correct))).to eq(0)
        corrected = ['foo = if bar',
                     '        something',
                     'elsif baz',
                     '  other_thing',
                     'else',
                     '  fail',
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
        source = ['# encoding: utf-8',
                  'expect(subject[:address]).to eq({',
                  "  street1:     '1 Market',",
                  "  street2:     '#200',",
                  "  city:        'Some Town',",
                  "  state:       'CA',",
                  "  postal_code: '99999-1111'",
                  '})']
        create_file('example.rb', source)
        expect(cli.run(['-D', '--auto-correct'])).to eq(0)
        corrected =
          ['# encoding: utf-8',
           "expect(subject[:address]).to eq(street1:     '1 Market',",
           "                                street2:     '#200',",
           "                                city:        'Some Town',",
           "                                state:       'CA',",
           "                                postal_code: '99999-1111')"]
        expect(IO.read('example.rb')).to eq(corrected.join("\n") + "\n")
      end

      it 'honors Exclude settings in individual cops' do
        source = ['# encoding: utf-8',
                  'puts %x(ls)']
        create_file('example.rb', source)
        create_file('.rubocop.yml', ['Style/CommandLiteral:',
                                     '  Exclude:',
                                     '    - example.rb'])
        expect(cli.run(['--auto-correct'])).to eq(0)
        expect($stdout.string).to include('no offenses detected')
        expect(IO.read('example.rb')).to eq(source.join("\n") + "\n")
      end

      it 'corrects code with indentation problems' do
        create_file('example.rb', ['# encoding: utf-8',
                                   'module Bar',
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
                                   'end'
                                  ])
        expect(cli.run(['--auto-correct'])).to eq(1)
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  'module Bar',
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
        create_file('example.rb', ['# encoding: utf-8',
                                   'module Foo',
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
          .to eq(['# encoding: utf-8',
                  'module Foo',
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
        create_file('example.rb', ['# encoding: utf-8',
                                   '(1..10).each{ |i|',
                                   '  puts i',
                                   '}'])
        expect(cli.run(['--auto-correct'])).to eq(0)
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  '(1..10).each do |i|',
                  '  puts i',
                  'end',
                  ''].join("\n"))
      end

      it 'can handle spaces when removing braces' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     "assert_post_status_code 400, 's', {:type => 'bad'}"])
        expect(cli.run(%w(--auto-correct --format emacs))).to eq(0)
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  "assert_post_status_code 400, 's', type: 'bad'",
                  ''].join("\n"))
        e = abs('example.rb')
        expect($stdout.string)
          .to eq(["#{e}:2:35: C: [Corrected] Redundant curly braces around " \
                  'a hash parameter.',
                  "#{e}:2:35: C: [Corrected] Use the new Ruby 1.9 hash " \
                  'syntax.',
                  # TODO: Don't report that a problem is corrected when it
                  # actually went away due to another correction.
                  "#{e}:2:35: C: [Corrected] Space inside { missing.",
                  # TODO: Don't report duplicates (HashSyntax in this case).
                  "#{e}:2:36: C: [Corrected] Use the new Ruby 1.9 hash " \
                  'syntax.',
                  "#{e}:2:50: C: [Corrected] Space inside } missing.",
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
                                             '  def f',
                                             '  end',
                                             'end',
                                             ''].join("\n"))
      end

      # A case where WordArray's correction can be clobbered by
      # AccessModifierIndentation's correction.
      it 'can correct indentation and another thing' do
        create_file('example.rb', ['# encoding: utf-8',
                                   'class Dsl',
                                   'private',
                                   '  A = ["git", "path",]',
                                   'end'])
        expect(cli.run(%w(--auto-correct --format emacs))).to eq(1)
        expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                             'class Dsl',
                                             '  private',
                                             '',
                                             '  A = %w(git path)',
                                             'end',
                                             ''].join("\n"))
        e = abs('example.rb')
        expect($stdout.string)
          .to eq(["#{e}:2:1: C: Missing top-level class documentation " \
                  'comment.',
                  "#{e}:3:1: C: [Corrected] Indent access modifiers like " \
                  '`private`.',
                  "#{e}:3:1: C: [Corrected] Keep a blank line before and " \
                  'after `private`.',
                  "#{e}:3:3: W: Useless `private` access modifier.",
                  "#{e}:3:3: C: [Corrected] Keep a blank line before and " \
                  'after `private`.',
                  "#{e}:4:7: C: [Corrected] Use `%w` or `%W` " \
                  'for an array of words.',
                  "#{e}:4:8: C: [Corrected] Prefer single-quoted strings " \
                  "when you don't need string interpolation or special " \
                  'symbols.',
                  "#{e}:4:15: C: [Corrected] Prefer single-quoted strings " \
                  "when you don't need string interpolation or special " \
                  'symbols.',
                  "#{e}:4:21: C: [Corrected] Avoid comma after the last item " \
                  'of an array.',
                  "#{e}:5:7: C: [Corrected] Use `%w` or `%W` " \
                  'for an array of words.',
                  "#{e}:5:8: C: [Corrected] Prefer single-quoted strings " \
                  "when you don't need string interpolation or special " \
                  'symbols.',
                  "#{e}:5:15: C: [Corrected] Prefer single-quoted strings " \
                  "when you don't need string interpolation or special " \
                  'symbols.',
                  "#{e}:5:21: C: [Corrected] Avoid comma after the last item " \
                  'of an array.',
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
        create_file('example.rb', ['# encoding: utf-8',
                                   'def func1; do_something end # comment',
                                   'def func2() do_1; do_2; end'])
        expect(cli.run(%w(--auto-correct --format offenses))).to eq(0)
        expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                             '# comment',
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
                                      '10  Style/TrailingWhitespace',
                                      '3   Style/Semicolon',
                                      '3   Style/SingleLineMethods',
                                      '1   Style/DefWithParentheses',
                                      '1   Style/EmptyLineBetweenDefs',
                                      '--',
                                      '18  Total',
                                      '',
                                      ''].join("\n"))
      end

      # In this example, the auto-correction (changing "raise" to "fail")
      # creates a new problem (alignment of parameters), which is also
      # corrected automatically.
      it 'can correct a problems and the problem it creates' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     'raise NotImplementedError,',
                     "      'Method should be overridden in child classes'"])
        expect(cli.run(['--auto-correct'])).to eq(0)
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  'fail NotImplementedError,',
                  "     'Method should be overridden in child classes'",
                  ''].join("\n"))
        expect($stdout.string)
          .to eq(['Inspecting 1 file',
                  'C',
                  '',
                  'Offenses:',
                  '',
                  'example.rb:2:1: C: [Corrected] Use fail instead of ' \
                  'raise to signal exceptions.',
                  'raise NotImplementedError,',
                  '^^^^^',
                  'example.rb:3:7: C: [Corrected] Align the parameters of a ' \
                  'method call if they span more than one line.',
                  "      'Method should be overridden in child classes'",
                  '      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',
                  '',
                  '1 file inspected, 2 offenses detected, 2 offenses ' \
                  'corrected',
                  ''].join("\n"))
      end

      # Thanks to repeated auto-correction, we can get rid of the trailing
      # spaces, and then the extra empty line.
      it 'can correct two problems in the same place' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     '# Example class.',
                     'class Klass',
                     '  ',
                     '  def f',
                     '  end',
                     'end'])
        expect(cli.run(['--auto-correct'])).to eq(0)
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  '# Example class.',
                  'class Klass',
                  '  def f',
                  '  end',
                  'end',
                  ''].join("\n"))
        expect($stderr.string).to eq('')
        expect($stdout.string)
          .to eq(['Inspecting 1 file',
                  'C',
                  '',
                  'Offenses:',
                  '',
                  'example.rb:4:1: C: [Corrected] Extra empty line detected ' \
                  'at class body beginning.',
                  'example.rb:4:1: C: [Corrected] Trailing whitespace ' \
                  'detected.',
                  '',
                  '1 file inspected, 2 offenses detected, 2 offenses ' \
                  'corrected',
                  ''].join("\n"))
      end

      it 'can correct MethodDefParentheses and other offense' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     'def primes limit',
                     '  1.upto(limit).select { |i| i.even? }',
                     'end'])
        expect(cli.run(%w(-D --auto-correct))).to eq(0)
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  'def primes(limit)',
                  '  1.upto(limit).select(&:even?)',
                  'end',
                  ''].join("\n"))
        expect($stdout.string)
          .to eq(['Inspecting 1 file',
                  'C',
                  '',
                  'Offenses:',
                  '',
                  'example.rb:2:12: C: [Corrected] ' \
                  'Style/MethodDefParentheses: ' \
                  'Use def with parentheses when there are parameters.',
                  'def primes limit',
                  '           ^^^^^',
                  'example.rb:3:24: C: [Corrected] Style/SymbolProc: ' \
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
                    ['# encoding: utf-8',
                     "f(type: ['offline','offline_payment'],",
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
          .to eq(['# encoding: utf-8',
                  'f(type: %w(offline offline_payment),',
                  '  bar_colors: %w(958c12 953579 ff5800 0085cc))',
                  ''].join("\n"))
      end

      it 'can correct SpaceAfterComma and HashSyntax offenses' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     "I18n.t('description',:property_name => property.name)"])
        expect(cli.run(%w(-D --auto-correct --format emacs))).to eq(0)
        expect($stdout.string)
          .to eq(["#{abs('example.rb')}:2:21: C: [Corrected] " \
                  'Style/SpaceAfterComma: Space missing after comma.',
                  "#{abs('example.rb')}:2:22: C: [Corrected] " \
                  'Style/HashSyntax: Use the new Ruby 1.9 hash syntax.',
                  ''].join("\n"))
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  "I18n.t('description', property_name: property.name)",
                  ''].join("\n"))
      end

      it 'can correct HashSyntax and SpaceAroundOperators offenses' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     '{ :b=>1 }'])
        expect(cli.run(%w(-D --auto-correct --format emacs))).to eq(0)
        expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                             '{ b: 1 }',
                                             ''].join("\n"))
        expect($stdout.string)
          .to eq(["#{abs('example.rb')}:2:3: C: [Corrected] " \
                  'Style/HashSyntax: Use the new Ruby 1.9 hash syntax.',
                  "#{abs('example.rb')}:2:5: C: [Corrected] " \
                  'Style/SpaceAroundOperators: Surrounding space missing for ' \
                  'operator `=>`.',
                  ''].join("\n"))
      end

      it 'can correct HashSyntax when --only is used' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     '{ :b=>1 }'])
        expect(cli.run(%w(--auto-correct -f emacs
                          --only Style/HashSyntax))).to eq(0)
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                             '{ b: 1 }',
                                             ''].join("\n"))
        expect($stdout.string)
          .to eq(["#{abs('example.rb')}:2:3: C: [Corrected] Use the new " \
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

      it 'can correct MethodCallParentheses and EmptyLiteral offenses' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     'Hash.new()'])
        expect(cli.run(%w(--auto-correct --format emacs))).to eq(0)
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                             '{}',
                                             ''].join("\n"))
        expect($stdout.string)
          .to eq(["#{abs('example.rb')}:2:1: C: [Corrected] Use hash " \
                  'literal `{}` instead of `Hash.new`.',
                  "#{abs('example.rb')}:2:9: C: [Corrected] Do not use " \
                  'parentheses for method calls with no arguments.',
                  ''].join("\n"))
      end

      it 'can correct IndentHash offenses with separator style' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     'CONVERSION_CORRESPONDENCE = {',
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
          .to eq(['# encoding: utf-8',
                  'CONVERSION_CORRESPONDENCE = {',
                  '                match_for_should: :match,',
                  '            match_for_should_not: :match_when_negated,',
                  '      failure_message_for_should: :failure_message,',
                  '  failure_message_for_should_not: :failure_message_when',
                  '}',
                  ''].join("\n"))
      end

      it 'does not say [Corrected] if correction was avoided' do
        src = ['# encoding: utf-8',
               'not a && b',
               'func a do b end',
               "Signal.trap('TERM') { system(cmd); exit }"]
        corrected = ['# encoding: utf-8',
                     'not a && b',
                     'func a do b end',
                     "Signal.trap('TERM') { system(cmd); exit }"]
        offenses =
          ['== example.rb ==',
           'C:  2:  1: Use ! instead of not.',
           'C:  3:  8: Prefer {...} over do...end for single-line blocks.',
           'C:  4: 34: Do not use semicolons to terminate expressions.']

        if RUBY_VERSION >= '2'
          src += ['def self.some_method(foo, bar: 1)',
                  '  log.debug(foo)',
                  'end']
          corrected += ['def self.some_method(foo, bar: 1)',
                        '  log.debug(foo)',
                        'end']
          offenses += ['W:  5: 27: Unused method argument - bar.']
          summary = '1 file inspected, 4 offenses detected'
        else
          summary = '1 file inspected, 3 offenses detected'
        end
        create_file('example.rb', src)
        expect(cli.run(%w(-a -f simple))).to eq(1)
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb')).to eq(corrected.join("\n") + "\n")
        expect($stdout.string)
          .to eq((offenses + ['', summary, '']).join("\n"))
      end

      it 'does not hang SpaceAfterPunctuation and SpaceInsideParens' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     'some_method(a, )'])
        Timeout.timeout(10) do
          expect(cli.run(%w(--auto-correct))).to eq(0)
        end
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                             'some_method(a)',
                                             ''].join("\n"))
      end

      it 'does not hang SpaceAfterPunctuation and SpaceInsideBrackets' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     'puts [1, ]'])
        Timeout.timeout(10) do
          expect(cli.run(%w(--auto-correct))).to eq(0)
        end
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                             'puts [1]',
                                             ''].join("\n"))
      end

      it 'can be disabled for any cop in configuration' do
        create_file('example.rb', ['# encoding: utf-8',
                                   'puts "Hello", 123456'])
        create_file('.rubocop.yml', ['Style/StringLiterals:',
                                     '  AutoCorrect: false'])
        expect(cli.run(%w(--auto-correct))).to eq(1)
        expect($stderr.string).to eq('')
        expect(IO.read('example.rb')).to eq(['# encoding: utf-8',
                                             'puts "Hello", 123_456',
                                             ''].join("\n"))
      end
    end

    describe '--auto-gen-config' do
      before(:each) do
        RuboCop::Formatter::DisabledConfigFormatter
          .config_to_allow_offenses = {}
      end

      it 'overwrites an existing todo file' do
        create_file('example1.rb', ['# encoding: utf-8',
                                    'x= 0 ',
                                    '#' * 85,
                                    'y ',
                                    'puts x'])
        create_file('.rubocop_todo.yml', ['Metrics/LineLength:',
                                          '  Enabled: false'])
        create_file('.rubocop.yml', ['inherit_from: .rubocop_todo.yml'])
        expect(cli.run(['--auto-gen-config'])).to eq(1)
        expect(IO.readlines('.rubocop_todo.yml')[8..-1].map(&:chomp))
          .to eq(['# Offense count: 1',
                  '# Configuration parameters: AllowHeredoc, AllowURI, ' \
                  'URISchemes.',
                  '# URISchemes: http, https',
                  'Metrics/LineLength:',
                  '  Max: 85',
                  '',
                  '# Offense count: 1',
                  '# Cop supports --auto-correct.',
                  '# Configuration parameters: AllowForAlignment.',
                  'Style/SpaceAroundOperators:',
                  '  Exclude:',
                  "    - 'example1.rb'",
                  '',
                  '# Offense count: 2',
                  '# Cop supports --auto-correct.',
                  'Style/TrailingWhitespace:',
                  '  Exclude:',
                  "    - 'example1.rb'"])

        # Create new CLI instance to avoid using cached configuration.
        new_cli = described_class.new

        expect(new_cli.run(['example1.rb'])).to eq(0)
      end

      it 'honors rubocop:disable comments' do
        create_file('example1.rb', ['# encoding: utf-8',
                                    '#' * 81,
                                    '# rubocop:disable LineLength',
                                    '#' * 85,
                                    'y ',
                                    'puts 123456'])
        create_file('.rubocop.yml', ['inherit_from: .rubocop_todo.yml'])
        expect(cli.run(['--auto-gen-config'])).to eq(1)
        expect(IO.readlines('.rubocop_todo.yml')[8..-1].join)
          .to eq(['# Offense count: 1',
                  '# Configuration parameters: AllowHeredoc, AllowURI, ' \
                  'URISchemes.',
                  '# URISchemes: http, https',
                  'Metrics/LineLength:',
                  '  Max: 81',
                  '',
                  '# Offense count: 1',
                  '# Cop supports --auto-correct.',
                  'Style/NumericLiterals:',
                  '  MinDigits: 7',
                  '',
                  '# Offense count: 1',
                  '# Cop supports --auto-correct.',
                  'Style/TrailingWhitespace:',
                  '  Exclude:',
                  "    - 'example1.rb'",
                  ''].join("\n"))
      end

      it 'can generate a todo list' do
        create_file('example1.rb', ['# encoding: utf-8',
                                    '$x= 0 ',
                                    '#' * 90,
                                    '#' * 85,
                                    'y ',
                                    'puts x'])
        create_file('example2.rb', ['# encoding: utf-8',
                                    "\tx = 0",
                                    'puts x',
                                    '',
                                    'class A',
                                    '  def a',
                                    '  end',
                                    'end'])
        # Make ConfigLoader reload the default configuration so that its
        # absolute Exclude paths will point into this example's work directory.
        RuboCop::ConfigLoader.default_configuration = nil

        expect(cli.run(['--auto-gen-config'])).to eq(1)
        expect($stderr.string).to eq('')
        expect($stdout.string)
          .to include(['Created .rubocop_todo.yml.',
                       'Run `rubocop --config .rubocop_todo.yml`, or ' \
                       'add `inherit_from: .rubocop_todo.yml` in a ' \
                       '.rubocop.yml file.',
                       ''].join("\n"))
        expected =
          ['# This configuration was generated by',
           '# `rubocop --auto-gen-config`',
           /# on .* using RuboCop version .*/,
           '# The point is for the user to remove these configuration records',
           '# one by one as the offenses are removed from the code base.',
           '# Note that changes in the inspected code, or installation of new',
           '# versions of RuboCop, may require this file to be generated ' \
           'again.',
           '',
           '# Offense count: 2',
           '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes.',
           '# URISchemes: http, https',
           'Metrics/LineLength:',
           '  Max: 90',
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/CommentIndentation:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           'Style/Documentation:',
           '  Exclude:',
           "    - 'spec/**/*'", # Copied from default configuration
           "    - 'test/**/*'", # Copied from default configuration
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Configuration parameters: AllowedVariables.',
           'Style/GlobalVars:',
           '  Exclude:',
           "    - 'example1.rb'",
           '',
           '# Offense count: 2',
           '# Cop supports --auto-correct.',
           '# Configuration parameters: EnforcedStyle, SupportedStyles.',
           '# SupportedStyles: normal, rails',
           'Style/IndentationConsistency:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/InitialIndentation:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           '# Configuration parameters: AllowForAlignment.',
           'Style/SpaceAroundOperators:',
           '  Exclude:',
           "    - 'example1.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/Tab:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 2',
           '# Cop supports --auto-correct.',
           'Style/TrailingWhitespace:',
           '  Exclude:',
           "    - 'example1.rb'"]
        actual = IO.read('.rubocop_todo.yml').split($RS)
        expected.each_with_index do |line, ix|
          if line.is_a?(String)
            expect(actual[ix]).to eq(line)
          else
            expect(actual[ix]).to match(line)
          end
        end
      end

      it 'can generate Exclude properties with a given limit' do
        create_file('example1.rb', ['# encoding: utf-8',
                                    '$x= 0 ',
                                    '#' * 90,
                                    '#' * 85,
                                    'y ',
                                    'puts x'])
        create_file('example2.rb', ['# encoding: utf-8',
                                    '#' * 85,
                                    "\tx = 0",
                                    'puts x'])
        expect(cli.run(['--auto-gen-config', '--exclude-limit', '1'])).to eq(1)
        expected =
          ['# This configuration was generated by',
           '# `rubocop --auto-gen-config --exclude-limit 1`',
           /# on .* using RuboCop version .*/,
           '# The point is for the user to remove these configuration records',
           '# one by one as the offenses are removed from the code base.',
           '# Note that changes in the inspected code, or installation of new',
           '# versions of RuboCop, may require this file to be generated ' \
           'again.',
           '',
           '# Offense count: 3',
           '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes.',
           '# URISchemes: http, https',
           'Metrics/LineLength:',
           '  Max: 90', # Offense occurs in 2 files, limit is 1, so no Exclude.
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/CommentIndentation:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Configuration parameters: AllowedVariables.',
           'Style/GlobalVars:',
           '  Exclude:',
           "    - 'example1.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           '# Configuration parameters: EnforcedStyle, SupportedStyles.',
           '# SupportedStyles: normal, rails',
           'Style/IndentationConsistency:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/InitialIndentation:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           '# Configuration parameters: AllowForAlignment.',
           'Style/SpaceAroundOperators:',
           '  Exclude:',
           "    - 'example1.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/Tab:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 2',
           '# Cop supports --auto-correct.',
           'Style/TrailingWhitespace:',
           '  Exclude:',
           "    - 'example1.rb'"]
        actual = IO.read('.rubocop_todo.yml').split($RS)
        expected.each_with_index do |line, ix|
          if line.is_a?(String)
            expect(actual[ix]).to eq(line)
          else
            expect(actual[ix]).to match(line)
          end
        end
      end

      it 'does not generate configuration for the Syntax cop' do
        create_file('example1.rb', ['# encoding: utf-8',
                                    'x = < ', # Syntax error
                                    'puts x'])
        create_file('example2.rb', ['# encoding: utf-8',
                                    "\tx = 0",
                                    'puts x'])
        expect(cli.run(['--auto-gen-config'])).to eq(1)
        expect($stderr.string).to eq('')
        expected =
          ['# This configuration was generated by',
           '# `rubocop --auto-gen-config`',
           /# on .* using RuboCop version .*/,
           '# The point is for the user to remove these configuration records',
           '# one by one as the offenses are removed from the code base.',
           '# Note that changes in the inspected code, or installation of new',
           '# versions of RuboCop, may require this file to be generated ' \
           'again.',
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/CommentIndentation:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           '# Configuration parameters: EnforcedStyle, SupportedStyles.',
           '# SupportedStyles: normal, rails',
           'Style/IndentationConsistency:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/InitialIndentation:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           'Style/Tab:',
           '  Exclude:',
           "    - 'example2.rb'"]
        actual = IO.read('.rubocop_todo.yml').split($RS)
        expect(actual.length).to eq(expected.length)
        expected.each_with_index do |line, ix|
          if line.is_a?(String)
            expect(actual[ix]).to eq(line)
          else
            expect(actual[ix]).to match(line)
          end
        end
      end

      it 'generates a todo list that removes the reports' do
        create_file('example.rb', ['# encoding: utf-8',
                                   'y.gsub!(/abc\/xyz/, x)'])
        expect(cli.run(%w(--format emacs))).to eq(1)
        expect($stdout.string).to eq("#{abs('example.rb')}:2:9: C: Use `%r` " \
                                     "around regular expression.\n")
        expect(cli.run(['--auto-gen-config'])).to eq(1)
        expected =
          ['# This configuration was generated by',
           '# `rubocop --auto-gen-config`',
           /# on .* using RuboCop version .*/,
           '# The point is for the user to remove these configuration records',
           '# one by one as the offenses are removed from the code base.',
           '# Note that changes in the inspected code, or installation of new',
           '# versions of RuboCop, may require this file to be generated ' \
           'again.',
           '',
           '# Offense count: 1',
           '# Cop supports --auto-correct.',
           '# Configuration parameters: EnforcedStyle, SupportedStyles, ' \
           'AllowInnerSlashes.',
           '# SupportedStyles: slashes, percent_r, mixed',
           'Style/RegexpLiteral:',
           '  Exclude:',
           "    - 'example.rb'"]
        actual = IO.read('.rubocop_todo.yml').split($RS)
        expected.each_with_index do |line, ix|
          if line.is_a?(String)
            expect(actual[ix]).to eq(line)
          else
            expect(actual[ix]).to match(line)
          end
        end
        $stdout = StringIO.new
        result = cli.run(%w(--config .rubocop_todo.yml --format emacs))
        expect($stdout.string).to eq('')
        expect(result).to eq(0)
      end

      it 'does not include offense counts when --no-offense-counts is used' do
        create_file('example1.rb', ['# encoding: utf-8',
                                    '$x= 0 ',
                                    '#' * 90,
                                    '#' * 85,
                                    'y ',
                                    'puts x'])
        create_file('example2.rb', ['# encoding: utf-8',
                                    "\tx = 0",
                                    'puts x',
                                    '',
                                    'class A',
                                    '  def a',
                                    '  end',
                                    'end'])
        # Make ConfigLoader reload the default configuration so that its
        # absolute Exclude paths will point into this example's work directory.
        RuboCop::ConfigLoader.default_configuration = nil

        expect(cli.run(['--auto-gen-config', '--no-offense-counts'])).to eq(1)
        expect($stderr.string).to eq('')
        expect($stdout.string)
          .to include(['Created .rubocop_todo.yml.',
                       'Run `rubocop --config .rubocop_todo.yml`, or ' \
                       'add `inherit_from: .rubocop_todo.yml` in a ' \
                       '.rubocop.yml file.',
                       ''].join("\n"))
        expected =
          ['# This configuration was generated by',
           '# `rubocop --auto-gen-config`',
           /# on .* using RuboCop version .*/,
           '# The point is for the user to remove these configuration records',
           '# one by one as the offenses are removed from the code base.',
           '# Note that changes in the inspected code, or installation of new',
           '# versions of RuboCop, may require this file to be generated ' \
           'again.',
           '',
           '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes.',
           '# URISchemes: http, https',
           'Metrics/LineLength:',
           '  Max: 90',
           '',
           '# Cop supports --auto-correct.',
           'Style/CommentIndentation:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           'Style/Documentation:',
           '  Exclude:',
           "    - 'spec/**/*'", # Copied from default configuration
           "    - 'test/**/*'", # Copied from default configuration
           "    - 'example2.rb'",
           '',
           '# Configuration parameters: AllowedVariables.',
           'Style/GlobalVars:',
           '  Exclude:',
           "    - 'example1.rb'",
           '',
           '# Cop supports --auto-correct.',
           '# Configuration parameters: EnforcedStyle, SupportedStyles.',
           '# SupportedStyles: normal, rails',
           'Style/IndentationConsistency:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Cop supports --auto-correct.',
           'Style/InitialIndentation:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Cop supports --auto-correct.',
           '# Configuration parameters: AllowForAlignment.',
           'Style/SpaceAroundOperators:',
           '  Exclude:',
           "    - 'example1.rb'",
           '',
           '# Cop supports --auto-correct.',
           'Style/Tab:',
           '  Exclude:',
           "    - 'example2.rb'",
           '',
           '# Cop supports --auto-correct.',
           'Style/TrailingWhitespace:',
           '  Exclude:',
           "    - 'example1.rb'"]
        actual = IO.read('.rubocop_todo.yml').split($RS)
        expected.each_with_index do |line, ix|
          if line.is_a?(String)
            expect(actual[ix]).to eq(line)
          else
            expect(actual[ix]).to match(line)
          end
        end
      end
    end

    describe '--only' do
      context 'when one cop is given' do
        it 'runs just one cop' do
          # The disable comment should not be reported as unnecessary (even if
          # it is) since --only overrides configuration.
          create_file('example.rb', ['# rubocop:disable LineLength',
                                     'if x== 0 ',
                                     "\ty",
                                     'end'])
          # IfUnlessModifier depends on the configuration of LineLength.

          expect(cli.run(['--format', 'simple',
                          '--only', 'Style/IfUnlessModifier',
                          'example.rb'])).to eq(1)
          expect($stdout.string)
            .to eq(['== example.rb ==',
                    'C:  2:  1: Favor modifier if usage when ' \
                    'having a single-line body. Another good alternative is ' \
                    'the usage of control flow &&/||.',
                    '',
                    '1 file inspected, 1 offense detected',
                    ''].join("\n"))
        end

        it 'exits with error if an incorrect cop name is passed' do
          create_file('example.rb', ['if x== 0 ',
                                     "\ty",
                                     'end'])
          expect(cli.run(['--only', 'Style/123'])).to eq(1)
          expect($stderr.string)
            .to include('Unrecognized cop or namespace: Style/123.')
        end

        it 'exits with error if an empty string is given' do
          create_file('example.rb', 'x')
          expect(cli.run(['--only', ''])).to eq(1)
          expect($stderr.string).to include('Unrecognized cop or namespace: .')
        end

        %w(Syntax Lint/Syntax).each do |name|
          it "only checks syntax if #{name} is given" do
            create_file('example.rb', 'x ')
            expect(cli.run(['--only', name])).to eq(0)
            expect($stdout.string).to include('no offenses detected')
          end
        end

        %w(Lint/UnneededDisable UnneededDisable).each do |name|
          it "exits with error if cop name #{name} is passed" do
            create_file('example.rb', ['if x== 0 ',
                                       "\ty",
                                       'end'])
            expect(cli.run(['--only', 'UnneededDisable'])).to eq(1)
            expect($stderr.string)
              .to include('Lint/UnneededDisable can not be used with --only.')
          end
        end

        it 'accepts cop names from plugins' do
          create_file('.rubocop.yml', ['require: rubocop_ext',
                                       '',
                                       'Style/SomeCop:',
                                       '  Description: Something',
                                       '  Enabled: true'])
          create_file('rubocop_ext.rb', ['module RuboCop',
                                         '  module Cop',
                                         '    module Style',
                                         '      class SomeCop < Cop',
                                         '      end',
                                         '    end',
                                         '  end',
                                         'end'])
          create_file('redirect.rb', '$stderr = STDOUT')
          rubocop = "#{RuboCop::ConfigLoader::RUBOCOP_HOME}/bin/rubocop"
          # Since we define a new cop class, we have to do this in a separate
          # process. Otherwise, the extra cop will affect other specs.
          output =
            `ruby -I . #{rubocop} --require redirect.rb --only Style/SomeCop`
          expect($CHILD_STATUS.success?).to be_truthy
          # The warning about the unrecognized cop is expected. It's given due
          # to the fact that we haven't supplied any default configuration for
          # rubocop_ext in this example.
          expect(output)
            .to eq(['Inspecting 2 files',
                    '..',
                    '',
                    '2 files inspected, no offenses detected',
                    ''].join("\n"))
        end

        context 'without using namespace' do
          it 'runs just one cop' do
            create_file('example.rb', ['if x== 0 ',
                                       "\ty",
                                       'end'])

            expect(cli.run(['--format', 'simple',
                            '--display-cop-names',
                            '--only', 'IfUnlessModifier',
                            'example.rb'])).to eq(1)
            expect($stdout.string)
              .to eq(['== example.rb ==',
                      'C:  1:  1: Style/IfUnlessModifier: Favor modifier if ' \
                      'usage when having a single-line body. Another good ' \
                      'alternative is the usage of control flow &&/||.',
                      '',
                      '1 file inspected, 1 offense detected',
                      ''].join("\n"))
          end
        end

        it 'enables the given cop' do
          create_file('example.rb',
                      ['x = 0 ',
                       # Disabling comments still apply.
                       '# rubocop:disable Style/TrailingWhitespace',
                       'y = 1  '])

          create_file('.rubocop.yml', ['Style/TrailingWhitespace:',
                                       '  Enabled: false'])

          expect(cli.run(['--format', 'simple',
                          '--only', 'Style/TrailingWhitespace',
                          'example.rb'])).to eq(1)
          expect($stderr.string).to eq('')
          expect($stdout.string)
            .to eq(['== example.rb ==',
                    'C:  1:  6: Trailing whitespace detected.',
                    '',
                    '1 file inspected, 1 offense detected',
                    ''].join("\n"))
        end
      end

      context 'when several cops are given' do
        it 'runs the given cops' do
          create_file('example.rb', ['if x== 100000000000000 ',
                                     "\ty",
                                     'end'])
          expect(cli.run(['--format', 'simple',
                          '--only',
                          'Style/IfUnlessModifier,Style/Tab,' \
                          'Style/SpaceAroundOperators',
                          'example.rb'])).to eq(1)
          expect($stderr.string).to eq('')
          expect($stdout.string)
            .to eq(['== example.rb ==',
                    'C:  1:  1: Favor modifier if usage when ' \
                    'having a single-line body. Another good alternative is ' \
                    'the usage of control flow &&/||.',
                    'C:  1:  5: Surrounding space missing for operator ==.',
                    'C:  2:  1: Tab detected.',
                    '',
                    '1 file inspected, 3 offenses detected',
                    ''].join("\n"))
        end

        context 'and --lint' do
          it 'runs the given cops plus all enabled lint cops' do
            create_file('example.rb', ['if x== 100000000000000 ',
                                       "\ty = 3",
                                       '  end'])
            create_file('.rubocop.yml', ['Lint/EndAlignment:',
                                         '  Enabled: false'])
            expect(cli.run(['--format', 'simple',
                            '--only', 'Style/Tab,Style/SpaceAroundOperators',
                            '--lint',
                            'example.rb'])).to eq(1)
            expect($stdout.string)
              .to eq(['== example.rb ==',
                      'C:  1:  5: Surrounding space missing for operator ==.',
                      'C:  2:  1: Tab detected.',
                      'W:  2:  2: Useless assignment to variable - y.',
                      '',
                      '1 file inspected, 3 offenses detected',
                      ''].join("\n"))
          end
        end
      end

      context 'when a namespace is given' do
        it 'runs all enabled cops in that namespace' do
          create_file('example.rb', ['if x== 100000000000000 ',
                                     '  ' + '#' * 100,
                                     "\ty",
                                     'end'])
          expect(cli.run(%w(-f offenses --only Metrics example.rb))).to eq(1)
          expect($stdout.string).to eq(['',
                                        '1  Metrics/LineLength',
                                        '--',
                                        '1  Total',
                                        '',
                                        ''].join("\n"))
        end
      end

      context 'when two namespaces are given' do
        it 'runs all enabled cops in those namespaces' do
          create_file('example.rb', ['# encoding: utf-8',
                                     'if x== 100000000000000 ',
                                     '  # ' + '-' * 98,
                                     "\ty",
                                     'end'])
          create_file('.rubocop.yml', ['Style/SpaceAroundOperators:',
                                       '  Enabled: false'])
          expect(cli.run(%w(-f o --only Metrics,Style example.rb))).to eq(1)
          expect($stdout.string)
            .to eq(['',
                    '1  Metrics/LineLength',
                    '1  Style/CommentIndentation',
                    '1  Style/IndentationWidth',
                    '1  Style/NumericLiterals',
                    '1  Style/Tab',
                    '1  Style/TrailingWhitespace',
                    '--',
                    '6  Total',
                    '',
                    ''].join("\n"))
        end
      end
    end

    describe '--except' do
      context 'when one name is given' do
        it 'exits with error if the cop name is incorrect' do
          create_file('example.rb', ['if x== 0 ',
                                     "\ty",
                                     'end'])
          expect(cli.run(['--except', 'Style/123'])).to eq(1)
          expect($stderr.string)
            .to include('Unrecognized cop or namespace: Style/123.')
        end

        it 'exits with error if an empty string is given' do
          create_file('example.rb', 'x')
          expect(cli.run(['--except', ''])).to eq(1)
          expect($stderr.string).to include('Unrecognized cop or namespace: .')
        end

        %w(Syntax Lint/Syntax).each do |name|
          it "exits with error if #{name} is given" do
            create_file('example.rb', 'x ')
            expect(cli.run(['--except', name])).to eq(1)
            expect($stderr.string)
              .to include('Syntax checking can not be turned off.')
          end
        end
      end

      context 'when one cop plus one namespace are given' do
        it 'runs all cops except the given' do
          # The disable comment should not be reported as unnecessary (even if
          # it is) since --except overrides configuration.
          create_file('example.rb', ['# rubocop:disable LineLength',
                                     'if x== 0 ',
                                     "\ty = 3",
                                     'end'])
          expect(cli.run(['--format', 'offenses',
                          '--except', 'Style/IfUnlessModifier,Lint',
                          'example.rb'])).to eq(1)
          expect($stdout.string)
            .to eq(['',
                    # Note: No Lint/UselessAssignment offense.
                    '1  Style/IndentationWidth',
                    '1  Style/SpaceAroundOperators',
                    '1  Style/Tab',
                    '1  Style/TrailingWhitespace',
                    '--',
                    '4  Total',
                    '',
                    ''].join("\n"))
        end
      end

      context 'when one cop is given without namespace' do
        it 'disables the given cop' do
          create_file('example.rb', ['if x== 0 ',
                                     "\ty",
                                     'end'])

          cli.run(['--format', 'offenses',
                   '--except', 'IfUnlessModifier',
                   'example.rb'])
          with_option = $stdout.string
          $stdout = StringIO.new
          cli.run(['--format', 'offenses',
                   'example.rb'])
          without_option = $stdout.string

          expect(without_option.split($RS) - with_option.split($RS))
            .to eq(['1  Style/IfUnlessModifier', '5  Total'])
        end
      end

      context 'when several cops are given' do
        %w(UnneededDisable Lint/UnneededDisable Lint).each do |cop_name|
          it "disables the given cops including #{cop_name}" do
            create_file('example.rb', ['if x== 100000000000000 ',
                                       "\ty",
                                       'end # rubocop:disable all'])
            expect(cli.run(['--format', 'offenses',
                            '--except',
                            'Style/IfUnlessModifier,Style/Tab,' \
                            "Style/SpaceAroundOperators,#{cop_name}",
                            'example.rb'])).to eq(1)
            expect($stderr.string).to eq('')
            expect($stdout.string)
              .to eq(['',
                      '1  Style/IndentationWidth',
                      '1  Style/NumericLiterals',
                      '1  Style/TrailingWhitespace',
                      '--',
                      '3  Total',
                      '',
                      ''].join("\n"))
          end
        end
      end
    end

    describe '--lint' do
      it 'runs only lint cops' do
        create_file('example.rb', ['if 0 ',
                                   "\ty",
                                   "\tz # rubocop:disable Style/Tab",
                                   'end'])
        # IfUnlessModifier depends on the configuration of LineLength.

        expect(cli.run(['--format', 'simple', '--lint',
                        'example.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(['== example.rb ==',
                  'W:  1:  4: Literal 0 appeared in a condition.',
                  '',
                  '1 file inspected, 1 offense detected',
                  ''].join("\n"))
      end
    end

    describe '-d/--debug' do
      it 'shows config files' do
        create_file('example1.rb', "\tputs 0")
        expect(cli.run(['--debug', 'example1.rb'])).to eq(1)
        home = File.dirname(File.dirname(File.dirname(__FILE__)))
        expect($stdout.string.lines.grep(/configuration/).map(&:chomp))
          .to eq(["For #{abs('')}:" \
                  " configuration from #{home}/config/default.yml",
                  "Inheriting configuration from #{home}/config/enabled.yml",
                  "Inheriting configuration from #{home}/config/disabled.yml"
                 ])
      end

      it 'shows cop names' do
        create_file('example1.rb', 'puts 0 ')
        file = abs('example1.rb')

        expect(cli.run(['--format',
                        'emacs',
                        '--debug',
                        'example1.rb'])).to eq(1)
        expect($stdout.string.lines.to_a[-1])
          .to eq("#{file}:1:7: C: Style/TrailingWhitespace: Trailing " \
                 "whitespace detected.\n")
      end
    end

    describe '-D/--display-cop-names' do
      it 'shows cop names' do
        create_file('example1.rb', 'puts 0 # rubocop:disable NumericLiterals ')
        file = abs('example1.rb')

        expect(cli.run(['--format', 'emacs', '--display-cop-names',
                        'example1.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(["#{file}:1:8: W: Lint/UnneededDisable: Unnecessary " \
                  'disabling of `Style/NumericLiterals`.',
                  "#{file}:1:41: C: Style/TrailingWhitespace: Trailing " \
                  'whitespace detected.',
                  ''].join("\n"))
      end
    end

    describe '-E/--extra-details' do
      it 'shows extra details' do
        create_file('example1.rb', 'puts 0 # rubocop:disable NumericLiterals ')
        create_file('.rubocop.yml',
                    ['TrailingWhitespace:',
                     '  Details: Trailing space is just sloppy.'])
        file = abs('example1.rb')

        expect(cli.run(['--format', 'emacs', '--extra-details',
                        'example1.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(["#{file}:1:8: W: Unnecessary disabling of " \
                  '`Style/NumericLiterals`. ',
                  "#{file}:1:41: C: Trailing " \
                  'whitespace detected. Trailing space is just sloppy.',
                  ''].join("\n"))

        expect($stderr.string).to eq('')
      end
    end

    describe '-S/--display-style-guide' do
      it 'shows style guide entry' do
        create_file('example1.rb', 'puts 0 ')
        file = abs('example1.rb')
        url =
          'https://github.com/bbatsov/ruby-style-guide#no-trailing-whitespace'

        expect(cli.run(['--format',
                        'emacs',
                        '--display-style-guide',
                        'example1.rb'])).to eq(1)
        expect($stdout.string.lines.to_a[-1])
          .to eq("#{file}:1:7: C: Trailing whitespace detected. (#{url})\n")
      end

      it 'shows reference entry' do
        create_file('example1.rb', '[1, 2, 3].reverse.each { |e| puts e }')
        file = abs('example1.rb')
        url = 'https://github.com/JuanitoFatas/fast-ruby' \
              '#enumerablereverseeach-vs-enumerablereverse_each-code'

        expect(cli.run(['--format',
                        'emacs',
                        '--display-style-guide',
                        'example1.rb'])).to eq(1)

        output = "#{file}:1:11: C: " \
                 "Use `reverse_each` instead of `reverse.each`. (#{url})"
        expect($stdout.string.lines.to_a[-1])
          .to eq([output, ''].join("\n"))
      end

      it 'shows style guide and reference entries' do
        create_file('example1.rb', '$foo = 1')
        file = abs('example1.rb')
        style_guide_link = 'https://github.com/bbatsov/ruby-style-guide' \
                           '#instance-vars'
        reference_link = 'http://www.zenspider.com/Languages/Ruby/QuickRef.html'

        expect(cli.run(['--format',
                        'emacs',
                        '--display-style-guide',
                        'example1.rb'])).to eq(1)

        output = "#{file}:1:1: C: " \
                 'Do not introduce global variables. ' \
                 "(#{style_guide_link}, #{reference_link})"
        expect($stdout.string.lines.to_a[-1])
          .to eq([output, ''].join("\n"))
      end
    end

    describe '--show-cops' do
      shared_examples(:prints_config) do
        it 'prints the current configuration' do
          out = stdout.lines.to_a
          printed_config = YAML.load(out.join)
          cop_names = (cop_list[0] || '').split(',')
          cop_names.each do |cop_name|
            global_conf[cop_name].each do |key, value|
              printed_value = printed_config[cop_name][key]
              expect(printed_value).to eq(value)
            end
          end
        end
      end

      let(:cops) { RuboCop::Cop::Cop.all }

      let(:global_conf) do
        config_path =
          RuboCop::ConfigLoader.configuration_file_for(Dir.pwd.to_s)
        RuboCop::ConfigLoader.configuration_from_file(config_path)
      end

      let(:stdout) { $stdout.string }

      before do
        create_file('.rubocop.yml', ['Metrics/LineLength:',
                                     '  Max: 110'])
        expect(cli.run(['--show-cops'] + cop_list)).to eq(0)
      end

      context 'with no args' do
        let(:cop_list) { [] }

        # Extracts the first line out of the description
        def short_description_of_cop(cop)
          desc = full_description_of_cop(cop)
          desc ? desc.lines.first.strip : ''
        end

        # Gets the full description of the cop or nil if no description is set.
        def full_description_of_cop(cop)
          cop_config = global_conf.for_cop(cop)
          cop_config['Description']
        end

        it 'prints all available cops and their description' do
          cops.each do |cop|
            expect(stdout).to include cop.cop_name
            # Because of line breaks, we will only find the beginning.
            expect(stdout).to include short_description_of_cop(cop)[0..60]
          end
        end

        it 'prints all types' do
          cops
            .types
            .map(&:to_s)
            .map(&:capitalize)
            .each { |type| expect(stdout).to include(type) }
        end

        it 'prints all cops in their right type listing' do
          lines = stdout.lines
          lines.slice_before(/Type /).each do |slice|
            types = cops.types.map(&:to_s).map(&:capitalize)
            current = types.delete(slice.shift[/Type '(?<c>[^']+)'/, 'c'])
            # all cops in their type listing
            cops.with_type(current).each do |cop|
              expect(slice.any? { |l| l.include? cop.cop_name }).to be_truthy
            end

            # no cop in wrong type listing
            types.each do |type|
              cops.with_type(type).each do |cop|
                expect(slice.any? { |l| l.include? cop.cop_name }).to be_falsey
              end
            end
          end
        end

        include_examples :prints_config
      end

      context 'with one cop given' do
        let(:cop_list) { ['Style/Tab'] }

        it 'prints that cop and nothing else' do
          expect(stdout).to eq(
            ['# Supports --auto-correct',
             'Style/Tab:',
             '  Description: No hard tabs.',
             '  StyleGuide: ' \
             'https://github.com/bbatsov/ruby-style-guide#spaces-indentation',
             '  Enabled: true',
             '',
             ''].join("\n"))
        end

        include_examples :prints_config
      end

      context 'with two cops given' do
        let(:cop_list) { ['Style/Tab,Metrics/LineLength'] }
        include_examples :prints_config
      end

      context 'with one of the cops misspelled' do
        let(:cop_list) { ['Style/Tab,Lint/X123'] }

        it 'skips the unknown cop' do
          expect(stdout).to eq(
            ['# Supports --auto-correct',
             'Style/Tab:',
             '  Description: No hard tabs.',
             '  StyleGuide: ' \
             'https://github.com/bbatsov/ruby-style-guide#spaces-indentation',
             '  Enabled: true',
             '',
             ''].join("\n"))
        end
      end
    end

    describe '-f/--format' do
      let(:target_file) { 'example.rb' }

      before do
        create_file(target_file, ['# encoding: utf-8',
                                  '#' * 90])
      end

      describe 'builtin formatters' do
        context 'when simple format is specified' do
          it 'outputs with simple format' do
            cli.run(['--format', 'simple', 'example.rb'])
            expect($stdout.string)
              .to include(["== #{target_file} ==",
                           'C:  2: 81: Line is too long. [90/80]'].join("\n"))
          end
        end

        context 'when clang format is specified' do
          it 'outputs with clang format' do
            create_file('example1.rb', ['# encoding: utf-8',
                                        'x= 0 ',
                                        '#' * 85,
                                        'y ',
                                        'puts x'])
            create_file('example2.rb', ['# encoding: utf-8',
                                        "\tx",
                                        'def a',
                                        '   puts',
                                        'end'])
            create_file('example3.rb', ['# encoding: utf-8',
                                        'def badName',
                                        '  if something',
                                        '    test',
                                        '    end',
                                        'end'])
            expect(cli.run(['--format', 'clang', 'example1.rb',
                            'example2.rb', 'example3.rb']))
              .to eq(1)
            expect($stdout.string)
              .to eq(['example1.rb:2:2: C: Surrounding space missing for ' \
                      'operator =.',
                      'x= 0 ',
                      ' ^',
                      'example1.rb:2:5: C: Trailing whitespace detected.',
                      'x= 0 ',
                      '    ^',
                      'example1.rb:3:81: C: Line is too long. [85/80]',
                      '###################################################' \
                      '##################################',
                      '                                                   ' \
                      '                             ^^^^^',
                      'example1.rb:4:2: C: Trailing whitespace detected.',
                      'y ',
                      ' ^',
                      'example2.rb:1:1: C: Incorrect indentation detected' \
                      ' (column 0 instead of 1).',
                      '# encoding: utf-8',
                      '^^^^^^^^^^^^^^^^^',
                      'example2.rb:2:1: C: Tab detected.',
                      "\tx",
                      '^',
                      'example2.rb:2:2: C: Indentation of first line in file ' \
                      'detected.',
                      '	x',
                      ' ^',
                      'example2.rb:3:1: C: Inconsistent indentation ' \
                      'detected.',
                      'def a',
                      '^^^^^',
                      'example2.rb:4:1: C: Use 2 (not 3) spaces for ' \
                      'indentation.',
                      '   puts',
                      '^^^',
                      'example3.rb:2:5: C: Use snake_case for method names.',
                      'def badName',
                      '    ^^^^^^^',
                      'example3.rb:3:3: C: Use a guard clause instead of ' \
                      'wrapping the code inside a conditional expression.',
                      '  if something',
                      '  ^^',
                      'example3.rb:3:3: C: Favor modifier if usage ' \
                      'when having a single-line body. Another good ' \
                      'alternative is the usage of control flow &&/||.',
                      '  if something',
                      '  ^^',
                      'example3.rb:5:5: W: end at 5, 4 is not aligned ' \
                      'with if at 3, 2.',
                      '    end',
                      '    ^^^',
                      '',
                      '3 files inspected, 13 offenses detected',
                      ''].join("\n"))
          end
        end

        context 'when emacs format is specified' do
          it 'outputs with emacs format' do
            create_file('example1.rb', ['# encoding: utf-8',
                                        'x= 0 ',
                                        'y ',
                                        'puts x'])
            create_file('example2.rb', ['# encoding: utf-8',
                                        "\tx = 0",
                                        'puts x'])
            expect(cli.run(['--format', 'emacs', 'example1.rb',
                            'example2.rb'])).to eq(1)
            expected_output =
              ["#{abs('example1.rb')}:2:2: C: Surrounding space missing" \
               ' for operator `=`.',
               "#{abs('example1.rb')}:2:5: C: Trailing whitespace detected.",
               "#{abs('example1.rb')}:3:2: C: Trailing whitespace detected.",
               "#{abs('example2.rb')}:1:1: C: Incorrect indentation detected" \
               ' (column 0 instead of 1).',
               "#{abs('example2.rb')}:2:1: C: Tab detected.",
               "#{abs('example2.rb')}:2:2: C: Indentation of first line in " \
               'file detected.',
               "#{abs('example2.rb')}:3:1: C: Inconsistent indentation " \
               'detected.',
               ''].join("\n")
            expect($stdout.string).to eq(expected_output)
          end
        end

        context 'when unknown format name is specified' do
          it 'aborts with error message' do
            expect(cli.run(['--format', 'unknown', 'example.rb'])).to eq(1)
            expect($stderr.string)
              .to include('No formatter for "unknown"')
          end
        end

        context 'when ambiguous format name is specified' do
          it 'aborts with error message' do
            # Both 'files' and 'fuubar' start with an 'f'.
            expect(cli.run(['--format', 'f', 'example.rb'])).to eq(1)
            expect($stderr.string)
              .to include('Cannot determine formatter for "f"')
          end
        end
      end

      describe 'custom formatter' do
        let(:target_file) { abs('example.rb') }

        context 'when a class name is specified' do
          it 'uses the class as a formatter' do
            module MyTool
              class RuboCopFormatter < RuboCop::Formatter::BaseFormatter
                def started(all_files)
                  output.puts "started: #{all_files.join(',')}"
                end

                def file_started(file, _options)
                  output.puts "file_started: #{file}"
                end

                def file_finished(file, _offenses)
                  output.puts "file_finished: #{file}"
                end

                def finished(processed_files)
                  output.puts "finished: #{processed_files.join(',')}"
                end
              end
            end

            cli.run(['--format', 'MyTool::RuboCopFormatter', 'example.rb'])
            expect($stdout.string).to eq(["started: #{target_file}",
                                          "file_started: #{target_file}",
                                          "file_finished: #{target_file}",
                                          "finished: #{target_file}",
                                          ''].join("\n"))
          end
        end

        context 'when unknown class name is specified' do
          it 'aborts with error message' do
            args = '--format UnknownFormatter example.rb'
            expect(cli.run(args.split)).to eq(1)
            expect($stderr.string).to include('UnknownFormatter')
          end
        end
      end

      it 'can be used multiple times' do
        cli.run(['--format', 'simple', '--format', 'emacs', 'example.rb'])
        expect($stdout.string)
          .to include(["== #{target_file} ==",
                       'C:  2: 81: Line is too long. [90/80]',
                       "#{abs(target_file)}:2:81: C: Line is too long. " \
                       '[90/80]'].join("\n"))
      end
    end

    describe '-o/--out option' do
      let(:target_file) { 'example.rb' }

      before do
        create_file(target_file, ['# encoding: utf-8',
                                  '#' * 90])
      end

      it 'redirects output to the specified file' do
        cli.run(['--out', 'output.txt', target_file])
        expect(File.read('output.txt')).to include('Line is too long.')
      end

      it 'is applied to the previously specified formatter' do
        cli.run(['--format', 'simple',
                 '--format', 'emacs', '--out', 'emacs_output.txt',
                 target_file])

        expect($stdout.string).to eq(["== #{target_file} ==",
                                      'C:  2: 81: Line is too long. [90/80]',
                                      '',
                                      '1 file inspected, 1 offense detected',
                                      ''].join("\n"))

        expect(File.read('emacs_output.txt'))
          .to eq(["#{abs(target_file)}:2:81: C: Line is too long. [90/80]",
                  ''].join("\n"))
      end
    end

    describe '--fail-level option' do
      let(:target_file) { 'example.rb' }

      before do
        create_file(target_file, ['# encoding: utf-8',
                                  'def f',
                                  ' x',
                                  'end'])
      end

      after do
        expect($stderr.string).to eq('')
        expect($stdout.string)
          .to include('1 file inspected, 1 offense detected')
      end

      it 'fails when option is less than the severity level' do
        expect(cli.run(['--fail-level', 'refactor', target_file])).to eq(1)
        expect(cli.run(['--fail-level', 'autocorrect', target_file])).to eq(1)
      end

      it 'fails when option is equal to the severity level' do
        expect(cli.run(['--fail-level', 'convention', target_file])).to eq(1)
      end

      it 'succeeds when option is greater than the severity level' do
        expect(cli.run(['--fail-level', 'warning', target_file])).to eq(0)
      end

      context 'with --auto-correct' do
        after do
          expect($stdout.string.lines.to_a.last)
            .to eq('1 file inspected, 1 offense detected, 1 offense corrected' \
                   "\n")
        end

        it 'fails when option is autocorrect and all offenses are ' \
           'autocorrected' do
          expect(cli.run(['--auto-correct', '--format', 'simple',
                          '--fail-level', 'autocorrect',
                          target_file])).to eq(1)
        end

        it 'fails when option is A and all offenses are autocorrected' do
          expect(cli.run(['--auto-correct', '--format', 'simple',
                          '--fail-level', 'A',
                          target_file])).to eq(1)
        end

        it 'succeeds when option is not given and all offenses are ' \
           'autocorrected' do
          expect(cli.run(['--auto-correct', '--format', 'simple',
                          target_file])).to eq(0)
        end

        it 'succeeds when option is refactor and all offenses are ' \
           'autocorrected' do
          expect(cli.run(['--auto-correct', '--format', 'simple',
                          '--fail-level', 'refactor',
                          target_file])).to eq(0)
        end
      end
    end

    describe 'with --auto-correct and disabled offense' do
      let(:target_file) { 'example.rb' }
      after do
        expect($stdout.string.lines.to_a.last)
          .to eq('1 file inspected, no offenses detected' \
                 "\n")
      end
      it 'succeeds when there is only a disabled offense' do
        create_file(target_file, ['# encoding: utf-8',
                                  'def f',
                                  ' x # rubocop:disable Style/IndentationWidth',
                                  'end'])

        expect(cli.run(['--auto-correct', '--format', 'simple',
                        '--fail-level', 'autocorrect',
                        target_file])).to eq(0)
      end
    end

    describe '--force-exclusion' do
      let(:target_file) { 'example.rb' }

      before do
        create_file(target_file, ['# encoding: utf-8',
                                  '#' * 90])

        create_file('.rubocop.yml', ['AllCops:',
                                     '  Exclude:',
                                     "    - #{target_file}"])
      end

      it 'excludes files specified in the configuration Exclude ' \
         'even if they are explicitly passed as arguments' do
        expect(cli.run(['--force-exclusion', target_file])).to eq(0)
      end
    end

    describe '--stdin' do
      it 'causes source code to be read from stdin' do
        begin
          $stdin = StringIO.new('p $/')
          argv   = ['--only=Style/SpecialGlobalVars',
                    '--format=simple',
                    '--stdin',
                    'fake.rb']
          expect(cli.run(argv)).to eq(1)
          expect($stdout.string).to eq([
            '== fake.rb ==',
            'C:  1:  3: Prefer $INPUT_RECORD_SEPARATOR or $RS from the ' \
            "stdlib 'English' module over $/.",
            '',
            '1 file inspected, 1 offense detected',
            ''].join("\n"))
        ensure
          $stdin = STDIN
        end
      end

      it 'requires a file path' do
        begin
          $stdin = StringIO.new('p $/')
          argv   = ['--only=Style/SpecialGlobalVars',
                    '--format=simple',
                    '--stdin']
          expect(cli.run(argv)).to eq(1)
          expect($stderr.string).to include(
            '-s/--stdin requires exactly one path.')
        ensure
          $stdin = STDIN
        end
      end

      it 'does not accept more than one file path' do
        begin
          $stdin = StringIO.new('p $/')
          argv   = ['--only=Style/SpecialGlobalVars',
                    '--format=simple',
                    '--stdin',
                    'fake1.rb',
                    'fake2.rb']
          expect(cli.run(argv)).to eq(1)
          expect($stderr.string).to include(
            '-s/--stdin requires exactly one path.')
        ensure
          $stdin = STDIN
        end
      end

      it 'prints corrected code to stdout if --autocorrect is used' do
        begin
          $stdin = StringIO.new('p $/')
          argv   = ['--auto-correct',
                    '--only=Style/SpecialGlobalVars',
                    '--format=simple',
                    '--stdin',
                    'fake.rb']
          expect(cli.run(argv)).to eq(0)
          expect($stdout.string).to eq([
            '== fake.rb ==',
            'C:  1:  3: [Corrected] Prefer $INPUT_RECORD_SEPARATOR or $RS ' \
            "from the stdlib 'English' module over $/.",
            '',
            '1 file inspected, 1 offense detected, 1 offense corrected',
            '====================',
            'p $INPUT_RECORD_SEPARATOR'].join("\n"))
        ensure
          $stdin = STDIN
        end
      end
    end
  end

  context 'when interrupted' do
    it 'returns 1' do
      allow_any_instance_of(RuboCop::Runner)
        .to receive(:aborting?).and_return(true)
      create_file('example.rb', '# encoding: utf-8')
      expect(cli.run(['example.rb'])).to eq(1)
    end
  end

  describe '#trap_interrupt' do
    let(:runner) { RuboCop::Runner.new({}, RuboCop::ConfigStore.new) }
    let(:interrupt_handlers) { [] }

    before do
      allow(Signal).to receive(:trap).with('INT') do |&block|
        interrupt_handlers << block
      end
    end

    def interrupt
      interrupt_handlers.each(&:call)
    end

    it 'adds a handler for SIGINT' do
      expect(interrupt_handlers).to be_empty
      cli.trap_interrupt(runner)
      expect(interrupt_handlers.size).to eq(1)
    end

    context 'with SIGINT once' do
      it 'aborts processing' do
        cli.trap_interrupt(runner)
        expect(runner).to receive(:abort)
        interrupt
      end

      it 'does not exit immediately' do
        cli.trap_interrupt(runner)
        expect_any_instance_of(Object).not_to receive(:exit)
        expect_any_instance_of(Object).not_to receive(:exit!)
        interrupt
      end
    end

    context 'with SIGINT twice' do
      it 'exits immediately' do
        cli.trap_interrupt(runner)
        expect_any_instance_of(Object).to receive(:exit!).with(1)
        interrupt
        interrupt
      end
    end
  end

  context 'when given a file/directory that is not under the current dir' do
    shared_examples 'checks Rakefile' do
      it 'checks a Rakefile but Style/FileName does not report' do
        create_file('Rakefile', 'x = 1')
        create_file('other/empty', '')
        Dir.chdir('other') do
          expect(cli.run(['--format', 'simple', checked_path])).to eq(1)
        end
        expect($stdout.string)
          .to eq(["== #{abs('Rakefile')} ==",
                  'W:  1:  1: Useless assignment to variable - x.',
                  '',
                  '1 file inspected, 1 offense detected',
                  ''].join("\n"))
      end
    end

    context 'and the directory is absolute' do
      let(:checked_path) { abs('..') }
      include_examples 'checks Rakefile'
    end

    context 'and the directory is relative' do
      let(:checked_path) { '..' }
      include_examples 'checks Rakefile'
    end

    context 'and the Rakefile path is absolute' do
      let(:checked_path) { abs('../Rakefile') }
      include_examples 'checks Rakefile'
    end

    context 'and the Rakefile path is relative' do
      let(:checked_path) { '../Rakefile' }
      include_examples 'checks Rakefile'
    end
  end

  it 'checks a given correct file and returns 0' do
    create_file('example.rb', ['# encoding: utf-8',
                               'x = 0',
                               'puts x'])
    expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
    expect($stdout.string)
      .to eq(['',
              '1 file inspected, no offenses detected',
              ''].join("\n"))
  end

  it 'checks a given file with faults and returns 1' do
    create_file('example.rb', ['# encoding: utf-8',
                               'x = 0 ',
                               'puts x'])
    expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq ['== example.rb ==',
              'C:  2:  6: Trailing whitespace detected.',
              '',
              '1 file inspected, 1 offense detected',
              ''].join("\n")
  end

  it 'registers an offense for a syntax error' do
    create_file('example.rb', ['# encoding: utf-8',
                               'class Test',
                               'en'])
    expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:4:2: E: unexpected " \
              'token $end',
              ''].join("\n"))
  end

  it 'registers an offense for Parser warnings' do
    create_file('example.rb', ['# encoding: utf-8',
                               'puts *test',
                               'if a then b else c end'])
    expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:2:6: W: " \
              'Ambiguous splat operator. Parenthesize the method arguments ' \
              "if it's surely a splat operator, or add a whitespace to the " \
              'right of the `*` if it should be a multiplication.',
              "#{abs('example.rb')}:3:1: C: " \
              'Favor the ternary operator (`?:`) over `if/then/else/end` ' \
              'constructs.',
              ''].join("\n"))
  end

  it 'can process a file with an invalid UTF-8 byte sequence' do
    create_file('example.rb', ['# encoding: utf-8',
                               "# #{'f9'.hex.chr}#{'29'.hex.chr}"])
    expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:1: F: Invalid byte sequence in utf-8.",
              ''].join("\n"))
  end

  context 'when errors are raised while processing files due to bugs' do
    let(:errors) do
      ['An error occurred while Encoding cop was inspecting file.rb.']
    end

    before do
      allow_any_instance_of(RuboCop::Runner)
        .to receive(:errors).and_return(errors)
    end

    it 'displays an error message to stderr' do
      cli.run([])
      expect($stderr.string)
        .to include('1 error occurred:').and include(errors.first)
    end
  end

  describe 'rubocop:disable comment' do
    it 'can disable all cops in a code section' do
      src = ['# encoding: utf-8',
             '# rubocop:disable all',
             '#' * 90,
             'x(123456)',
             'y("123")',
             'def func',
             '  # rubocop: enable Metrics/LineLength,Style/StringLiterals',
             '  ' + '#' * 93,
             '  x(123456)',
             '  y("123")',
             'end']
      create_file('example.rb', src)
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      # all cops were disabled, then 2 were enabled again, so we
      # should get 2 offenses reported.
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:8:81: C: Line is too long. [95/80]",
                "#{abs('example.rb')}:10:5: C: Prefer single-quoted " \
                "strings when you don't need string interpolation or " \
                'special symbols.',
                ''].join("\n"))
    end

    context 'when --auto-correct is given' do
      it 'does not trigger UnneededDisable due to lines moving around' do
        src = ['a = 1 # rubocop:disable Lint/UselessAssignment']
        create_file('example.rb', src)
        create_file('.rubocop.yml', ['Style/Encoding:',
                                     '  Enabled: true'])
        expect(cli.run(['--format', 'offenses', '-a', 'example.rb'])).to eq(0)
        expect($stdout.string).to eq(['',
                                      '1  Style/Encoding',
                                      '--',
                                      '1  Total',
                                      '',
                                      ''].join("\n"))
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  'a = 1 # rubocop:disable Lint/UselessAssignment',
                  ''].join("\n"))
      end
    end

    it 'can disable selected cops in a code section' do
      create_file('example.rb',
                  ['# encoding: utf-8',
                   '# rubocop:disable Style/LineLength,' \
                   'Style/NumericLiterals,Style/StringLiterals',
                   '#' * 90,
                   'x(123456)',
                   'y("123")',
                   'def func',
                   '  # rubocop: enable Metrics/LineLength, ' \
                   'Style/StringLiterals',
                   '  ' + '#' * 93,
                   '  x(123456)',
                   '  y("123")',
                   'end'])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stderr.string)
        .to eq(["#{abs('example.rb')}: Style/LineLength has the wrong " \
                'namespace - should be Metrics',
                ''].join("\n"))
      # 3 cops were disabled, then 2 were enabled again, so we
      # should get 2 offenses reported.
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:8:81: C: Line is too long. [95/80]",
                "#{abs('example.rb')}:10:5: C: Prefer single-quoted " \
                "strings when you don't need string interpolation or " \
                'special symbols.',
                ''].join("\n"))
    end

    it 'can disable all cops on a single line' do
      create_file('example.rb', ['# encoding: utf-8',
                                 'y("123", 123456) # rubocop:disable all'
                                ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
      expect($stdout.string).to be_empty
    end

    it 'can disable selected cops on a single line' do
      create_file('example.rb',
                  ['# encoding: utf-8',
                   'a' * 90 + ' # rubocop:disable Metrics/LineLength',
                   '#' * 95,
                   'y("123", 123456) # rubocop:disable Style/StringLiterals,' \
                   'Style/NumericLiterals'
                  ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:3:81: C: Line is too long. [95/80]",
                ''].join("\n"))
    end

    context 'without using namespace' do
      it 'can disable selected cops on a single line' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     'a' * 90 + ' # rubocop:disable LineLength',
                     '#' * 95,
                     'y("123") # rubocop:disable StringLiterals'
                    ])
        expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(["#{abs('example.rb')}:3:81: C: Line is too long. [95/80]",
                  ''].join("\n"))
      end
    end

    context 'when not necessary' do
      it 'causes an offense to be reported' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     '#' * 95,
                     '# rubocop:disable all',
                     'a' * 10 + ' # rubocop:disable LineLength,ClassLength',
                     'y(123) # rubocop:disable all'])
        expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
        expect($stderr.string).to eq('')
        expect($stdout.string)
          .to eq(["#{abs('example.rb')}:2:81: C: Line is too long. [95/80]",
                  "#{abs('example.rb')}:3:1: W: Unnecessary disabling of " \
                  'all cops.',
                  "#{abs('example.rb')}:4:12: W: Unnecessary disabling of " \
                  '`Metrics/ClassLength`, `Metrics/LineLength`.',
                  "#{abs('example.rb')}:5:8: W: Unnecessary disabling of " \
                  'all cops.',
                  ''].join("\n"))
      end

      context 'and there are no other offenses' do
        it 'exits with error code' do
          create_file('example.rb',
                      ['# encoding: utf-8',
                       'a' * 10 + ' # rubocop:disable LineLength'])
          expect(cli.run(['example.rb'])).to eq(1)
        end
      end

      context 'and UnneededDisable is disabled' do
        it 'does not cause UnneededDisable offenses to be reported' do
          create_file('example.rb',
                      ['# encoding: utf-8',
                       '#' * 95,
                       '# rubocop:disable all',
                       'a' * 10 + ' # rubocop:disable LineLength,ClassLength',
                       'y(123) # rubocop:disable all'])
          create_file('.rubocop.yml', ['UnneededDisable:',
                                       '  Enabled: false'])
          expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
          expect($stderr.string).to eq('')
          expect($stdout.string)
            .to eq(["#{abs('example.rb')}:2:81: C: Line is too long. [95/80]",
                    ''].join("\n"))
        end
      end
    end
  end

  it 'finds a file with no .rb extension but has a shebang line' do
    create_file('example', ['#!/usr/bin/env ruby',
                            '# encoding: utf-8',
                            'x = 0',
                            'puts x'
                           ])
    expect(cli.run(%w(--format simple))).to eq(0)
    expect($stdout.string)
      .to eq(['', '1 file inspected, no offenses detected', ''].join("\n"))
  end

  it 'does not register any offenses for an empty file' do
    create_file('example.rb', '')
    expect(cli.run(%w(--format simple))).to eq(0)
    expect($stdout.string)
      .to eq(['', '1 file inspected, no offenses detected', ''].join("\n"))
  end

  describe 'style guide only usage' do
    context 'via the cli option' do
      describe '--only-guide-cops' do
        it 'skips cops that have no link to a style guide' do
          create_file('example.rb', 'fail')
          create_file('.rubocop.yml', ['Metrics/LineLength:',
                                       '  Enabled: true',
                                       '  StyleGuide: ~',
                                       '  Max: 2'])

          expect(cli.run(['--format', 'simple', '--only-guide-cops',
                          'example.rb'])).to eq(0)
        end

        it 'runs cops for rules that link to a style guide' do
          create_file('example.rb', 'fail')
          create_file('.rubocop.yml', ['Metrics/LineLength:',
                                       '  Enabled: true',
                                       '  StyleGuide: "http://an.example/url"',
                                       '  Max: 2'])

          expect(cli.run(['--format', 'simple', '--only-guide-cops',
                          'example.rb'])).to eq(1)

          expect($stdout.string)
            .to eq(['== example.rb ==',
                    'C:  1:  3: Line is too long. [4/2]',
                    '',
                    '1 file inspected, 1 offense detected',
                    ''].join("\n"))
        end

        it 'overrides configuration of AllCops/StyleGuideCopsOnly' do
          create_file('example.rb', 'fail')
          create_file('.rubocop.yml', ['AllCops:',
                                       '  StyleGuideCopsOnly: false',
                                       'Metrics/LineLength:',
                                       '  Enabled: true',
                                       '  StyleGuide: ~',
                                       '  Max: 2'])

          expect(cli.run(['--format', 'simple', '--only-guide-cops',
                          'example.rb'])).to eq(0)
        end
      end
    end

    context 'via the config' do
      before do
        create_file('example.rb', 'do_something or fail')
        create_file('.rubocop.yml',
                    ['AllCops:',
                     "  StyleGuideCopsOnly: #{guide_cops_only}",
                     "  DisabledByDefault: #{disabled_by_default}",
                     'Metrics/LineLength:',
                     '  Enabled: true',
                     '  StyleGuide: ~',
                     '  Max: 2'])
      end

      describe 'AllCops/StyleGuideCopsOnly' do
        let(:disabled_by_default) { 'false' }

        context 'when it is true' do
          let(:guide_cops_only) { 'true' }

          it 'skips cops that have no link to a style guide' do
            expect(cli.run(['--format', 'offenses', 'example.rb'])).to eq(1)

            expect($stdout.string.strip).to eq(['1  Style/AndOr',
                                                '--',
                                                '1  Total'].join("\n"))
          end
        end

        context 'when it is false' do
          let(:guide_cops_only) { 'false' }

          it 'runs cops for rules regardless of any link to the style guide' do
            expect(cli.run(['--format', 'offenses', 'example.rb'])).to eq(1)

            expect($stdout.string.strip).to eq(['1  Metrics/LineLength',
                                                '1  Style/AndOr',
                                                '--',
                                                '2  Total'].join("\n"))
          end
        end
      end

      describe 'AllCops/DisabledByDefault' do
        let(:guide_cops_only) { 'false' }

        context 'when it is true' do
          let(:disabled_by_default) { 'true' }

          it 'runs only the cop configured in .rubocop.yml' do
            expect(cli.run(['--format', 'offenses', 'example.rb'])).to eq(1)

            expect($stdout.string.strip).to eq(['1  Metrics/LineLength',
                                                '--',
                                                '1  Total'].join("\n"))
          end
        end

        context 'when it is false' do
          let(:disabled_by_default) { 'false' }

          it 'runs all cops that are enabled in default configuration' do
            expect(cli.run(['--format', 'offenses', 'example.rb'])).to eq(1)

            expect($stdout.string.strip).to eq(['1  Metrics/LineLength',
                                                '1  Style/AndOr',
                                                '--',
                                                '2  Total'].join("\n"))
          end
        end
      end
    end
  end

  describe 'rails cops' do
    describe 'enabling/disabling' do
      it 'by default does not run rails cops' do
        create_file('app/models/example1.rb', ['# encoding: utf-8',
                                               'read_attribute(:test)'])
        expect(cli.run(['--format', 'simple', 'app/models/example1.rb']))
          .to eq(0)
      end

      it 'with -R given runs rails cops' do
        create_file('app/models/example1.rb', ['# encoding: utf-8',
                                               'read_attribute(:test)'])
        expect(cli.run(['--format', 'simple', '-R', 'app/models/example1.rb']))
          .to eq(1)
        expect($stdout.string).to include('Prefer self[:attr]')
      end

      it 'with configuration option true in one dir runs rails cops there' do
        source = ['# encoding: utf-8',
                  'read_attribute(:test)']
        create_file('dir1/app/models/example1.rb', source)
        create_file('dir1/.rubocop.yml', ['Rails:',
                                          '  Enabled: true',
                                          '',
                                          'Rails/ReadWriteAttribute:',
                                          '  Include:',
                                          '    - app/models/**/*.rb'])
        create_file('dir2/app/models/example2.rb', source)
        create_file('dir2/.rubocop.yml', ['Rails:',
                                          '  Enabled: false',
                                          '',
                                          'Rails/ReadWriteAttribute:',
                                          '  Include:',
                                          '    - app/models/**/*.rb'])
        expect(cli.run(%w(--format simple dir1 dir2))).to eq(1)
        expect($stdout.string)
          .to eq(['== dir1/app/models/example1.rb ==',
                  'C:  2:  1: Prefer self[:attr] over read_attribute' \
                  '(:attr).',
                  '',
                  '2 files inspected, 1 offense detected',
                  ''].join("\n"))
      end

      it 'with configuration option false but -R given runs rails cops' do
        create_file('app/models/example1.rb', ['# encoding: utf-8',
                                               'read_attribute(:test)'])
        create_file('.rubocop.yml', ['Rails:',
                                     '  Enabled: false'])
        expect(cli.run(['--format', 'simple', '-R', 'app/models/example1.rb']))
          .to eq(1)
        expect($stdout.string).to include('Prefer self[:attr]')
      end

      context 'with obsolete RunRailsCops config option' do
        it 'prints a warning' do
          create_file('.rubocop.yml', ['AllCops:',
                                       '  RunRailsCops: false'])
          expect(cli.run([])).to eq(1)
          expect($stderr.string).to include('obsolete parameter RunRailsCops ' \
                                            '(for AllCops) found')
        end
      end
    end

    describe 'including/excluding' do
      it 'honors Exclude settings in .rubocop_todo.yml one level up' do
        create_file('lib/example.rb', ['# encoding: utf-8',
                                       'puts %x(ls)'])
        create_file('.rubocop.yml', 'inherit_from: .rubocop_todo.yml')
        create_file('.rubocop_todo.yml', ['Style/CommandLiteral:',
                                          '  Exclude:',
                                          '    - lib/example.rb'])
        Dir.chdir('lib') { expect(cli.run([])).to eq(0) }
        expect($stdout.string).to include('no offenses detected')
      end

      it 'includes some directories by default' do
        source = ['# encoding: utf-8',
                  'read_attribute(:test)',
                  "default_scope order: 'position'"]
        # Several rails cops include app/models by default.
        create_file('dir1/app/models/example1.rb', source)
        create_file('dir1/app/models/example2.rb', source)
        # No rails cops include app/views by default.
        create_file('dir1/app/views/example3.rb', source)
        # The .rubocop.yml file inherits from default.yml where the Include
        # config parameter is set for the rails cops. The paths are interpreted
        # as relative to dir1 because .rubocop.yml is placed there.
        create_file('dir1/.rubocop.yml', ['Rails:',
                                          '  Enabled: true',
                                          '',
                                          'Rails/ReadWriteAttribute:',
                                          '  Exclude:',
                                          '    - "**/example2.rb"',
                                          '',
                                          'Rails/DefaultScope:',
                                          '  Exclude:',
                                          '    - "**/example2.rb"'])
        # No .rubocop.yml file in dir2 means that the paths from default.yml
        # are interpreted as relative to the current directory, so they don't
        # match.
        create_file('dir2/app/models/example4.rb', source)

        expect(cli.run(%w(--format simple dir1 dir2))).to eq(1)
        expect($stdout.string)
          .to eq(['== dir1/app/models/example1.rb ==',
                  'C:  2:  1: Prefer self[:attr] over read_attribute' \
                  '(:attr).',
                  'C:  3: 15: default_scope expects a block as its sole' \
                  ' argument.',
                  '',
                  '4 files inspected, 2 offenses detected',
                  ''].join("\n"))
      end
    end
  end

  describe 'cops can exclude files based on config' do
    it 'ignores excluded files' do
      create_file('example.rb', ['# encoding: utf-8',
                                 'x = 0'])
      create_file('regexp.rb', ['# encoding: utf-8',
                                'x = 0'])
      create_file('exclude_glob.rb', ['#!/usr/bin/env ruby',
                                      '# encoding: utf-8',
                                      'x = 0'])
      create_file('dir/thing.rb', ['# encoding: utf-8',
                                   'x = 0'])
      create_file('.rubocop.yml', ['Lint/UselessAssignment:',
                                   '  Exclude:',
                                   '    - example.rb',
                                   '    - !ruby/regexp /regexp.rb\z/',
                                   '    - "exclude_*"',
                                   '    - "dir/*"'])
      expect(cli.run(%w(--format simple))).to eq(0)
      expect($stdout.string)
        .to eq(['', '4 files inspected, no offenses detected',
                ''].join("\n"))
    end
  end

  describe 'configuration from file' do
    context 'when configured for rails style indentation' do
      it 'accepts rails style indentation' do
        create_file('.rubocop.yml', ['Style/IndentationConsistency:',
                                     '  EnforcedStyle: rails'])
        create_file('example.rb', ['# encoding: utf-8',
                                   '',
                                   '# A feline creature',
                                   'class Cat',
                                   '  def meow',
                                   "    puts('Meow!')",
                                   '  end',
                                   '',
                                   '  protected',
                                   '',
                                   '    def can_we_be_friends?(another_cat)',
                                   '      some_logic(another_cat)',
                                   '    end',
                                   '',
                                   '  private',
                                   '',
                                   '    def meow_at_3am?',
                                   '      rand < 0.8',
                                   '    end',
                                   'end'])
        result = cli.run(%w(--format simple))
        expect($stderr.string).to eq('')
        expect(result).to eq(0)
        expect($stdout.string)
          .to eq(['', '1 file inspected, no offenses detected',
                  ''].join("\n"))
      end

      %w(class module).each do |parent|
        it "registers offense for normal indentation in #{parent}" do
          create_file('.rubocop.yml', ['Style/IndentationConsistency:',
                                       '  EnforcedStyle: rails'])
          create_file('example.rb', ['# encoding: utf-8',
                                     '',
                                     '# A feline creature',
                                     "#{parent} Cat",
                                     '  def meow',
                                     "    puts('Meow!')",
                                     '  end',
                                     '',
                                     '  protected',
                                     '',
                                     '  def can_we_be_friends?(another_cat)',
                                     '    some_logic(another_cat)',
                                     '  end',
                                     '',
                                     '  private',
                                     '',
                                     '  def meow_at_3am?',
                                     '    rand < 0.8',
                                     '  end',
                                     '',
                                     '  def meow_at_4am?',
                                     '    rand < 0.8',
                                     '  end',
                                     'end'])
          result = cli.run(%w(--format simple))
          expect($stderr.string).to eq('')
          expect(result).to eq(1)
          expect($stdout.string)
            .to eq(['== example.rb ==',
                    'C: 11:  3: Use 2 (not 0) spaces for rails indentation.',
                    'C: 17:  3: Use 2 (not 0) spaces for rails indentation.',
                    '',
                    '1 file inspected, 2 offenses detected',
                    ''].join("\n"))
        end
      end

      context 'when obsolete MultiSpaceAllowedForOperators param is used' do
        it 'displays a warning' do
          create_file('.rubocop.yml', ['Style/SpaceAroundOperators:',
                                       '  MultiSpaceAllowedForOperators:',
                                       '    - "="'])
          expect(cli.run([])).to eq(1)
          expect($stderr.string).to include('obsolete parameter ' \
                                            'MultiSpaceAllowedForOperators ' \
                                            '(for Style/SpaceAroundOperators)' \
                                            ' found')
        end
      end
    end

    it 'allows the default configuration file as the -c argument' do
      create_file('example.rb', ['# encoding: utf-8',
                                 'x = 0',
                                 'puts x'
                                ])
      create_file('.rubocop.yml', [])

      expect(cli.run(%w(--format simple -c .rubocop.yml))).to eq(0)
      expect($stdout.string)
        .to eq(['', '1 file inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'displays cop names if DisplayCopNames is true' do
      source = ['# encoding: utf-8',
                'x = 0 ',
                'puts x']
      create_file('example1.rb', source)

      # DisplayCopNames: false inherited from config/default.yml
      create_file('.rubocop.yml', [])

      create_file('dir/example2.rb', source)
      create_file('dir/.rubocop.yml', ['AllCops:',
                                       '  DisplayCopNames: true'])

      expect(cli.run(%w(--format simple))).to eq(1)
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  2:  6: Trailing whitespace detected.',
                '== dir/example2.rb ==',
                'C:  2:  6: Style/TrailingWhitespace: Trailing whitespace' \
                ' detected.',
                '',
                '2 files inspected, 2 offenses detected',
                ''].join("\n"))
    end

    it 'displays style guide URLs if DisplayStyleGuide is true' do
      source = ['# encoding: utf-8',
                'x = 0 ',
                'puts x']
      create_file('example1.rb', source)

      # DisplayCopNames: false inherited from config/default.yml
      create_file('.rubocop.yml', [])

      create_file('dir/example2.rb', source)
      create_file('dir/.rubocop.yml', ['AllCops:',
                                       '  DisplayStyleGuide: true'])

      url = 'https://github.com/bbatsov/ruby-style-guide#no-trailing-whitespace'

      expect(cli.run(%w(--format simple))).to eq(1)
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  2:  6: Trailing whitespace detected.',
                '== dir/example2.rb ==',
                'C:  2:  6: Trailing whitespace' \
                " detected. (#{url})",
                '',
                '2 files inspected, 2 offenses detected',
                ''].join("\n"))
    end

    it 'finds included files' do
      create_file('file.rb', 'x=0') # Included by default
      create_file('example', 'x=0')
      create_file('regexp', 'x=0')
      create_file('.dot1/file.rb', 'x=0') # Hidden but explicitly included
      create_file('.dot2/file.rb', 'x=0') # Hidden, excluded by default
      create_file('.dot3/file.rake', 'x=0') # Hidden, not included by wildcard
      create_file('.rubocop.yml', ['AllCops:',
                                   '  Include:',
                                   '    - example',
                                   '    - "**/*.rake"',
                                   '    - !ruby/regexp /regexp$/',
                                   '    - .dot1/**/*'
                                  ])
      expect(cli.run(%w(--format files))).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string.split($RS).sort).to eq([abs('.dot1/file.rb'),
                                                    abs('example'),
                                                    abs('file.rb'),
                                                    abs('regexp')])
    end

    it 'ignores excluded files' do
      create_file('example.rb', ['# encoding: utf-8',
                                 'x = 0',
                                 'puts x'
                                ])
      create_file('regexp.rb', ['# encoding: utf-8',
                                'x = 0',
                                'puts x'
                               ])
      create_file('exclude_glob.rb', ['#!/usr/bin/env ruby',
                                      '# encoding: utf-8',
                                      'x = 0',
                                      'puts x'
                                     ])
      create_file('.rubocop.yml', ['AllCops:',
                                   '  Exclude:',
                                   '    - example.rb',
                                   '    - !ruby/regexp /regexp.rb$/',
                                   '    - "exclude_*"'
                                  ])
      expect(cli.run(%w(--format simple))).to eq(0)
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'only reads configuration in explicitly included hidden directories' do
      create_file('.hidden/example.rb', ['# encoding: utf-8',
                                         'x=0'])
      # This file contains configuration for an unknown cop. This would cause a
      # warning to be printed on stderr if the file was read. But it's in a
      # hidden directory, so it's not read.
      create_file('.hidden/.rubocop.yml', ['SymbolName:',
                                           '  Enabled: false'])

      create_file('.other/example.rb', ['# encoding: utf-8',
                                        'x=0'])
      # The .other directory is explicitly included, so the configuration file
      # is read, and modifies the behavior.
      create_file('.other/.rubocop.yml', ['Style/SpaceAroundOperators:',
                                          '  Enabled: false'])
      create_file('.rubocop.yml', ['AllCops:',
                                   '  Include:',
                                   '    - .other/**/*'])
      expect(cli.run(%w(--format simple))).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq(['== .other/example.rb ==',
                'W:  2:  1: Useless assignment to variable - x.',
                '',
                '1 file inspected, 1 offense detected',
                ''].join("\n"))
    end

    it 'does not consider Include parameters in subdirectories' do
      create_file('dir/example.ruby', ['# encoding: utf-8',
                                       'x=0'])
      create_file('dir/.rubocop.yml', ['AllCops:',
                                       '  Include:',
                                       '    - "*.ruby"'])
      expect(cli.run(%w(--format simple))).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq(['',
                '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'matches included/excluded files correctly when . argument is given' do
      create_file('example.rb', 'x = 0')
      create_file('special.dsl', ['# encoding: utf-8',
                                  'setup { "stuff" }'
                                 ])
      create_file('.rubocop.yml', ['AllCops:',
                                   '  Include:',
                                   '    - "*.dsl"',
                                   '  Exclude:',
                                   '    - example.rb'
                                  ])
      expect(cli.run(%w(--format simple .))).to eq(1)
      expect($stdout.string)
        .to eq(['== special.dsl ==',
                "C:  2:  9: Prefer single-quoted strings when you don't " \
                'need string interpolation or special symbols.',
                '',
                '1 file inspected, 1 offense detected',
                ''].join("\n"))
    end

    # With rubinius 2.0.0.rc1 + rspec 2.13.1,
    # File.stub(:open).and_call_original causes SystemStackError.
    it 'does not read files in excluded list', broken: :rbx do
      %w(rb.rb non-rb.ext without-ext).each do |filename|
        create_file("example/ignored/#{filename}", ['# encoding: utf-8',
                                                    '#' * 90
                                                   ])
      end

      create_file('example/.rubocop.yml', ['AllCops:',
                                           '  Exclude:',
                                           '    - ignored/**'])
      expect(File).not_to receive(:open).with(%r{/ignored/})
      allow(File).to receive(:open).and_call_original
      expect(cli.run(%w(--format simple example))).to eq(0)
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'can be configured with option to disable a certain error' do
      create_file('example1.rb', 'puts 0 ')
      create_file('rubocop.yml', ['Style/Encoding:',
                                  '  Enabled: false',
                                  '',
                                  'Style/CaseIndentation:',
                                  '  Enabled: false'])
      expect(cli.run(['--format', 'simple',
                      '-c', 'rubocop.yml', 'example1.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  1:  7: Trailing whitespace detected.',
                '',
                '1 file inspected, 1 offense detected',
                ''].join("\n"))
    end

    context 'without using namespace' do
      it 'can be configured with option to disable a certain error' do
        create_file('example1.rb', 'puts 0 ')
        create_file('rubocop.yml', ['Encoding:',
                                    '  Enabled: false',
                                    '',
                                    'CaseIndentation:',
                                    '  Enabled: false'])
        expect(cli.run(['--format', 'simple',
                        '-c', 'rubocop.yml', 'example1.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(['== example1.rb ==',
                  'C:  1:  7: Trailing whitespace detected.',
                  '',
                  '1 file inspected, 1 offense detected',
                  ''].join("\n"))
      end
    end

    it 'can disable parser-derived offenses with warning severity' do
      # `-' interpreted as argument prefix
      create_file('example.rb', 'puts -1')
      create_file('.rubocop.yml', ['Style/Encoding:',
                                   '  Enabled: false',
                                   '',
                                   'Lint/AmbiguousOperator:',
                                   '  Enabled: false'
                                  ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
    end

    it 'cannot disable Syntax offenses' do
      create_file('example.rb', 'class Test')
      create_file('.rubocop.yml', ['Style/Encoding:',
                                   '  Enabled: false',
                                   '',
                                   'Syntax:',
                                   '  Enabled: false'
                                  ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stderr.string).to include(
        'Error: configuration for Syntax cop found')
      expect($stderr.string).to include('This cop cannot be configured.')
    end

    it 'can be configured to merge a parameter that is a hash' do
      create_file('example1.rb',
                  ['# encoding: utf-8',
                   'puts %w(a b c)',
                   'puts %q|hi|'])
      # We want to change the preferred delimiters for word arrays. The other
      # settings from default.yml are unchanged.
      create_file('rubocop.yml',
                  ['Style/PercentLiteralDelimiters:',
                   '  PreferredDelimiters:',
                   "    '%w': '[]'",
                   "    '%W': '[]'"])
      cli.run(['--format', 'simple', '-c', 'rubocop.yml', 'example1.rb'])
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  2:  6: %w-literals should be delimited by [ and ].',
                'C:  3:  6: %q-literals should be delimited by ( and ).',
                'C:  3:  6: Use %q only for strings that contain both single ' \
                'quotes and double quotes.',
                '',
                '1 file inspected, 3 offenses detected',
                ''].join("\n"))
    end

    it 'can be configured to override a parameter that is a hash in a ' \
       'special case' do
      create_file('example1.rb',
                  ['# encoding: utf-8',
                   'arr.select { |e| e > 0 }.collect { |e| e * 2 }',
                   'a2.find_all { |e| e > 0 }'])
      # We prefer find_all over select. This setting overrides the default
      # select over find_all. Other preferred methods appearing in the default
      # config (e.g., map over collect) are kept.
      create_file('rubocop.yml',
                  ['Style/CollectionMethods:',
                   '  PreferredMethods:',
                   '    select: find_all'])
      cli.run(['--format',
               'simple',
               '-c',
               'rubocop.yml',
               '--only',
               'CollectionMethods',
               'example1.rb'])
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  2:  5: Prefer find_all over select.',
                'C:  2: 26: Prefer map over collect.',
                '',
                '1 file inspected, 2 offenses detected',
                ''].join("\n"))
    end

    it 'works when a cop that others depend on is disabled' do
      create_file('example1.rb', ['if a',
                                  '  b',
                                  'end'])
      create_file('rubocop.yml', ['Style/Encoding:',
                                  '  Enabled: false',
                                  '',
                                  'Metrics/LineLength:',
                                  '  Enabled: false'
                                 ])
      result = cli.run(['--format', 'simple',
                        '-c', 'rubocop.yml', 'example1.rb'])
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  1:  1: Favor modifier if usage when having ' \
                'a single-line body. Another good alternative is the ' \
                'usage of control flow &&/||.',
                '',
                '1 file inspected, 1 offense detected',
                ''].join("\n"))
      expect(result).to eq(1)
    end

    it 'can be configured with project config to disable a certain error' do
      create_file('example_src/example1.rb', 'puts 0 ')
      create_file('example_src/.rubocop.yml', ['Style/Encoding:',
                                               '  Enabled: false',
                                               '',
                                               'Style/CaseIndentation:',
                                               '  Enabled: false'
                                              ])
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(['== example_src/example1.rb ==',
                'C:  1:  7: Trailing whitespace detected.',
                '',
                '1 file inspected, 1 offense detected',
                ''].join("\n"))
    end

    it 'can use an alternative max line length from a config file' do
      create_file('example_src/example1.rb', ['# encoding: utf-8',
                                              '#' * 90
                                             ])
      create_file('example_src/.rubocop.yml', ['Metrics/LineLength:',
                                               '  Enabled: true',
                                               '  Max: 100'
                                              ])
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(0)
      expect($stdout.string)
        .to eq(['', '1 file inspected, no offenses detected', ''].join("\n"))
    end

    it 'can have different config files in different directories' do
      %w(src lib).each do |dir|
        create_file("example/#{dir}/example1.rb", ['# encoding: utf-8',
                                                   '#' * 90
                                                  ])
      end
      create_file('example/src/.rubocop.yml', ['Metrics/LineLength:',
                                               '  Enabled: true',
                                               '  Max: 100'
                                              ])
      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stdout.string).to eq(['== example/lib/example1.rb ==',
                                    'C:  2: 81: Line is too long. [90/80]',
                                    '',
                                    '2 files inspected, 1 offense detected',
                                    ''].join("\n"))
    end

    it 'prefers a config file in ancestor directory to another in home' do
      create_file('example_src/example1.rb', ['# encoding: utf-8',
                                              '#' * 90
                                             ])
      create_file('example_src/.rubocop.yml', ['Metrics/LineLength:',
                                               '  Enabled: true',
                                               '  Max: 100'
                                              ])
      create_file("#{Dir.home}/.rubocop.yml", ['Metrics/LineLength:',
                                               '  Enabled: true',
                                               '  Max: 80'
                                              ])
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(0)
      expect($stdout.string)
        .to eq(['', '1 file inspected, no offenses detected', ''].join("\n"))
    end

    it 'can exclude directories relative to .rubocop.yml' do
      %w(src etc/test etc/spec tmp/test tmp/spec).each do |dir|
        create_file("example/#{dir}/example1.rb", ['# encoding: utf-8',
                                                   '#' * 90])
      end

      # Hidden subdirectories should also be excluded.
      create_file('example/etc/.dot/example1.rb', ['# encoding: utf-8',
                                                   '#' * 90])

      create_file('example/.rubocop.yml', ['AllCops:',
                                           '  Exclude:',
                                           '    - src/**',
                                           '    - etc/**/*',
                                           '    - tmp/spec/**'])

      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string).to eq(['== example/tmp/test/example1.rb ==',
                                    'C:  2: 81: Line is too long. [90/80]',
                                    '',
                                    '1 file inspected, 1 offense detected',
                                    ''].join("\n"))
    end

    it 'can exclude a typical vendor directory' do
      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/.rubocop.yml',
                  ['AllCops:',
                   '  Exclude:',
                   '    - lib/parser/lexer.rb'])

      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/lib/ex.rb',
                  ['# encoding: utf-8',
                   '#' * 90])

      create_file('.rubocop.yml',
                  ['AllCops:',
                   '  Exclude:',
                   '    - vendor/**/*'])

      cli.run(%w(--format simple))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'excludes the vendor directory by default' do
      create_file('vendor/ex.rb',
                  ['# encoding: utf-8',
                   '#' * 90])

      cli.run(%w(--format simple))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    # Being immune to bad configuration files in excluded directories has
    # become important due to a bug in rubygems
    # (https://github.com/rubygems/rubygems/issues/680) that makes
    # installations of, for example, rubocop lack their .rubocop.yml in the
    # root directory.
    it 'can exclude a vendor directory with an erroneous config file' do
      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/.rubocop.yml',
                  ['inherit_from: non_existent.yml'])

      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/lib/ex.rb',
                  ['# encoding: utf-8',
                   '#' * 90])

      create_file('.rubocop.yml',
                  ['AllCops:',
                   '  Exclude:',
                   '    - vendor/**/*'])

      cli.run(%w(--format simple))
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    # Relative exclude paths in .rubocop.yml files are relative to that file,
    # but in configuration files with other names they will be relative to
    # whatever file inherits from them.
    it 'can exclude a vendor directory indirectly' do
      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/.rubocop.yml',
                  ['AllCops:',
                   '  Exclude:',
                   '    - lib/parser/lexer.rb'])

      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/lib/ex.rb',
                  ['# encoding: utf-8',
                   '#' * 90])

      create_file('.rubocop.yml',
                  ['inherit_from: config/default.yml'])

      create_file('config/default.yml',
                  ['AllCops:',
                   '  Exclude:',
                   '    - vendor/**/*'])

      cli.run(%w(--format simple))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'prints a warning for an unrecognized cop name in .rubocop.yml' do
      create_file('example/example1.rb', ['# encoding: utf-8',
                                          '#' * 90])

      create_file('example/.rubocop.yml', ['Style/LyneLenth:',
                                           '  Enabled: true',
                                           '  Max: 100'])

      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stderr.string)
        .to eq(['Warning: unrecognized cop Style/LyneLenth found in ' +
                abs('example/.rubocop.yml'),
                ''].join("\n"))
    end

    it 'prints a warning for an unrecognized configuration parameter' do
      create_file('example/example1.rb', ['# encoding: utf-8',
                                          '#' * 90])

      create_file('example/.rubocop.yml', ['Metrics/LineLength:',
                                           '  Enabled: true',
                                           '  Min: 10'])

      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stderr.string)
        .to eq(['Warning: unrecognized parameter Metrics/LineLength:Min ' \
                'found in ' + abs('example/.rubocop.yml'),
                ''].join("\n"))
    end

    it 'prints an error message for an unrecognized EnforcedStyle' do
      create_file('example/example1.rb', ['# encoding: utf-8',
                                          'puts "hello"'])
      create_file('example/.rubocop.yml', ['Style/BracesAroundHashParameters:',
                                           '  EnforcedStyle: context'])

      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stderr.string)
        .to eq(["Error: invalid EnforcedStyle 'context' for " \
                'Style/BracesAroundHashParameters found in ' +
                abs('example/.rubocop.yml'),
                'Valid choices are: braces, no_braces, context_dependent',
                ''].join("\n"))
    end

    it 'works when a configuration file passed by -c specifies Exclude ' \
       'with regexp' do
      create_file('example/example1.rb', ['# encoding: utf-8',
                                          '#' * 90])

      create_file('rubocop.yml', ['AllCops:',
                                  '  Exclude:',
                                  '    - !ruby/regexp /example1\.rb$/'])

      cli.run(%w(--format simple -c rubocop.yml))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'works when a configuration file passed by -c specifies Exclude ' \
       'with strings' do
      create_file('example/example1.rb', ['# encoding: utf-8',
                                          '#' * 90])

      create_file('rubocop.yml', ['AllCops:',
                                  '  Exclude:',
                                  '    - example/**'])

      cli.run(%w(--format simple -c rubocop.yml))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'works when a configuration file specifies a Severity' do
      create_file('example/example1.rb', ['# encoding: utf-8',
                                          '#' * 90])

      create_file('rubocop.yml', ['Metrics/LineLength:',
                                  '  Severity: error'])

      cli.run(%w(--format simple -c rubocop.yml))
      expect($stdout.string)
        .to eq(['== example/example1.rb ==',
                'E:  2: 81: Line is too long. [90/80]',
                '',
                '1 file inspected, 1 offense detected',
                ''].join("\n"))
      expect($stderr.string).to eq('')
    end

    it 'fails when a configuration file specifies an invalid Severity' do
      create_file('example/example1.rb', ['# encoding: utf-8',
                                          '#' * 90])

      create_file('rubocop.yml', ['Metrics/LineLength:',
                                  '  Severity: superbad'])

      cli.run(%w(--format simple -c rubocop.yml))
      expect($stderr.string)
        .to eq(["Warning: Invalid severity 'superbad'. " \
                'Valid severities are refactor, convention, ' \
                'warning, error, fatal.',
                ''].join("\n"))
    end

    it 'fails when a configuration file has invalid YAML syntax' do
      create_file('example/.rubocop.yml', ['AllCops:',
                                           '  Exclude:',
                                           '    - **/*_old.rb'])

      cli.run(['example'])
      # MRI and JRuby return slightly different error messages.
      expect($stderr.string)
        .to match(/^\(<unknown>\):\ (did\ not\ find\ )?expected\ alphabetic\ or
                  \ numeric\ character/x)
    end

    context 'when a file inherits from the old auto generated file' do
      before do
        create_file('rubocop-todo.yml', '')
        create_file('.rubocop.yml', ['inherit_from: rubocop-todo.yml'])
      end

      it 'prints no warning when --auto-gen-config is not set' do
        expect { cli.run(%w(-c .rubocop.yml)) }.not_to exit_with_code(1)
      end

      it 'prints a warning when --auto-gen-config is set' do
        expect(cli.run(%w(-c .rubocop.yml --auto-gen-config))).to eq(1)
        expect($stderr.string)
          .to eq(['Error: rubocop-todo.yml is obsolete; it must be called ' \
                  '.rubocop_todo.yml instead',
                  ''].join("\n"))
      end
    end

    context 'when a file inherits from a higher level' do
      before do
        create_file('.rubocop.yml', ['Metrics/LineLength:',
                                     '  Exclude:',
                                     '    - dir/example.rb'])
        create_file('dir/.rubocop.yml', 'inherit_from: ../.rubocop.yml')
        create_file('dir/example.rb', '#' * 90)
      end

      it 'inherits relative excludes correctly' do
        expect(cli.run([])).to eq(0)
      end
    end

    context 'when configuration is taken from $HOME/.rubocop.yml' do
      before do
        create_file("#{Dir.home}/.rubocop.yml", ['Metrics/LineLength:',
                                                 '  Exclude:',
                                                 '    - dir/example.rb'])
        create_file('dir/example.rb', '#' * 90)
      end

      it 'handles relative excludes correctly when run from project root' do
        expect(cli.run([])).to eq(0)
      end
    end

    it 'shows an error if the input file cannot be found' do
      begin
        cli.run(%w(/tmp/not_a_file))
      rescue SystemExit => e
        expect(e.status).to eq(1)
        expect(e.message)
          .to eq 'rubocop: No such file or directory -- /tmp/not_a_file'
      end
    end
  end
end
