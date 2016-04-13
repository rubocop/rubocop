# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

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
          expect($stdout.string.split("\n")).to contain_exactly(
            'app.rb', 'Gemfile', 'lib/helper.rb')
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
          expect($stdout.string.split("\n")).to contain_exactly(
            'app.rb', 'lib/helper.rb', 'show.rabl')
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
        expect(cli.run(['--only', 'Style/123'])).to eq(2)
        expect($stderr.string)
          .to include('Unrecognized cop or namespace: Style/123.')
      end

      it 'exits with error if an empty string is given' do
        create_file('example.rb', 'x')
        expect(cli.run(['--only', ''])).to eq(2)
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
          expect(cli.run(['--only', 'UnneededDisable'])).to eq(2)
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
        expect(cli.run(['--except', 'Style/123'])).to eq(2)
        expect($stderr.string)
          .to include('Unrecognized cop or namespace: Style/123.')
      end

      it 'exits with error if an empty string is given' do
        create_file('example.rb', 'x')
        expect(cli.run(['--except', ''])).to eq(2)
        expect($stderr.string).to include('Unrecognized cop or namespace: .')
      end

      %w(Syntax Lint/Syntax).each do |name|
        it "exits with error if #{name} is given" do
          create_file('example.rb', 'x ')
          expect(cli.run(['--except', name])).to eq(2)
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
      home = File.dirname(File.dirname(File.dirname(File.dirname(__FILE__))))
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

      %w(html json).each do |format|
        context "when #{format} format is specified" do
          context 'and offenses come from the cache' do
            context 'and a message has binary encoding' do
              let(:message_from_cache) do
                'Cyclomatic complexity for 文 is too high. [8/6]'
                  .dup
                  .force_encoding('ASCII-8BIT')
              end
              let(:data_from_cache) do
                [
                  {
                    'severity' => 'convention',
                    'location' => { 'begin_pos' => 18, 'end_pos' => 21 },
                    'message' => message_from_cache,
                    'cop_name' => 'Metrics/CyclomaticComplexity',
                    'status' => 'unsupported'
                  }
                ]
              end

              it "outputs #{format.upcase} code without crashing" do
                create_file('example.rb', ['# encoding: utf-8',
                                           'def 文',
                                           '  b if a',
                                           '  b if a',
                                           '  b if a',
                                           '  b if a',
                                           '  b if a',
                                           '  b if a',
                                           '  b if a',
                                           'end'])
                # Stub out the JSON.load call used by the cache mechanism, so
                # we can test what happens when an offense message has
                # ASCII-8BIT encoding and contains a non-7bit-ascii character.
                allow(JSON).to receive(:load).and_return(data_from_cache)

                2.times do
                  # The second run (and possibly the first) should hit the
                  # cache.
                  expect(cli.run(['--format', format,
                                  '--only', 'Metrics/CyclomaticComplexity']))
                    .to eq(1)
                end
                expect($stderr.string).to eq('')
              end
            end
          end
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
                    "\tx",
                    ' ^',
                    'example2.rb:3:1: C: Inconsistent indentation ' \
                    'detected.',
                    'def a ...',
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
          expect(cli.run(['--format', 'unknown', 'example.rb'])).to eq(2)
          expect($stderr.string)
            .to include('No formatter for "unknown"')
        end
      end

      context 'when ambiguous format name is specified' do
        it 'aborts with error message' do
          # Both 'files' and 'fuubar' start with an 'f'.
          expect(cli.run(['--format', 'f', 'example.rb'])).to eq(2)
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
          expect(cli.run(args.split)).to eq(2)
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
        expect(cli.run(argv)).to eq(2)
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
        expect(cli.run(argv)).to eq(2)
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
