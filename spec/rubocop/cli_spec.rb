# encoding: utf-8

require 'fileutils'
require 'tmpdir'
require 'spec_helper'

describe Rubocop::CLI, :isolated_environment do
  include FileHelper

  subject(:cli) { described_class.new }

  before(:each) do
    $stdout = StringIO.new
    $stderr = StringIO.new
    Rubocop::ConfigLoader.debug = false
  end

  after(:each) do
    $stdout = STDOUT
    $stderr = STDERR
  end

  def abs(path)
    File.expand_path(path)
  end

  describe 'option' do
    describe '--version' do
      it 'exits cleanly' do
        expect { cli.run ['-v'] }.to exit_with_code(0)
        expect { cli.run ['--version'] }.to exit_with_code(0)
        expect($stdout.string).to eq((Rubocop::Version::STRING + "\n") * 2)
      end
    end

    describe '--auto-correct' do
      it 'can correct two problems with blocks' do
        # {} should be do..end and space is missing.
        create_file('example.rb', ['# encoding: utf-8',
                                   '(1..10).each{ |i|',
                                   '  puts i',
                                   '}'])
        expect(cli.run(['--auto-correct'])).to eq(1)
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  '(1..10).each do |i|',
                  '  puts i',
                  'end'].join("\n") + "\n")
      end

      # In this example, the auto-correction (changing "raise" to "fail")
      # creates a new problem (alignment of parameters), which is also
      # corrected automatically.
      it 'can correct a problems and the problem it creates' do
        create_file('example.rb',
                    ['# encoding: utf-8',
                     'raise NotImplementedError,',
                     "      'Method should be overridden in child classes'"])
        expect(cli.run(['--auto-correct'])).to eq(1)
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  'fail NotImplementedError,',
                  "     'Method should be overridden in child classes'"]
                   .join("\n") + "\n")
        expect($stdout.string)
          .to eq(['Inspecting 1 file',
                  'C',
                  '',
                  'Offences:',
                  '',
                  'example.rb:2:1: C: [Corrected] Use `fail` instead of ' \
                  '`raise` to signal exceptions.',
                  'raise NotImplementedError,',
                  '^^^^^',
                  'example.rb:3:7: C: [Corrected] Align the parameters of a ' \
                  'method call if they span more than one line.',
                  "      'Method should be overridden in child classes'",
                  '      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',
                  '',
                  '1 file inspected, 2 offences detected, 2 offences ' \
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
        expect(cli.run(['--auto-correct'])).to eq(1)
        expect(IO.read('example.rb'))
          .to eq(['# encoding: utf-8',
                  '# Example class.',
                  'class Klass',
                  '  def f',
                  '  end',
                  'end'].join("\n") + "\n")
        expect($stderr.string).to eq('')
        expect($stdout.string)
          .to eq(['Inspecting 1 file',
                  'C',
                  '',
                  'Offences:',
                  '',
                  'example.rb:4:1: C: [Corrected] Trailing whitespace ' \
                  'detected.',
                  'example.rb:4:1: C: [Corrected] Extra empty line detected ' \
                  'at body beginning.',
                  '',
                  '1 file inspected, 2 offences detected, 2 offences ' \
                  'corrected',
                  ''].join("\n"))
      end
    end

    describe '--auto-gen-config' do
      it 'exits with error if asked to re-generate a todo list that is in ' \
        'use' do
        create_file('example1.rb', ['# encoding: utf-8',
                                    'x= 0 ',
                                    '#' * 85,
                                    'y ',
                                    'puts x'])
        todo_contents = ['# This configuration was generated with `rubocop' \
                         ' --auto-gen-config`',
                         '',
                         'LineLength:',
                         '  Enabled: false']
        create_file('rubocop-todo.yml', todo_contents)
        expect(IO.read('rubocop-todo.yml'))
          .to eq(todo_contents.join("\n") + "\n")
        create_file('.rubocop.yml', ['inherit_from: rubocop-todo.yml'])
        expect(cli.run(['--auto-gen-config'])).to eq(1)
        expect($stderr.string).to eq('Remove rubocop-todo.yml from the ' \
                                     'current configuration before ' +
                                     "generating it again.\n")
      end

      it 'exits with error if file arguments are given' do
        create_file('example1.rb', ['# encoding: utf-8',
                                    'x= 0 ',
                                    '#' * 85,
                                    'y ',
                                    'puts x'])
        expect(cli.run(['--auto-gen-config', 'example1.rb'])).to eq(1)
        expect($stderr.string)
          .to eq('--auto-gen-config can not be combined with any other ' \
                 "arguments.\n")
        expect($stdout.string).to eq('')
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
                                    'puts x'])
        expect(cli.run(['--auto-gen-config'])).to eq(1)
        expect($stderr.string).to eq('')
        expect($stdout.string)
          .to include([
                       'Created rubocop-todo.yml.',
                       'Run rubocop with --config rubocop-todo.yml, or',
                       'add inherit_from: rubocop-todo.yml in a ' \
                       '.rubocop.yml file.',
                       ''].join("\n"))
        expected =
          ['# This configuration was generated by `rubocop --auto-gen-config`',
           /# on .* using RuboCop version .*/,
           '# The point is for the user to remove these configuration records',
           '# one by one as the offences are removed from the code base.',
           '# Note that changes in the inspected code, or installation of new',
           '# versions of RuboCop, may require this file to be generated ' \
           'again.',
           '',
           '# Offence count: 1',
           '# Configuration parameters: AllowedVariables.',
           'GlobalVars:',
           '  Enabled: false',
           '',
           '# Offence count: 1',
           'IndentationConsistency:',
           '  Enabled: false',
           '',
           '# Offence count: 2',
           'LineLength:',
           '  Max: 90',
           '',
           '# Offence count: 1',
           '# Cop supports --auto-correct.',
           'SpaceAroundOperators:',
           '  Enabled: false',
           '',
           '# Offence count: 1',
           'Tab:',
           '  Enabled: false',
           '',
           '# Offence count: 2',
           '# Cop supports --auto-correct.',
           'TrailingWhitespace:',
           '  Enabled: false']
        actual = IO.read('rubocop-todo.yml').split($RS)
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
      it 'runs just one cop' do
        create_file('example.rb', ['if x== 0 ',
                                   "\ty",
                                   'end'])
        # IfUnlessModifier depends on the configuration of LineLength.

        expect(cli.run(['--format', 'simple',
                        '--only', 'IfUnlessModifier',
                        'example.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(['== example.rb ==',
                  'C:  1:  1: Favor modifier if usage when you ' \
                  'have a single-line body. Another good alternative is ' +
                  'the usage of control flow &&/||.',
                  '',
                  '1 file inspected, 1 offence detected',
                  ''].join("\n"))
      end
    end

    describe '--lint' do
      it 'runs only lint cops' do
        create_file('example.rb', ['if 0 ',
                                   "\ty",
                                   'end'])
        # IfUnlessModifier depends on the configuration of LineLength.

        expect(cli.run(['--format', 'simple', '--lint',
                        'example.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(['== example.rb ==',
                  'W:  1:  4: Literal 0 appeared in a condition.',
                  '',
                  '1 file inspected, 1 offence detected',
                  ''].join("\n"))
      end
    end

    describe '-d/--debug' do
      it 'shows config files' do
        create_file('example1.rb', "\tputs 0")
        expect(cli.run(['--debug', 'example1.rb'])).to eq(1)
        home = File.dirname(File.dirname(File.dirname(__FILE__)))
        expect($stdout.string.lines.grep(/configuration/).map(&:chomp))
          .to eq(["For #{abs('')}:" +
                  " configuration from #{home}/config/default.yml",
                  "Inheriting configuration from #{home}/config/enabled.yml",
                  "Inheriting configuration from #{home}/config/disabled.yml"
                 ])
      end

      it 'shows cop names' do
        create_file('example1.rb', "\tputs 0")
        expect(cli.run(['--format',
                        'emacs',
                        '--debug',
                        'example1.rb'])).to eq(1)
        expect($stdout.string.lines.to_a[-1])
          .to eq(["#{abs('example1.rb')}:1:1: C: Tab: Tab detected.",
                  ''].join("\n"))
      end
    end

    describe '-D/--display-cop-names' do
      it 'shows cop names' do
        create_file('example1.rb', "\tputs 0")
        expect(cli.run(['--format',
                        'emacs',
                        '--debug',
                        'example1.rb'])).to eq(1)
        expect($stdout.string.lines.to_a[-1])
          .to eq(["#{abs('example1.rb')}:1:1: C: Tab: Tab detected.",
                  ''].join("\n"))
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

      let(:cops) { Rubocop::Cop::Cop.all }

      let(:global_conf) do
        config_path =
          Rubocop::ConfigLoader.configuration_file_for(Dir.pwd.to_s)
        Rubocop::ConfigLoader.configuration_from_file(config_path)
      end

      let(:stdout) { $stdout.string }

      before do
        expect { cli.run ['--show-cops'] + cop_list }.to exit_with_code(0)
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
            current = types.delete(slice.shift[/Type '(?<c>[^'']+)'/, 'c'])
            # all cops in their type listing
            cops.with_type(current).each do |cop|
              expect(slice.any? { |l| l.include? cop.cop_name }).to be_true
            end

            # no cop in wrong type listing
            types.each do |type|
              cops.with_type(type).each do |cop|
                expect(slice.any? { |l| l.include? cop.cop_name }).to be_false
              end
            end
          end
        end

        include_examples :prints_config
      end

      context 'with one cop given' do
        let(:cop_list) { ['Tab'] }

        it 'prints that cop and nothing else' do
          expect(stdout).to eq(['Tab:',
                                '  Description: No hard tabs.',
                                '  Enabled: true',
                                '',
                                ''].join("\n"))
        end

        include_examples :prints_config
      end

      context 'with two cops given' do
        let(:cop_list) { ['Tab,LineLength'] }
        include_examples :prints_config
      end

      context 'with one of the cops misspelled' do
        let(:cop_list) { ['Tab,X123'] }

        it 'skips the unknown cop' do
          expect(stdout).to eq(['Tab:',
                                '  Description: No hard tabs.',
                                '  Enabled: true',
                                '',
                                ''].join("\n"))
        end
      end
    end

    describe '-f/--format' do
      let(:target_file) { 'example.rb' }

      before do
        create_file(target_file, [
                                  '# encoding: utf-8',
                                  '#' * 90
                                 ])
      end

      describe 'builtin formatters' do
        context 'when simple format is specified' do
          it 'outputs with simple format' do
            cli.run(['--format', 'simple', 'example.rb'])
            expect($stdout.string)
              .to include([
                           "== #{target_file} ==",
                           'C:  2: 80: Line is too long. [90/79]'
                          ].join("\n"))
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
                      "operator '='.",
                      'x= 0 ',
                      ' ^',
                      'example1.rb:2:5: C: Trailing whitespace detected.',
                      'x= 0 ',
                      '    ^',
                      'example1.rb:3:80: C: Line is too long. [85/79]',
                      '###################################################' \
                      '##################################',
                      '                                                   ' \
                      '                            ^^^^^^',
                      'example1.rb:4:2: C: Trailing whitespace detected.',
                      'y ',
                      ' ^',
                      'example2.rb:2:1: C: Tab detected.',
                      "\tx",
                      '^',
                      'example2.rb:3:1: C: Inconsistent indentation ' \
                      'detected.',
                      'def a',
                      '',
                      'example2.rb:4:1: C: Use 2 (not 3) spaces for ' \
                      'indentation.',
                      '   puts',
                      '^^^',
                      'example3.rb:2:5: C: Use snake_case for methods.',
                      'def badName',
                      '    ^^^^^^^',
                      'example3.rb:3:3: C: Favor modifier if usage ' \
                      'when you have a single-line body. Another good ' +
                      'alternative is the usage of control flow &&/||.',
                      '  if something',
                      '  ^^',
                      'example3.rb:5:5: W: end at 5, 4 is not aligned ' \
                      'with if at 3, 2',
                      '    end',
                      '    ^^^',
                      '',
                      '3 files inspected, 10 offences detected',
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
              ["#{abs('example1.rb')}:2:2: C: Surrounding space missing" +
               " for operator '='.",
               "#{abs('example1.rb')}:2:5: C: Trailing whitespace detected.",
               "#{abs('example1.rb')}:3:2: C: Trailing whitespace detected.",
               "#{abs('example2.rb')}:2:1: C: Tab detected.",
               "#{abs('example2.rb')}:3:1: C: Inconsistent indentation " +
               'detected.',
               ''].join("\n")
            expect($stdout.string).to eq(expected_output)
          end
        end

        context 'when unknown format name is specified' do
          it 'aborts with error message' do
            expect { cli.run(['--format', 'unknown', 'example.rb']) }
              .to exit_with_code(1)
            expect($stderr.string)
              .to include('No formatter for "unknown"')
          end
        end
      end

      describe 'custom formatter' do
        let(:target_file) { abs('example.rb') }

        context 'when a class name is specified' do
          it 'uses the class as a formatter' do
            module ::MyTool
              class RubocopFormatter < Rubocop::Formatter::BaseFormatter
                def started(all_files)
                  output.puts "started: #{all_files.join(',')}"
                end

                def file_started(file, options)
                  output.puts "file_started: #{file}"
                end

                def file_finished(file, offences)
                  output.puts "file_finished: #{file}"
                end

                def finished(processed_files)
                  output.puts "finished: #{processed_files.join(',')}"
                end
              end
            end

            cli.run(['--format', 'MyTool::RubocopFormatter', 'example.rb'])
            expect($stdout.string).to eq([
                                          "started: #{target_file}",
                                          "file_started: #{target_file}",
                                          "file_finished: #{target_file}",
                                          "finished: #{target_file}",
                                          ''
                                         ].join("\n"))
          end
        end

        context 'when unknown class name is specified' do
          it 'aborts with error message' do
            args = '--format UnknownFormatter example.rb'
            expect { cli.run(args.split) }.to exit_with_code(1)
            expect($stderr.string).to include('UnknownFormatter')
          end
        end
      end

      it 'can be used multiple times' do
        cli.run(['--format', 'simple', '--format', 'emacs', 'example.rb'])
        expect($stdout.string)
          .to include([
                       "== #{target_file} ==",
                       'C:  2: 80: Line is too long. [90/79]',
                       "#{abs(target_file)}:2:80: C: Line is too long. " +
                       '[90/79]'
                      ].join("\n"))
      end
    end

    describe '-o/--out option' do
      let(:target_file) { 'example.rb' }

      before do
        create_file(target_file, [
                                  '# encoding: utf-8',
                                  '#' * 90
                                 ])
      end

      it 'redirects output to the specified file' do
        cli.run(['--out', 'output.txt', target_file])
        expect(File.read('output.txt')).to include('Line is too long.')
      end

      it 'is applied to the previously specified formatter' do
        cli.run([
                 '--format', 'simple',
                 '--format', 'emacs', '--out', 'emacs_output.txt',
                 target_file
                ])

        expect($stdout.string).to eq([
                                      "== #{target_file} ==",
                                      'C:  2: 80: Line is too long. [90/79]',
                                      '',
                                      '1 file inspected, 1 offence detected',
                                      ''
                                     ].join("\n"))

        expect(File.read('emacs_output.txt'))
          .to eq("#{abs(target_file)}:2:80: C: Line is too long. [90/79]\n")
      end
    end
  end

  describe '#wants_to_quit?' do
    it 'is initially false' do
      expect(cli.wants_to_quit?).to be_false
    end

    context 'when true' do
      it 'returns 1' do
        create_file('example.rb', '# encoding: utf-8')
        cli.wants_to_quit = true
        expect(cli.run(['example.rb'])).to eq(1)
      end
    end
  end

  describe '#trap_interrupt' do
    before do
      @interrupt_handlers = []
      allow(Signal).to receive(:trap).with('INT') do |&block|
        @interrupt_handlers << block
      end
    end

    def interrupt
      @interrupt_handlers.each(&:call)
    end

    it 'adds a handler for SIGINT' do
      expect(@interrupt_handlers).to be_empty
      cli.trap_interrupt
      expect(@interrupt_handlers.size).to eq(1)
    end

    context 'with SIGINT once' do
      it 'sets #wants_to_quit? to true' do
        cli.trap_interrupt
        expect(cli.wants_to_quit?).to be_false
        interrupt
        expect(cli.wants_to_quit?).to be_true
      end

      it 'does not exit immediately' do
        expect_any_instance_of(Object).not_to receive(:exit)
        expect_any_instance_of(Object).not_to receive(:exit!)
        cli.trap_interrupt
        interrupt
      end
    end

    context 'with SIGINT twice' do
      it 'exits immediately' do
        expect_any_instance_of(Object).to receive(:exit!).with(1)
        cli.trap_interrupt
        interrupt
        interrupt
      end
    end
  end

  it 'checks a given correct file and returns 0' do
    create_file('example.rb', [
                               '# encoding: utf-8',
                               'x = 0',
                               'puts x'
                              ])
    expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
    expect($stdout.string)
      .to eq("\n1 file inspected, no offences detected\n")
  end

  it 'checks a given file with faults and returns 1' do
    create_file('example.rb', [
                               '# encoding: utf-8',
                               'x = 0 ',
                               'puts x'
                              ])
    expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq ['== example.rb ==',
              'C:  2:  6: Trailing whitespace detected.',
              '',
              '1 file inspected, 1 offence detected',
              ''].join("\n")
  end

  it 'registers an offence for a syntax error' do
    create_file('example.rb', [
                               '# encoding: utf-8',
                               'class Test',
                               'en'
                              ])
    expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:4:1: E: unexpected " +
              'token $end',
              ''].join("\n"))
  end

  it 'registers an offence for Parser warnings' do
    create_file('example.rb', [
                               '# encoding: utf-8',
                               'puts *test',
                               'if a then b else c end'
                              ])
    expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:2:6: W: " +
              'Ambiguous splat operator. Parenthesize the method arguments ' +
              "if it's surely a splat operator, or add a whitespace to the " +
              'right of the * if it should be a multiplication.',
              "#{abs('example.rb')}:3:1: C: " +
              'Favor the ternary operator (?:) over if/then/else/end ' +
              'constructs.',
              ''].join("\n"))
  end

  it 'can process a file with an invalid UTF-8 byte sequence' do
    create_file('example.rb', [
                               '# encoding: utf-8',
                               "# #{'f9'.hex.chr}#{'29'.hex.chr}"
                              ])
    expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:1:1: F: Invalid byte sequence in utf-8.",
              ''].join("\n"))
  end

  describe 'rubocop:disable comment' do
    it 'can disable all cops in a code section' do
      create_file('example.rb',
                  ['# encoding: utf-8',
                   '# rubocop:disable all',
                   '#' * 90,
                   'x(123456)',
                   'y("123")',
                   'def func',
                   '  # rubocop: enable LineLength, StringLiterals',
                   '  ' + '#' * 93,
                   '  x(123456)',
                   '  y("123")',
                   'end'])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      # all cops were disabled, then 2 were enabled again, so we
      # should get 2 offences reported.
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:8:80: C: Line is too long. [95/79]",
                "#{abs('example.rb')}:10:5: C: Prefer single-quoted " +
                "strings when you don't need string interpolation or " +
                'special symbols.',
                ''].join("\n"))
    end

    it 'can disable selected cops in a code section' do
      create_file('example.rb',
                  ['# encoding: utf-8',
                   '# rubocop:disable LineLength,NumericLiterals,' +
                   'StringLiterals',
                   '#' * 90,
                   'x(123456)',
                   'y("123")',
                   'def func',
                   '  # rubocop: enable LineLength, StringLiterals',
                   '  ' + '#' * 93,
                   '  x(123456)',
                   '  y("123")',
                   'end'])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      # 3 cops were disabled, then 2 were enabled again, so we
      # should get 2 offences reported.
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:8:80: C: Line is too long. [95/79]",
                "#{abs('example.rb')}:10:5: C: Prefer single-quoted " +
                "strings when you don't need string interpolation or " +
                'special symbols.',
                ''].join("\n"))
    end

    it 'can disable all cops on a single line' do
      create_file('example.rb', [
                                 '# encoding: utf-8',
                                 'y("123", 123456) # rubocop:disable all'
                                ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
      expect($stdout.string).to be_empty
    end

    it 'can disable selected cops on a single line' do
      create_file('example.rb',
                  [
                   '# encoding: utf-8',
                   '#' * 90 + ' # rubocop:disable LineLength',
                   '#' * 95,
                   'y("123") # rubocop:disable LineLength,StringLiterals'
                  ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(
               ["#{abs('example.rb')}:3:80: C: Line is too long. [95/79]",
                ''].join("\n"))
    end
  end

  it 'finds a file with no .rb extension but has a shebang line' do
    create_file('example', [
                            '#!/usr/bin/env ruby',
                            '# encoding: utf-8',
                            'x = 0',
                            'puts x'
                           ])
    expect(cli.run(%w(--format simple))).to eq(0)
    expect($stdout.string)
      .to eq(['', '1 file inspected, no offences detected', ''].join("\n"))
  end

  describe 'enabling/disabling rails cops' do
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
      expect($stdout.string).to include('Prefer self[:attribute]')
    end

    it 'with configation option true in one dir runs rails cops there' do
      create_file('dir1/app/models/example1.rb', ['# encoding: utf-8',
                                                 'read_attribute(:test)'])
      create_file('dir1/.rubocop.yml', [
                                        'AllCops:',
                                        '  RunRailsCops: true',
                                       ])
      create_file('dir2/app/models/example2.rb', ['# encoding: utf-8',
                                                  'read_attribute(:test)'])
      create_file('dir2/.rubocop.yml', [
                                        'AllCops:',
                                        '  RunRailsCops: false',
                                       ])
      expect(cli.run(['--format', 'simple', 'dir1', 'dir2'])).to eq(1)
      expect($stdout.string)
        .to eq(['== dir1/app/models/example1.rb ==',
                'C:  2:  1: Prefer self[:attribute] over read_attribute' +
                '(:attribute).',
                '',
                '2 files inspected, 1 offence detected',
                ''].join("\n"))
    end

    it 'with configation option false but -R given runs rails cops' do
      create_file('app/models/example1.rb', ['# encoding: utf-8',
                                             'read_attribute(:test)'])
      create_file('.rubocop.yml', [
                                   'AllCops:',
                                   '  RunRailsCops: false',
                                  ])
      expect(cli.run(['--format', 'simple', '-R', 'app/models/example1.rb']))
        .to eq(1)
      expect($stdout.string).to include('Prefer self[:attribute]')
    end
  end

  describe 'cops can exclude files based on config' do
    it 'ignores excluded files' do
      create_file('example.rb', [
                                 '# encoding: utf-8',
                                 'x = 0'
                                ])
      create_file('regexp.rb', [
                                '# encoding: utf-8',
                                'x = 0'
                               ])
      create_file('exclude_glob.rb', [
                                      '#!/usr/bin/env ruby',
                                      '# encoding: utf-8',
                                      'x = 0'
                                     ])
      create_file('dir/thing.rb', [
                                   '# encoding: utf-8',
                                   'x = 0'
                                  ])
      create_file('.rubocop.yml', [
                                   'UselessAssignment:',
                                   '  Exclude:',
                                   '    - example.rb',
                                   '    - !ruby/regexp /regexp.rb\z/',
                                   '    - "exclude_*"',
                                   '    - "dir/*"'
                                  ])
      expect(cli.run(%w(--format simple))).to eq(0)
      expect($stdout.string)
        .to eq(['', '4 files inspected, no offences detected',
                ''].join("\n"))
    end

  end

  describe 'configuration from file' do
    it 'finds included files' do
      create_file('example', [
                              '# encoding: utf-8',
                              'x = 0',
                              'puts x'
                             ])
      create_file('regexp', [
                             '# encoding: utf-8',
                             'x = 0',
                             'puts x'
                            ])
      create_file('.rubocop.yml', [
                                   'AllCops:',
                                   '  Includes:',
                                   '    - example',
                                   '    - !ruby/regexp /regexp$/'
                                  ])
      expect(cli.run(%w(--format simple))).to eq(0)
      expect($stdout.string)
        .to eq(['', '2 files inspected, no offences detected',
                ''].join("\n"))
    end

    it 'ignores excluded files' do
      create_file('example.rb', [
                                 '# encoding: utf-8',
                                 'x = 0',
                                 'puts x'
                                ])
      create_file('regexp.rb', [
                                '# encoding: utf-8',
                                'x = 0',
                                'puts x'
                               ])
      create_file('exclude_glob.rb', [
                                      '#!/usr/bin/env ruby',
                                      '# encoding: utf-8',
                                      'x = 0',
                                      'puts x'
                                     ])
      create_file('.rubocop.yml', [
                                   'AllCops:',
                                   '  Excludes:',
                                   '    - example.rb',
                                   '    - !ruby/regexp /regexp.rb$/',
                                   '    - "exclude_*"'
                                  ])
      expect(cli.run(%w(--format simple))).to eq(0)
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offences detected',
                ''].join("\n"))
    end

    # With rubinius 2.0.0.rc1 + rspec 2.13.1,
    # File.stub(:open).and_call_original causes SystemStackError.
    it 'does not read files in excluded list', broken: :rbx do
      %w(rb.rb non-rb.ext without-ext).each do |filename|
        create_file("example/ignored/#{filename}", [
                                                    '# encoding: utf-8',
                                                    '#' * 90
                                                   ])
      end

      create_file('example/.rubocop.yml', [
                                           'AllCops:',
                                           '  Excludes:',
                                           '    - ignored/**',
                                          ])
      expect(File).not_to receive(:open).with(%r(/ignored/))
      allow(File).to receive(:open).and_call_original
      expect(cli.run(%w(--format simple example))).to eq(0)
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offences detected',
                ''].join("\n"))
    end

    it 'can be configured with option to disable a certain error' do
      create_file('example1.rb', 'puts 0 ')
      create_file('rubocop.yml', [
                                  'Encoding:',
                                  '  Enabled: false',
                                  '',
                                  'CaseIndentation:',
                                  '  Enabled: false'
                                 ])
      expect(cli.run(['--format', 'simple',
                      '-c', 'rubocop.yml', 'example1.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  1:  7: Trailing whitespace detected.',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
    end

    it 'can disable parser-derived offences with warning severity' do
      # `-' interpreted as argument prefix
      create_file('example.rb', 'puts -1')
      create_file('.rubocop.yml', [
                                   'Encoding:',
                                   '  Enabled: false',
                                   '',
                                   'AmbiguousOperator:',
                                   '  Enabled: false'
                                  ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
    end

    it 'cannot disable Syntax offences with fatal/error severity' do
      create_file('example.rb', 'class Test')
      create_file('.rubocop.yml', [
                                   'Encoding:',
                                   '  Enabled: false',
                                   '',
                                   'Syntax:',
                                   '  Enabled: false'
                                  ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string).to include('unexpected token $end')
    end

    it 'can be configured to override a parameter that is a hash' do
      create_file('example1.rb',
                  ['# encoding: utf-8',
                   'arr.find_all { |e| e > 0 }.collect { |e| -e }'])
      # We only care about select over find_all. All other preferred methods
      # appearing in the default config are gone when we override
      # PreferredMethods. We get no report about collect.
      create_file('rubocop.yml',
                  ['CollectionMethods:',
                   '  PreferredMethods:',
                   '    find_all: select'])
      cli.run(['--format', 'simple', '-c', 'rubocop.yml', 'example1.rb'])
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  2:  5: Prefer select over find_all.',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
    end

    it 'works when a cop that others depend on is disabled' do
      create_file('example1.rb', ['if a',
                                  '  b',
                                  'end'])
      create_file('rubocop.yml', [
                                  'Encoding:',
                                  '  Enabled: false',
                                  '',
                                  'LineLength:',
                                  '  Enabled: false'
                                 ])
      result = cli.run(['--format', 'simple',
                        '-c', 'rubocop.yml', 'example1.rb'])
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  1:  1: Favor modifier if usage when you have ' +
                'a single-line body. Another good alternative is the ' +
                'usage of control flow &&/||.',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
      expect(result).to eq(1)
    end

    it 'can be configured with project config to disable a certain error' do
      create_file('example_src/example1.rb', 'puts 0 ')
      create_file('example_src/.rubocop.yml', [
                                               'Encoding:',
                                               '  Enabled: false',
                                               '',
                                               'CaseIndentation:',
                                               '  Enabled: false'
                                              ])
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(['== example_src/example1.rb ==',
                'C:  1:  7: Trailing whitespace detected.',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
    end

    it 'can use an alternative max line length from a config file' do
      create_file('example_src/example1.rb', [
                                              '# encoding: utf-8',
                                              '#' * 90
                                             ])
      create_file('example_src/.rubocop.yml', [
                                               'LineLength:',
                                               '  Enabled: true',
                                               '  Max: 100'
                                              ])
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(0)
      expect($stdout.string)
        .to eq(['', '1 file inspected, no offences detected', ''].join("\n"))
    end

    it 'can have different config files in different directories' do
      %w(src lib).each do |dir|
        create_file("example/#{dir}/example1.rb", [
                                                   '# encoding: utf-8',
                                                   '#' * 90
                                                  ])
      end
      create_file('example/src/.rubocop.yml', [
                                               'LineLength:',
                                               '  Enabled: true',
                                               '  Max: 100'
                                              ])
      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stdout.string).to eq(
                                   ['== example/lib/example1.rb ==',
                                    'C:  2: 80: Line is too long. [90/79]',
                                    '',
                                    '2 files inspected, 1 offence detected',
                                    ''].join("\n"))
    end

    it 'prefers a config file in ancestor directory to another in home' do
      create_file('example_src/example1.rb', [
                                              '# encoding: utf-8',
                                              '#' * 90
                                             ])
      create_file('example_src/.rubocop.yml', [
                                               'LineLength:',
                                               '  Enabled: true',
                                               '  Max: 100'
                                              ])
      create_file("#{Dir.home}/.rubocop.yml", [
                                               'LineLength:',
                                               '  Enabled: true',
                                               '  Max: 80'
                                              ])
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(0)
      expect($stdout.string)
        .to eq(['', '1 file inspected, no offences detected', ''].join("\n"))
    end

    it 'can exclude directories relative to .rubocop.yml' do
      %w(src etc/test etc/spec tmp/test tmp/spec).each do |dir|
        create_file("example/#{dir}/example1.rb", [
                                                   '# encoding: utf-8',
                                                   '#' * 90
                                                  ])
      end

      create_file('example/.rubocop.yml', [
                                           'AllCops:',
                                           '  Excludes:',
                                           '    - src/**',
                                           '    - etc/**',
                                           '    - tmp/spec/**'
                                          ])

      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stdout.string).to eq(
                                   ['== example/tmp/test/example1.rb ==',
                                    'C:  2: 80: Line is too long. [90/79]',
                                    '',
                                    '1 file inspected, 1 offence detected',
                                    ''].join("\n"))
    end

    it 'can exclude a typical vendor directory' do
      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/.rubocop.yml',
                  ['AllCops:',
                   '  Excludes:',
                   '    - lib/parser/lexer.rb'])

      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/lib/ex.rb',
                  ['# encoding: utf-8',
                   '#' * 90])

      create_file('.rubocop.yml',
                  ['AllCops:',
                   '  Excludes:',
                   '    - vendor/**'])

      cli.run(%w(--format simple))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offences detected',
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
                   '  Excludes:',
                   '    - vendor/**'])

      cli.run(%w(--format simple))
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offences detected',
                ''].join("\n"))
    end

    # Relative exclude paths in .rubocop.yml files are relative to that file,
    # but in configuration files with other names they will be relative to
    # whatever file inherits from them.
    it 'can exclude a vendor directory indirectly' do
      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/.rubocop.yml',
                  ['AllCops:',
                   '  Excludes:',
                   '    - lib/parser/lexer.rb'])

      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/lib/ex.rb',
                  ['# encoding: utf-8',
                   '#' * 90])

      create_file('.rubocop.yml',
                  ['inherit_from: config/default.yml'])

      create_file('config/default.yml',
                  ['AllCops:',
                   '  Excludes:',
                   '    - vendor/**'])

      cli.run(%w(--format simple))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offences detected',
                ''].join("\n"))
    end

    it 'prints a warning for an unrecognized cop name in .rubocop.yml' do
      create_file('example/example1.rb', [
                                          '# encoding: utf-8',
                                          '#' * 90
                                         ])

      create_file('example/.rubocop.yml', [
                                           'LyneLenth:',
                                           '  Enabled: true',
                                           '  Max: 100'
                                          ])

      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stderr.string)
        .to eq(
               ['Warning: unrecognized cop LyneLenth found in ' +
                abs('example/.rubocop.yml'),
                ''].join("\n"))
    end

    it 'prints a warning for an unrecognized configuration parameter' do
      create_file('example/example1.rb', [
                                          '# encoding: utf-8',
                                          '#' * 90
                                         ])

      create_file('example/.rubocop.yml', [
                                           'LineLength:',
                                           '  Enabled: true',
                                           '  Min: 10'
                                          ])

      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stderr.string)
        .to eq(
               ['Warning: unrecognized parameter LineLength:Min found in ' +
                abs('example/.rubocop.yml'),
                ''].join("\n"))
    end

    it 'works when a configuration file passed by -c specifies Excludes with regexp' do
      create_file('example/example1.rb', [
                                          '# encoding: utf-8',
                                          '#' * 90
                                         ])

      create_file('rubocop.yml', [
                                           'AllCops:',
                                           '  Excludes:',
                                           '    - !ruby/regexp /example1\.rb$/'
                                          ])

      cli.run(%w(--format simple -c rubocop.yml))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offences detected',
                ''].join("\n"))
    end

    it 'works when a configuration file passed by -c specifies Excludes with strings' do
      create_file('example/example1.rb', [
                                          '# encoding: utf-8',
                                          '#' * 90
                                         ])

      create_file('rubocop.yml', [
                                  'AllCops:',
                                  '  Excludes:',
                                  '    - example/**'
                                 ])

      cli.run(%w(--format simple -c rubocop.yml))
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offences detected',
                ''].join("\n"))
    end

    it 'works when a configuration file specifies a Severity' do
      create_file('example/example1.rb', [
                                          '# encoding: utf-8',
                                          '#' * 90
                                         ])

      create_file('rubocop.yml', [
                                  'LineLength:',
                                  '  Severity: error',
                                 ])

      cli.run(%w(--format simple -c rubocop.yml))
      expect($stdout.string)
        .to eq(['== example/example1.rb ==',
                'E:  2: 80: Line is too long. [90/79]',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
      expect($stderr.string).to eq('')
    end

    it 'fails when a configuration file specifies an invalid Severity' do
      create_file('example/example1.rb', [
                                          '# encoding: utf-8',
                                          '#' * 90
                                         ])

      create_file('rubocop.yml', [
                                  'LineLength:',
                                  '  Severity: superbad',
                                 ])

      cli.run(%w(--format simple -c rubocop.yml))
      expect($stderr.string)
        .to eq("Warning: Invalid severity 'superbad'. " +
               'Valid severities are refactor, convention, ' +
               "warning, error, fatal.\n")
    end
  end
end
