# encoding: utf-8

require 'fileutils'
require 'tmpdir'
require 'spec_helper'

module Rubocop
  describe CLI do
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
      end

      after do
        $stderr = STDERR
        @cli_thread.terminate if @cli_thread

        # Workaround for not to break cop specs,
        # since Cop#add_offence checks if $options[:debug].
        $options = {}
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
      File.open('example.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts 'x = 0'
        f.puts 'puts x'
      end
      begin
        expect(cli.run(['example.rb'])).to eq(0)
        expect($stdout.string)
          .to eq("\n1 file inspected, no offences detected\n")
      ensure
        File.delete 'example.rb'
      end
    end

    it 'checks a given file with faults and returns 1' do
      File.open('example.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts 'x = 0 '
        f.puts 'puts x'
      end
      begin
        expect(cli.run(['example.rb'])).to eq(1)
        expect($stdout.string)
          .to eq ['== example.rb ==',
                  'C:  2: Trailing whitespace detected.',
                  '',
                  '1 file inspected, 1 offence detected',
                  ''].join("\n")
      ensure
        File.delete 'example.rb'
      end
    end

    it 'can report in emacs style', ruby: 1.9 do
      File.open('example1.rb', 'w') { |f| f.puts 'x= 0 ', 'y ', 'puts x' }
      File.open('example2.rb', 'w') { |f| f.puts "\tx = 0", 'puts x' }
      begin
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
      ensure
        File.delete 'example1.rb'
        File.delete 'example2.rb'
      end
    end

    it 'can report in emacs style', ruby: 2.0 do
      File.open('example1.rb', 'w') { |f| f.puts 'x= 0 ', 'y ', 'puts x' }
      File.open('example2.rb', 'w') { |f| f.puts "\tx = 0", 'puts x' }
      begin
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
      ensure
        File.delete 'example1.rb'
        File.delete 'example2.rb'
      end
    end

    it 'ommits summary when --silent passed', ruby: 1.9 do
      File.open('example1.rb', 'w') { |f| f.puts 'puts 0 ' }
      File.open('example2.rb', 'w') { |f| f.puts "\tputs 0" }
      begin
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
      ensure
        File.delete 'example1.rb'
        File.delete 'example2.rb'
      end
    end

    it 'ommits summary when --silent passed', ruby: 2.0 do
      File.open('example1.rb', 'w') { |f| f.puts 'puts 0 ' }
      File.open('example2.rb', 'w') { |f| f.puts "\tputs 0" }
      begin
        expect(cli.run(['--emacs',
                        '--silent',
                        'example1.rb',
                        'example2.rb'])).to eq(1)
        expect($stdout.string).to eq(
          ['example1.rb:1: C: Trailing whitespace detected.',
           'example2.rb:1: C: Tab detected.',
           ''].join("\n"))
      ensure
        File.delete 'example1.rb'
        File.delete 'example2.rb'
      end
    end

    it 'shows cop names when --debug is passed', ruby: 2.0 do
      File.open('example1.rb', 'w') { |f| f.puts "\tputs 0" }
      begin
        expect(cli.run(['--emacs',
                        '--silent',
                        '--debug',
                        'example1.rb'])).to eq(1)
        expect($stdout.string.lines[-1]).to eq(
          ['example1.rb:1: C: Tab: Tab detected.',
           ''].join("\n"))
      ensure
        File.delete 'example1.rb'
      end
    end

    it 'can be configured with option to disable a certain error' do
      File.open('example1.rb', 'w') { |f| f.puts 'puts 0 ' }
      File.open('rubocop.yml', 'w') do |f|
        f.puts('Encoding:',
               '  Enabled: false',
               '',
               'CaseIndentation:',
               '  Enabled: false')
      end
      begin
        expect(cli.run(['-c', 'rubocop.yml', 'example1.rb'])).to eq(1)
        expect($stdout.string).to eq(
          ['== example1.rb ==',
           'C:  1: Trailing whitespace detected.',
           '',
           '1 file inspected, 1 offence detected',
           ''].join("\n"))
      ensure
        File.delete 'example1.rb'
        File.delete 'rubocop.yml'
      end
    end

    it 'can be configured with project config to disable a certain error' do
      FileUtils.mkdir 'example_src'
      File.open('example_src/example1.rb', 'w') { |f| f.puts 'puts 0 ' }
      File.open('example_src/.rubocop.yml', 'w') do |f|
        f.puts('Encoding:',
               '  Enabled: false',
               '',
               'CaseIndentation:',
               '  Enabled: false')
      end
      begin
        expect(cli.run(['example_src/example1.rb'])).to eq(1)
        expect($stdout.string).to eq(
          ['== example_src/example1.rb ==',
           'C:  1: Trailing whitespace detected.',
           '',
           '1 file inspected, 1 offence detected',
           ''].join("\n"))
      ensure
        FileUtils.rm_rf 'example_src'
      end
    end

    it 'can use an alternative max line length from a config file' do
      FileUtils.mkdir 'example_src'
      File.open('example_src/example1.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts '#' * 90
      end
      File.open('example_src/.rubocop.yml', 'w') do |f|
        f.puts('LineLength:',
               '  Enabled: true',
               '  Max: 100')
      end
      begin
        expect(cli.run(['example_src/example1.rb'])).to eq(0)
        expect($stdout.string).to eq(
          ['', '1 file inspected, no offences detected',
           ''].join("\n"))
      ensure
        FileUtils.rm_rf 'example_src'
      end
    end

    it 'can have different config files in different directories' do
      %w(src lib).each do |dir|
        FileUtils.mkdir_p "example/#{dir}"
        File.open("example/#{dir}/example1.rb", 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts '#' * 90
        end
      end
      File.open('example/src/.rubocop.yml', 'w') do |f|
        f.puts('LineLength:',
               '  Enabled: true',
               '  Max: 100')
      end
      begin
        expect(cli.run(['example'])).to eq(1)
        expect($stdout.string).to eq(
          ['== example/lib/example1.rb ==',
           'C:  2: Line is too long. [90/79]',
           '',
           '2 files inspected, 1 offence detected',
           ''].join("\n"))
      ensure
        FileUtils.rm_rf 'example'
      end
    end

    it 'prefers a config file in ancestor directory to another in home' do
      FileUtils.mkdir 'example_src'
      File.open('example_src/example1.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts '#' * 90
      end
      File.open('example_src/.rubocop.yml', 'w') do |f|
        f.puts('LineLength:',
               '  Enabled: true',
               '  Max: 100')
      end
      Dir.mktmpdir do |tmpdir|
        @original_home = ENV['HOME']
        ENV['HOME'] = tmpdir
        File.open("#{Dir.home}/.rubocop.yml", 'w') do |f|
          f.puts('LineLength:',
                 '  Enabled: true',
                 '  Max: 80')
        end
        begin
          expect(cli.run(['example_src/example1.rb'])).to eq(0)
          expect($stdout.string).to eq(
            ['', '1 file inspected, no offences detected',
             ''].join("\n"))
        ensure
          FileUtils.rm_rf 'example_src'
          ENV['HOME'] = @original_home
        end
      end
    end

    it 'Can exclude directories relative to .rubocop.yml' do
      %w(src etc/test etc/spec tmp/test tmp/spec).each do |dir|
        FileUtils.mkdir_p "example/#{dir}"
        File.open("example/#{dir}/example1.rb", 'w') do |f|
          f.puts '# encoding: utf-8'
          f.puts '#' * 90
        end
      end

      File.open('example/.rubocop.yml', 'w') do |f|
        f.puts('AllCops:',
               '  NoGoZone:',
               '    - src',
               '    - etc',
               '    - tmp/spec')
      end

      begin
        expect(cli.run(['example'])).to eq(1)
        expect($stdout.string).to eq(
          ['== example/tmp/test/example1.rb ==',
           'C:  2: Line is too long. [90/79]',
           '',
           '1 file inspected, 1 offence detected',
           ''].join("\n"))
      ensure
        FileUtils.rm_rf 'example'
      end
    end

    it 'prints a warning for an unrecognized cop name in .rubocop.yml' do
      FileUtils.mkdir_p 'example'
      File.open('example/example1.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts '#' * 90
      end

      File.open('example/.rubocop.yml', 'w') do |f|
        f.puts('LyneLenth:',
               '  Enabled: true',
               '  Max: 100')
      end

      begin
        expect(cli.run(['example'])).to eq(1)
        expect($stdout.string).to eq(
          ['Warning: unrecognized cop LyneLenth found in example/' +
           '.rubocop.yml',
           '== example/example1.rb ==',
           'C:  2: Line is too long. [90/79]',
           '',
           '1 file inspected, 1 offence detected',
           ''].join("\n"))
      ensure
        FileUtils.rm_rf 'example'
      end
    end

    it 'prints a warning for an unrecognized configuration parameter' do
      FileUtils.mkdir_p 'example'
      File.open('example/example1.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts '#' * 90
      end

      File.open('example/.rubocop.yml', 'w') do |f|
        f.puts('LineLength:',
               '  Enabled: true',
               '  Min: 10')
      end

      begin
        expect(cli.run(['example'])).to eq(1)
        expect($stdout.string).to eq(
          ['Warning: unrecognized parameter LineLength:Min found in ' +
           'example/.rubocop.yml',
           '== example/example1.rb ==',
           'C:  2: Line is too long. [90/79]',
           '',
           '1 file inspected, 1 offence detected',
           ''].join("\n"))
      ensure
        FileUtils.rm_rf 'example'
      end
    end

    it 'finds no violations when checking the rubocop source code' do
      # Need to pass an empty array explicitly
      # so that the CLI does not refer arguments of `rspec`
      cli.run([])
      expect($stdout.string).to match(
        /files inspected, no offences detected\n/
      )
    end

    it 'registers an offence for a syntax error' do
      File.open('example.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts 'class Test'
        f.puts 'en'
      end
      begin
        expect(cli.run(['--emacs', 'example.rb'])).to eq(1)
        unexpected_part = RUBY_VERSION >= '2.0' ? 'end-of-input' : '$end'
        expect($stdout.string).to eq(
          ["example.rb:3: E: Syntax error, unexpected #{unexpected_part}, " +
           'expecting keyword_end',
           '',
           '1 file inspected, 1 offence detected',
           ''].join("\n"))
      ensure
        File.delete 'example.rb'
      end
    end

    it 'can process a file with an invalid UTF-8 byte sequence' do
      File.open('example.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts "# \xf9\x29"
      end
      begin
        expect(cli.run(['--emacs', 'example.rb'])).to eq(0)
      ensure
        File.delete 'example.rb'
      end
    end

    it 'has configuration for all cops in .rubocop.yml' do
      cop_names = Cop::Cop.all.map do |cop_class|
        cop_class.name.split('::').last
      end
      expect(YAML.load_file('.rubocop.yml').keys.sort)
        .to eq((['AllCops'] + cop_names).sort)
    end

    it 'can have all cops disabled in a code section' do
      File.open('example.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts '# rubocop:disable all'
        f.puts '#' * 90
        f.puts 'x(123456)'
        f.puts 'y("123")'
        f.puts 'def func'
        f.puts '  # rubocop: enable LineLength, StringLiterals'
        f.puts '  ' + '#' * 93
        f.puts '  x(123456)'
        f.puts '  y("123")'
        f.puts 'end'
      end
      begin
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
      ensure
        File.delete 'example.rb'
      end
    end

    it 'can have selected cops disabled in a code section' do
      File.open('example.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts '# rubocop:disable LineLength,NumericLiterals,StringLiterals'
        f.puts '#' * 90
        f.puts 'x(123456)'
        f.puts 'y("123")'
        f.puts 'def func'
        f.puts '  # rubocop: enable LineLength, StringLiterals'
        f.puts '  ' + '#' * 93
        f.puts '  x(123456)'
        f.puts '  y("123")'
        f.puts 'end'
      end
      begin
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
      ensure
        File.delete 'example.rb'
      end
    end

    it 'can have all cops disabled on a single line' do
      File.open('example.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts 'y("123", 123456) # rubocop:disable all'
      end
      begin
        expect(cli.run(['--emacs', 'example.rb'])).to eq(0)
        expect($stdout.string).to eq(
          ['',
           '1 file inspected, no offences detected',
           ''].join("\n"))
      ensure
        File.delete 'example.rb'
      end
    end

    it 'can have selected cops disabled on a single line' do
      File.open('example.rb', 'w') do |f|
        f.puts '# encoding: utf-8'
        f.puts '#' * 90 + ' # rubocop:disable LineLength'
        f.puts '#' * 95
        f.puts 'y("123") # rubocop:disable LineLength,StringLiterals'
      end
      begin
        expect(cli.run(['--emacs', 'example.rb'])).to eq(1)
        expect($stdout.string).to eq(
          ['example.rb:3: C: Line is too long. [95/79]',
           '',
           '1 file inspected, 1 offence detected',
           ''].join("\n"))
      ensure
        File.delete 'example.rb'
      end
    end

    it 'finds a file with no .rb extension but has a shebang line' do
      FileUtils::mkdir 'test'
      File.open('test/example', 'w') do |f|
        f.puts '#!/usr/bin/env ruby'
        f.puts '# encoding: utf-8'
        f.puts 'x = 0'
        f.puts 'puts x'
      end
      begin
        FileUtils::cd 'test' do
          # Need to pass an empty array explicitly
          # so that the CLI does not refer arguments of `rspec`
          expect(cli.run([])).to eq(0)
          expect($stdout.string).to eq(
            ['', '1 file inspected, no offences detected',
             ''].join("\n"))
        end
      ensure
        FileUtils::rm_rf 'test'
      end
    end

    describe '#display_summary' do
      it 'handles pluralization correctly' do
        cli.display_summary(0, 0, 0)
        expect($stdout.string).to eq(
          "\n0 files inspected, no offences detected\n")
        $stdout = StringIO.new
        cli.display_summary(1, 0, 0)
        expect($stdout.string).to eq(
          "\n1 file inspected, no offences detected\n")
        $stdout = StringIO.new
        cli.display_summary(1, 1, 0)
        expect($stdout.string).to eq(
          "\n1 file inspected, 1 offence detected\n")
        $stdout = StringIO.new
        cli.display_summary(2, 2, 0)
        expect($stdout.string).to eq(
          "\n2 files inspected, 2 offences detected\n")
      end

      it 'displays an error message when errors are present' do
        cli.display_summary(1, 1, 1)
        expect($stdout.string.lines.to_a[-3])
          .to eq("1 error occurred.\n")
      end
    end
  end
end
