# encoding: utf-8

require 'fileutils'
require 'tmpdir'
require 'spec_helper'

module Rubocop
  describe CLI, :isolated_environment do
    include FileHelper

    let(:cli) { CLI.new }
    before(:each) { $stdout = StringIO.new }
    after(:each) { $stdout = STDOUT }

    it 'exits cleanly when -h is used' do
      expect { cli.run ['-h'] }.to exit_with_code(0)
      expect { cli.run ['--help'] }.to exit_with_code(0)
      message = ['Usage: rubocop [options] [file1, file2, ...]',
                 '    -d, --debug                      Display debug info',
                 '    -e, --emacs                      Emacs style output',
                 '    -c, --config FILE                Configuration file',
                 '        --only COP                   Run just one cop',
                 '    -s, --silent                     Silence summary',
                 '    -n, --no-color                   Disable color output',
                 '    -v, --version                    Display version']
      expect($stdout.string).to eq((message * 2).join("\n") + "\n")
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

    context 'when interrupted with Ctrl-C' do
      before do
        @interrupt_handlers = []
        Signal.stub(:trap).with('INT') do |&block|
          @interrupt_handlers << block
        end

        $stderr = StringIO.new

        create_file('example.rb', '# encoding: utf-8')
      end

      after do
        $stderr = STDERR
        @cli_thread.terminate if @cli_thread
      end

      def interrupt
        @interrupt_handlers.each(&:call)
      end

      def cli_run_in_thread
        @cli_thread = Thread.new do
          cli.run(['--debug'])
        end

        # Wait for start.
        loop { break unless $stdout.string.empty? }

        @cli_thread
      end

      it 'exits with status 1' do
        cli_thread = cli_run_in_thread
        interrupt
        expect(cli_thread.value).to eq(1)
      end

      it 'exits gracefully without dumping backtraces' do
        cli_thread = cli_run_in_thread
        interrupt
        cli_thread.join
        expect($stderr.string).not_to match(/from .+:\d+:in /)
      end

      context 'with Ctrl-C once' do
        it 'reports summary' do
          cli_thread = cli_run_in_thread
          interrupt
          cli_thread.join
          expect($stdout.string).to match(/files? inspected/)
        end
      end

      context 'with Ctrl-C twice' do
        it 'exits immediately' do
          Object.any_instance.should_receive(:exit!).with(1)
          cli_thread = cli_run_in_thread
          interrupt
          interrupt
          cli_thread.join
        end
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
                'C:  2: Trailing whitespace detected.',
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
      expect(cli.run(['--emacs', 'example1.rb', 'example2.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(
        ['example1.rb:1: C: Missing utf-8 encoding comment.',
         'example1.rb:1: C: Trailing whitespace detected.',
         "example1.rb:1: C: Surrounding space missing for operator '='.",
         'example1.rb:2: C: Trailing whitespace detected.',
         'example2.rb:1: C: Missing utf-8 encoding comment.',
         'example2.rb:1: C: Tab detected.',
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
      expect(cli.run(['--emacs', 'example1.rb', 'example2.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(
        ['example1.rb:1: C: Trailing whitespace detected.',
         "example1.rb:1: C: Surrounding space missing for operator '='.",
         'example1.rb:2: C: Trailing whitespace detected.',
         'example2.rb:1: C: Tab detected.',
         '',
         '2 files inspected, 4 offences detected',
         ''].join("\n"))
    end

    it 'runs just one cop if --only is passed' do
      create_file('example.rb', [
        'x= 0 ',
        'y '
      ])
      expect(cli.run(['--only', 'TrailingWhitespace', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(['== example.rb ==',
                'C:  1: Trailing whitespace detected.',
                'C:  2: Trailing whitespace detected.',
                '',
                '1 file inspected, 2 offences detected',
                ''].join("\n"))
    end

    it 'exits with error if an incorrect cop name is passed to --only' do
      expect(cli.run(%w(--only 123))).to eq(1)
      expect($stdout.string).to eq("Unrecognized cop name: 123.\n")
    end

    it 'ommits summary when --silent passed', ruby: 1.9 do
      create_file('example1.rb', 'puts 0 ')
      create_file('example2.rb', "\tputs 0")
      expect(cli.run(['--emacs',
                      '--silent',
                      'example1.rb',
                      'example2.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ['example1.rb:1: C: Missing utf-8 encoding comment.',
         'example1.rb:1: C: Trailing whitespace detected.',
         'example2.rb:1: C: Missing utf-8 encoding comment.',
         'example2.rb:1: C: Tab detected.',
         ''].join("\n"))
    end

    it 'ommits summary when --silent passed', ruby: 2.0 do
      create_file('example1.rb', 'puts 0 ')
      create_file('example2.rb', "\tputs 0")
      expect(cli.run(['--emacs',
                      '--silent',
                      'example1.rb',
                      'example2.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ['example1.rb:1: C: Trailing whitespace detected.',
         'example2.rb:1: C: Tab detected.',
         ''].join("\n"))
    end

    it 'shows cop names when --debug is passed', ruby: 2.0 do
      create_file('example1.rb', "\tputs 0")
      expect(cli.run(['--emacs',
                      '--silent',
                      '--debug',
                      'example1.rb'])).to eq(1)
      expect($stdout.string.lines[-1]).to eq(
        ['example1.rb:1: C: Tab: Tab detected.',
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
         'C:  1: Trailing whitespace detected.',
         '',
         '1 file inspected, 1 offence detected',
         ''].join("\n"))
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
         'C:  1: Trailing whitespace detected.',
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
         'C:  2: Line is too long. [90/79]',
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
         'C:  2: Line is too long. [90/79]',
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
         'C:  2: Line is too long. [90/79]',
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
         'C:  2: Line is too long. [90/79]',
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
      expect(cli.run(['--emacs', 'example.rb'])).to eq(1)
      unexpected_part = RUBY_VERSION >= '2.0' ? 'end-of-input' : '$end'
      expect($stdout.string).to eq(
        ["example.rb:3: E: Syntax error, unexpected #{unexpected_part}, " +
         'expecting keyword_end',
         '',
         '1 file inspected, 1 offence detected',
         ''].join("\n"))
    end

    it 'can process a file with an invalid UTF-8 byte sequence' do
      create_file('example.rb', [
        '# encoding: utf-8',
        "# \xf9\x29"
      ])
      expect(cli.run(['--emacs', 'example.rb'])).to eq(0)
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
      expect(cli.run(['--emacs', 'example.rb'])).to eq(1)
      # all cops were disabled, then 2 were enabled again, so we
      # should get 2 offences reported.
      expect($stdout.string).to eq(
        ['example.rb:8: C: Line is too long. [95/79]',
         "example.rb:10: C: Prefer single-quoted strings when you don't " +
         'need string interpolation or special symbols.',
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
      expect(cli.run(['--emacs', 'example.rb'])).to eq(1)
      # 3 cops were disabled, then 2 were enabled again, so we
      # should get 2 offences reported.
      expect($stdout.string).to eq(
        ['example.rb:8: C: Line is too long. [95/79]',
         "example.rb:10: C: Prefer single-quoted strings when you don't " +
         'need string interpolation or special symbols.',
         '',
         '1 file inspected, 2 offences detected',
         ''].join("\n"))
    end

    it 'can have all cops disabled on a single line' do
      create_file('example.rb', [
        '# encoding: utf-8',
        'y("123", 123456) # rubocop:disable all'
      ])
      expect(cli.run(['--emacs', 'example.rb'])).to eq(0)
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
      expect(cli.run(['--emacs', 'example.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ['example.rb:3: C: Line is too long. [95/79]',
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

    describe '#display_summary' do
      it 'handles pluralization correctly' do
        cli.display_summary(0, 0, [])
        expect($stdout.string).to eq(
          "\n0 files inspected, no offences detected\n")
        $stdout = StringIO.new
        cli.display_summary(1, 0, [])
        expect($stdout.string).to eq(
          "\n1 file inspected, no offences detected\n")
        $stdout = StringIO.new
        cli.display_summary(1, 1, [])
        expect($stdout.string).to eq(
          "\n1 file inspected, 1 offence detected\n")
        $stdout = StringIO.new
        cli.display_summary(2, 2, [])
        expect($stdout.string).to eq(
          "\n2 files inspected, 2 offences detected\n")
      end

      it 'displays an error message when errors are present' do
        msg = 'An error occurred while Encoding cop was inspecting file.rb.'
        cli.display_summary(1, 1, [msg])
        expect($stdout.string.lines.to_a[-4..-3])
          .to eq(["1 error occurred:\n", "#{msg}\n"])
      end
    end
  end
end
