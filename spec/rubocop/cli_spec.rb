# encoding: utf-8

require 'fileutils'
require 'tmpdir'
require 'spec_helper'

module Rubocop
  describe CLI, :isolated_environment do
    include FileHelper

    let(:cli) { CLI.new }

    before(:each) do
      $stdout = StringIO.new
      $stderr = StringIO.new
    end

    after(:each) do
      $stdout = STDOUT
      $stderr = STDERR
    end

    def abs(path)
      File.expand_path(path)
    end

    it 'exits cleanly when -h is used' do
      expect { cli.run ['-h'] }.to exit_with_code(0)
      expect { cli.run ['--help'] }.to exit_with_code(0)
      message = <<-END
Usage: rubocop [options] [file1, file2, ...]
    -d, --debug                      Display debug info.
    -c, --config FILE                Specify configuration file.
        --only COP                   Run just one cop.
    -f, --format FORMATTER           Choose a formatter.
                                       [s]imple (default)
                                       [d]etails
                                       [p]rogress
                                       [e]macs
                                       [j]son
                                       custom formatter class name
    -o, --out FILE                   Write output to a file instead of STDOUT.
                                       This option applies to the previously
                                       specified --format, or the default
                                       format if no format is specified.
    -r, --require FILE               Require Ruby file.
    -R, --rails                      Run extra Rails cops.
    -a, --auto-correct               Auto-correct offences.
    -s, --silent                     Silence summary.
    -n, --no-color                   Disable color output.
    -v, --version                    Display version.
    -V, --verbose-version            Display verbose version.
      END
      expect($stdout.string).to eq(message * 2)
    end

    it 'exits cleanly when -v is used' do
      expect { cli.run ['-v'] }.to exit_with_code(0)
      expect { cli.run ['--version'] }.to exit_with_code(0)
      expect($stdout.string).to eq((Rubocop::Version::STRING + "\n") * 2)
    end

    describe '#wants_to_quit?' do
      it 'is initially false' do
        expect(cli.wants_to_quit?).to be_false
      end
    end

    describe '#trap_interrupt' do
      before do
        @interrupt_handlers = []
        Signal.stub(:trap).with('INT') do |&block|
          @interrupt_handlers << block
        end
      end

      def interrupt
        @interrupt_handlers.each(&:call)
      end

      it 'adds a handler for SIGINT' do
        expect(@interrupt_handlers).to be_empty
        cli.trap_interrupt
        expect(@interrupt_handlers).to have(1).item
      end

      context 'with SIGINT once' do
        it 'sets #wants_to_quit? to true' do
          cli.trap_interrupt
          expect(cli.wants_to_quit?).to be_false
          interrupt
          expect(cli.wants_to_quit?).to be_true
        end

        it 'does not exit immediately' do
          Object.any_instance.should_not_receive(:exit)
          Object.any_instance.should_not_receive(:exit!)
          cli.trap_interrupt
          interrupt
        end
      end

      context 'with SIGINT twice' do
        it 'exits immediately' do
          Object.any_instance.should_receive(:exit!).with(1)
          cli.trap_interrupt
          interrupt
          interrupt
        end
      end
    end

    context 'when #wants_to_quit? is true' do
      it 'returns 1' do
        create_file('example.rb', '# encoding: utf-8')
        cli.wants_to_quit = true
        expect(cli.run(['example.rb'])).to eq(1)
      end
    end

    it 'checks a given correct file and returns 0' do
      create_file('example.rb', [
        '# encoding: utf-8',
        'x = 0',
        'puts x'
      ])
      expect(cli.run(['example.rb'])).to eq(0)
      expect($stdout.string)
        .to eq("\n1 file inspected, no offences detected\n")
    end

    it 'checks a given file with faults and returns 1' do
      create_file('example.rb', [
        '# encoding: utf-8',
        'x = 0 ',
        'puts x'
      ])
      expect(cli.run(['example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq ['== example.rb ==',
                'C:  2:  5: Trailing whitespace detected.',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n")
    end

    it 'can report in emacs style', ruby: 1.9 do
      create_file('example1.rb', [
        'x= 0 ',
        'y ',
        'puts x'
      ])
      create_file('example2.rb', [
        "\tx = 0",
        'puts x'
      ])
      expect(cli.run(['--format', 'emacs', 'example1.rb', 'example2.rb']))
        .to eq(1)
      expect($stdout.string)
        .to eq(
        ["#{abs('example1.rb')}:1:0: C: Missing utf-8 encoding comment.",
         "#{abs('example1.rb')}:1:1: C: Surrounding space missing" +
         " for operator '='.",
         "#{abs('example1.rb')}:1:4: C: Trailing whitespace detected.",
         "#{abs('example1.rb')}:2:1: C: Trailing whitespace detected.",
         "#{abs('example2.rb')}:1:0: C: Missing utf-8 encoding comment.",
         "#{abs('example2.rb')}:1:0: C: Tab detected.",
         '',
         '2 files inspected, 6 offences detected',
         ''].join("\n"))
    end

    it 'can report in emacs style', ruby: 2.0 do
      create_file('example1.rb', [
        'x= 0 ',
        'y ',
        'puts x'
      ])
      create_file('example2.rb', [
        "\tx = 0",
        'puts x'
      ])
      expect(cli.run(['--format', 'emacs', 'example1.rb', 'example2.rb']))
        .to eq(1)
      expect($stdout.string)
        .to eq(
        ["#{abs('example1.rb')}:1:1: C: Surrounding space missing" +
         " for operator '='.",
         "#{abs('example1.rb')}:1:4: C: Trailing whitespace detected.",
         "#{abs('example1.rb')}:2:1: C: Trailing whitespace detected.",
         "#{abs('example2.rb')}:1:0: C: Tab detected.",
         '',
         '2 files inspected, 4 offences detected',
         ''].join("\n"))
    end

    it 'can report with detailed information' do
      create_file('example1.rb', ['# encoding: utf-8',
                                  'x= 0 ',
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', ['# encoding: utf-8',
                                  "\tx = 0",
                                  'puts x'])
      expect(cli.run(['--format', 'details', 'example1.rb', 'example2.rb']))
        .to eq(1)
      expect($stdout.string)
        .to eq(["== #{abs('example1.rb')} ==",
                'example1.rb:2:1: C: Surrounding space missing for operator ' +
                "'='.",
                'x= 0 ',
                ' ^',
                '',
                'example1.rb:2:4: C: Trailing whitespace detected.',
                'x= 0 ',
                '    ^',
                '',
                'example1.rb:3:1: C: Trailing whitespace detected.',
                'y ',
                ' ^',
                '',
                "== #{abs('example2.rb')} ==",
                'example2.rb:2:0: C: Tab detected.',
                "\tx = 0",
                '^',
                '',
                '',
                '2 files inspected, 4 offences detected',
                ''].join("\n"))
    end

    it 'runs just one cop if --only is passed' do
      create_file('example.rb', ['if x== 0 ',
                                 "\ty",
                                 'end'])
      # IfUnlessModifier depends on the configuration of LineLength.
      # That configuration might have been set by other spec examples
      # so we reset it to emulate a start from scratch.
      Cop::LineLength.config = nil

      expect(cli.run(['--only', 'IfUnlessModifier', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(['== example.rb ==',
                'C:  1:  0: Favor modifier if/unless usage when you have a ' +
                'single-line body. Another good alternative is the usage of ' +
                'control flow &&/||.',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
    end

    it 'exits with error if an incorrect cop name is passed to --only' do
      expect(cli.run(%w(--only 123))).to eq(1)
      expect($stderr.string).to eq("Unrecognized cop name: 123.\n")
    end

    it 'ommits summary when --silent passed', ruby: 1.9 do
      create_file('example1.rb', 'puts 0 ')
      create_file('example2.rb', "\tputs 0")
      expect(cli.run(['--format',
                      'emacs',
                      '--silent',
                      'example1.rb',
                      'example2.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ["#{abs('example1.rb')}:1:0: C: Missing utf-8 encoding comment.",
         "#{abs('example1.rb')}:1:6: C: Trailing whitespace detected.",
         "#{abs('example2.rb')}:1:0: C: Missing utf-8 encoding comment.",
         "#{abs('example2.rb')}:1:0: C: Tab detected.",
         ''].join("\n"))
    end

    it 'ommits summary when --silent passed', ruby: 2.0 do
      create_file('example1.rb', 'puts 0 ')
      create_file('example2.rb', "\tputs 0")
      expect(cli.run(['--format',
                      'emacs',
                      '--silent',
                      'example1.rb',
                      'example2.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ["#{abs('example1.rb')}:1:6: C: Trailing whitespace detected.",
         "#{abs('example2.rb')}:1:0: C: Tab detected.",
         ''].join("\n"))
    end

    it 'shows cop names when --debug is passed', ruby: 2.0 do
      create_file('example1.rb', "\tputs 0")
      expect(cli.run(['--format',
                      'emacs',
                      '--silent',
                      '--debug',
                      'example1.rb'])).to eq(1)
      expect($stdout.string.lines[-1]).to eq(
        ["#{abs('example1.rb')}:1:0: C: Tab: Tab detected.",
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
      expect(cli.run(['-c', 'rubocop.yml', 'example1.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ['== example1.rb ==',
         'C:  1:  6: Trailing whitespace detected.',
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
      result = cli.run(['-c', 'rubocop.yml', 'example1.rb'])
      expect($stdout.string).to eq(
        ['== example1.rb ==',
         'C:  1:  0: Favor modifier if/unless usage when you have a ' +
         'single-line body. Another good alternative is the usage of ' +
         'control flow &&/||.',
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
      expect(cli.run(['example_src/example1.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ['== example_src/example1.rb ==',
         'C:  1:  6: Trailing whitespace detected.',
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
      expect(cli.run(['example_src/example1.rb'])).to eq(0)
      expect($stdout.string).to eq(
        ['', '1 file inspected, no offences detected',
         ''].join("\n"))
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
      expect(cli.run(['example'])).to eq(1)
      expect($stdout.string).to eq(
        ['== example/lib/example1.rb ==',
         'C:  2: 79: Line is too long. [90/79]',
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
      expect(cli.run(['example_src/example1.rb'])).to eq(0)
      expect($stdout.string).to eq(
        ['', '1 file inspected, no offences detected',
         ''].join("\n"))
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

      expect(cli.run(['example'])).to eq(1)
      expect($stdout.string).to eq(
        ['== example/tmp/test/example1.rb ==',
         'C:  2: 79: Line is too long. [90/79]',
         '',
         '1 file inspected, 1 offence detected',
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

      expect(cli.run(['example'])).to eq(1)
      expect($stdout.string).to eq(
        ['Warning: unrecognized cop LyneLenth found in ' +
         File.expand_path('example/.rubocop.yml'),
         '== example/example1.rb ==',
         'C:  2: 79: Line is too long. [90/79]',
         '',
         '1 file inspected, 1 offence detected',
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

      expect(cli.run(['example'])).to eq(1)
      expect($stdout.string).to eq(
        ['Warning: unrecognized parameter LineLength:Min found in ' +
         File.expand_path('example/.rubocop.yml'),
         '== example/example1.rb ==',
         'C:  2: 79: Line is too long. [90/79]',
         '',
         '1 file inspected, 1 offence detected',
         ''].join("\n"))
    end

    it 'registers an offence for a syntax error' do
      create_file('example.rb', [
        '# encoding: utf-8',
        'class Test',
        'en'
      ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:3:2: E: unexpected " +
                'token $end',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
    end

    it 'registers an offence for Parser warnings' do
      create_file('example.rb', [
                                 '# encoding: utf-8',
                                 'puts *test'
                                ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:2:5: W: " +
                "`*' interpreted as argument prefix",
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
    end

    it 'can report other errors together with syntax errors in some cases' do
      create_file('example.rb', [
        '',
        'class Test >',
        '  x=0',
                                 'end',
                                 ''
      ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)

      expected =
        ["#{abs('example.rb')}:2:11: E: unexpected token tGT"]
      if RUBY_ENGINE == 'ruby'
        if RUBY_VERSION < '2'
          expected.unshift("#{abs('example.rb')}:1:0: C: Missing utf-8 " +
                           'encoding comment.')
        end
        expected.push("#{abs('example.rb')}:3:3: C: Surrounding space " +
                      "missing for operator '='.")
      end
      expected.concat(['',
                       "1 file inspected, #{expected.size} " +
                       "offence#{'s' unless expected.size == 1} detected",
                       ''])

      expect($stdout.string).to eq(expected.join("\n"))
    end

    it 'can process a file with an invalid UTF-8 byte sequence' do
      pending
      create_file('example.rb', [
        '# encoding: utf-8',
        "# #{'f9'.hex.chr}#{'29'.hex.chr}"
      ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
    end

    it 'can have all cops disabled in a code section' do
      create_file('example.rb', [
        '# encoding: utf-8',
        '# rubocop:disable all',
        '#' * 90,
        'x(123456)',
        'y("123")',
        'def func',
        '  # rubocop: enable LineLength, StringLiterals',
        '  ' + '#' * 93,
        '  x(123456)',
        '  y("123")',
        'end'
      ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      # all cops were disabled, then 2 were enabled again, so we
      # should get 2 offences reported.
      expect($stdout.string).to eq(
        ["#{abs('example.rb')}:8:79: C: Line is too long. [95/79]",
         "#{abs('example.rb')}:10:4: C: Prefer single-quoted strings when " +
         "you don't need string interpolation or special symbols.",
         '',
         '1 file inspected, 2 offences detected',
         ''].join("\n"))
    end

    it 'can have selected cops disabled in a code section' do
      create_file('example.rb', [
        '# encoding: utf-8',
        '# rubocop:disable LineLength,NumericLiterals,StringLiterals',
        '#' * 90,
        'x(123456)',
        'y("123")',
        'def func',
        '  # rubocop: enable LineLength, StringLiterals',
        '  ' + '#' * 93,
        '  x(123456)',
        '  y("123")',
        'end'
      ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      # 3 cops were disabled, then 2 were enabled again, so we
      # should get 2 offences reported.
      expect($stdout.string).to eq(
        ["#{abs('example.rb')}:8:79: C: Line is too long. [95/79]",
         "#{abs('example.rb')}:10:4: C: Prefer single-quoted strings when " +
         "you don't need string interpolation or special symbols.",
         '',
         '1 file inspected, 2 offences detected',
         ''].join("\n"))
    end

    it 'can have all cops disabled on a single line' do
      create_file('example.rb', [
        '# encoding: utf-8',
        'y("123", 123456) # rubocop:disable all'
      ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
      expect($stdout.string).to eq(
        ['',
         '1 file inspected, no offences detected',
         ''].join("\n"))
    end

    it 'can have selected cops disabled on a single line' do
      create_file('example.rb', [
        '# encoding: utf-8',
        '#' * 90 + ' # rubocop:disable LineLength',
        '#' * 95,
        'y("123") # rubocop:disable LineLength,StringLiterals'
      ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ["#{abs('example.rb')}:3:79: C: Line is too long. [95/79]",
         '',
         '1 file inspected, 1 offence detected',
         ''].join("\n"))
    end

    it 'finds a file with no .rb extension but has a shebang line' do
      create_file('example', [
        '#!/usr/bin/env ruby',
        '# encoding: utf-8',
        'x = 0',
        'puts x'
      ])
      # Need to pass an empty array explicitly
      # so that the CLI does not refer arguments of `rspec`
      expect(cli.run([])).to eq(0)
      expect($stdout.string).to eq(
        ['', '1 file inspected, no offences detected',
         ''].join("\n"))
    end

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
      # Need to pass an empty array explicitly
      # so that the CLI does not refer arguments of `rspec`
      expect(cli.run([])).to eq(0)
      expect($stdout.string).to eq(
        ['', '2 files inspected, no offences detected',
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
      # Need to pass an empty array explicitly
      # so that the CLI does not refer arguments of `rspec`
      expect(cli.run([])).to eq(0)
      expect($stdout.string).to eq(
        ['', '0 files inspected, no offences detected',
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
      File.should_not_receive(:open).with(%r(/ignored/))
      File.stub(:open).and_call_original
      expect(cli.run(['example'])).to eq(0)
      expect($stdout.string).to eq(
        ['', '0 files inspected, no offences detected',
         ''].join("\n"))
    end

    describe '--require option' do
      let(:required_file_path) { './path/to/required_file.rb' }

      before do
        create_file('example.rb', '# encoding: utf-8')

        create_file(required_file_path, [
          '# encoding: utf-8',
          "puts 'Hello from required file!'"
        ])
      end

      it 'requires the passed path' do
        cli.run(['--require', required_file_path, 'example.rb'])
        expect($stdout.string).to start_with('Hello from required file!')
      end
    end

    describe '-f/--format option' do
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
            expect($stdout.string).to include([
              "== #{target_file} ==",
              'C:  2: 79: Line is too long. [90/79]'
            ].join("\n"))
          end
        end

        context 'when emacs format is specified' do
          it 'outputs with emacs format' do
            cli.run(['--format', 'emacs', 'example.rb'])
            expect($stdout.string).to include(
              "#{abs(target_file)}:2:79: C: Line is too long. [90/79]")
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
            expect { cli.run(['--format', 'UnknownFormatter', 'example.rb']) }
              .to exit_with_code(1)
            expect($stderr.string).to include('UnknownFormatter')
          end
        end
      end

      it 'can be used multiple times' do
        cli.run(['--format', 'simple', '--format', 'emacs', 'example.rb'])
        expect($stdout.string).to include([
          "== #{target_file} ==",
          'C:  2: 79: Line is too long. [90/79]',
          "#{abs(target_file)}:2:79: C: Line is too long. [90/79]"
        ].join("\n"))
      end
    end

    unless Rubocop::Version::STRING.start_with?('0')
      describe '-e/--emacs option' do
        it 'is dropped in RuboCop 1.0.0' do
          # This spec can be removed once the option is dropped.
          expect(cli.run(['--emacs'])).to eq(1)
          expect($stderr.string).to include('invalid option: --emacs')
        end
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
          'C:  2: 79: Line is too long. [90/79]',
          '',
          '1 file inspected, 1 offence detected',
          ''
        ].join("\n"))

        expect(File.read('emacs_output.txt')).to eq([
          "#{abs(target_file)}:2:79: C: Line is too long. [90/79]",
          '',
          '1 file inspected, 1 offence detected',
          ''
        ].join("\n"))
      end
    end

    describe '#display_error_summary' do
      it 'displays an error message when errors are present' do
        msg = 'An error occurred while Encoding cop was inspecting file.rb.'
        cli.display_error_summary([msg])
        expect($stdout.string.lines.to_a[-6..-5])
          .to eq(["1 error occurred:\n", "#{msg}\n"])
      end
    end

    describe '#custom_formatter_class' do
      def custom_formatter_class(string)
        cli.send(:custom_formatter_class, string)
      end

      it 'returns constant represented by the passed string' do
        expect(custom_formatter_class('Rubocop')).to eq(Rubocop)
      end

      it 'can handle namespaced constant name' do
        expect(custom_formatter_class('Rubocop::CLI')).to eq(Rubocop::CLI)
      end

      it 'can handle top level namespaced constant name' do
        expect(custom_formatter_class('::Rubocop::CLI')).to eq(Rubocop::CLI)
      end

      context 'when non-existent constant name is passed' do
        it 'raises error' do
          expect { custom_formatter_class('Rubocop::NonExistentClass') }
            .to raise_error(NameError)
        end
      end
    end
  end
end
