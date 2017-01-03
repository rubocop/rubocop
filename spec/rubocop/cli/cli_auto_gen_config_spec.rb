# frozen_string_literal: true

require 'spec_helper'
require 'timeout'

describe RuboCop::CLI, :isolated_environment do
  include FileHelper

  include_context 'cli spec behavior'

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

  describe '--auto-gen-config' do
    before(:each) do
      RuboCop::Formatter::DisabledConfigFormatter
        .config_to_allow_offenses = {}
    end

    it 'overwrites an existing todo file' do
      create_file('example1.rb', ['x= 0 ',
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
                'URISchemes, IgnoreCopDirectives, IgnoredPatterns.',
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
      create_file('example1.rb', ['#' * 81,
                                  '# rubocop:disable LineLength',
                                  '#' * 85,
                                  'y ',
                                  'puts 123456'])
      create_file('.rubocop.yml', ['inherit_from: .rubocop_todo.yml'])
      expect(cli.run(['--auto-gen-config'])).to eq(1)
      expect(IO.readlines('.rubocop_todo.yml')[8..-1].join)
        .to eq(['# Offense count: 1',
                '# Configuration parameters: AllowHeredoc, AllowURI, ' \
                'URISchemes, IgnoreCopDirectives, IgnoredPatterns.',
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
      create_file('example1.rb', ['$x= 0 ',
                                  '#' * 90,
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', ['# encoding: utf-8',
                                  "\tx = 0",
                                  'puts x',
                                  '',
                                  'class A',
                                  '  def a; end',
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
         '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes, '\
         'IgnoreCopDirectives, IgnoredPatterns.',
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
      create_file('example1.rb', ['$x= 0 ',
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
         '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes, '\
         'IgnoreCopDirectives, IgnoredPatterns.',
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
      create_file('example.rb', 'y.gsub!(/abc\/xyz/, x)')
      expect(cli.run(%w(--format emacs))).to eq(1)
      expect($stdout.string).to eq("#{abs('example.rb')}:1:9: C: Use `%r` " \
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
      create_file('example1.rb', ['$x= 0 ',
                                  '#' * 90,
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', ['# encoding: utf-8',
                                  "\tx = 0",
                                  'puts x',
                                  '',
                                  'class A',
                                  '  def a; end',
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
         '# `rubocop --auto-gen-config --no-offense-counts`',
         /# on .* using RuboCop version .*/,
         '# The point is for the user to remove these configuration records',
         '# one by one as the offenses are removed from the code base.',
         '# Note that changes in the inspected code, or installation of new',
         '# versions of RuboCop, may require this file to be generated ' \
         'again.',
         '',
         '# Configuration parameters: AllowHeredoc, AllowURI, URISchemes, '\
         'IgnoreCopDirectives, IgnoredPatterns.',
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

    describe 'when different styles appear in different files' do
      before do
        create_file('example1.rb', ['$!'])
        create_file('example2.rb', ['$!'])
        create_file('example3.rb', ['$ERROR_INFO'])
      end

      it 'disables cop if --exclude-limit is exceeded' do
        expect(cli.run(['--auto-gen-config', '--exclude-limit', '1'])).to eq(1)
        expect(IO.readlines('.rubocop_todo.yml')[8..-1].join)
          .to eq(['# Offense count: 2',
                  '# Cop supports --auto-correct.',
                  '# Configuration parameters: EnforcedStyle, SupportedStyles.',
                  '# SupportedStyles: use_perl_names, use_english_names',
                  'Style/SpecialGlobalVars:',
                  '  Enabled: false',
                  ''].join("\n"))
      end

      it 'generates Exclude list if --exclude-limit is not exceeded' do
        create_file('example4.rb', ['$!'])
        expect(cli.run(['--auto-gen-config', '--exclude-limit', '10'])).to eq(1)
        expect(IO.readlines('.rubocop_todo.yml')[8..-1].join)
          .to eq(['# Offense count: 3',
                  '# Cop supports --auto-correct.',
                  '# Configuration parameters: EnforcedStyle, SupportedStyles.',
                  '# SupportedStyles: use_perl_names, use_english_names',
                  'Style/SpecialGlobalVars:',
                  '  Exclude:',
                  "    - 'example1.rb'",
                  "    - 'example2.rb'",
                  "    - 'example4.rb'",
                  ''].join("\n"))
      end
    end

    it 'can be called when there are no files to inspection' do
      expect(cli.run(['--auto-gen-config'])).to eq(0)
    end
  end
end
