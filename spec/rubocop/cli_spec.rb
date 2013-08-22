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
      Config.debug = false
    end

    after(:each) do
      $stdout = STDOUT
      $stderr = STDERR
    end

    def abs(path)
      File.expand_path(path)
    end

    describe '-h/--help option' do
      it 'exits cleanly' do
        expect { cli.run ['-h'] }.to exit_with_code(0)
        expect { cli.run ['--help'] }.to exit_with_code(0)
      end

      it 'shows help text' do
        begin
          cli.run(['--help'])
        rescue SystemExit # rubocop:disable HandleExceptions
        end

        expected_help = <<-END
Usage: rubocop [options] [file1, file2, ...]
    -d, --debug                      Display debug info.
    -c, --config FILE                Specify configuration file.
        --only COP                   Run just one cop.
        --auto-gen-config            Generate a configuration file acting as a
                                     TODO list.
        --show-cops                  Shows cops and their config for the
                                     current directory.
    -f, --format FORMATTER           Choose an output formatter. This option
                                     can be specified multiple times to enable
                                     multiple formatters at the same time.
                                       [p]rogress (default)
                                       [s]imple
                                       [c]lang
                                       [e]macs
                                       [j]son
                                       [f]iles
                                       [o]ffences
                                       custom formatter class name
    -o, --out FILE                   Write output to a file instead of STDOUT.
                                     This option applies to the previously
                                     specified --format, or the default format
                                     if no format is specified.
    -r, --require FILE               Require Ruby file.
    -R, --rails                      Run extra Rails cops.
    -l, --lint                       Run only lint cops.
    -a, --auto-correct               Auto-correct offences.
    -n, --no-color                   Disable color output.
    -v, --version                    Display version.
    -V, --verbose-version            Display verbose version.
        END

        expect($stdout.string).to eq(expected_help)
      end

      it 'lists all builtin formatters' do
        begin
          cli.run(['--help'])
        rescue SystemExit # rubocop:disable HandleExceptions
        end

        option_sections = $stdout.string.lines.slice_before(/^\s*-/)

        format_section = option_sections.find do |lines|
          lines.first =~ /^\s*-f/
        end

        formatter_keys = format_section.reduce([]) do |keys, line|
          match = line.match(/^[ ]{39}(\[[a-z\]]+)/)
          next keys unless match
          keys << match.captures.first.gsub(/\[|\]/, '')
        end.sort

        expected_formatter_keys =
          Formatter::FormatterSet::BUILTIN_FORMATTERS_FOR_KEYS.keys.sort

        expect(formatter_keys).to eq(expected_formatter_keys)
      end
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
        ["#{abs('example1.rb')}:1:1: C: Missing utf-8 encoding comment.",
         "#{abs('example1.rb')}:1:2: C: Surrounding space missing" +
         " for operator '='.",
         "#{abs('example1.rb')}:1:5: C: Trailing whitespace detected.",
         "#{abs('example1.rb')}:2:2: C: Trailing whitespace detected.",
         "#{abs('example2.rb')}:1:1: C: Missing utf-8 encoding comment.",
         "#{abs('example2.rb')}:1:1: C: Tab detected.",
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
        ["#{abs('example1.rb')}:1:2: C: Surrounding space missing" +
         " for operator '='.",
         "#{abs('example1.rb')}:1:5: C: Trailing whitespace detected.",
         "#{abs('example1.rb')}:2:2: C: Trailing whitespace detected.",
         "#{abs('example2.rb')}:1:1: C: Tab detected.",
         ''].join("\n"))
    end

    it 'can report in clang style' do
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
      expect(cli.run(['--format', 'clang', 'example1.rb', 'example2.rb',
                      'example3.rb']))
        .to eq(1)
      expect($stdout.string)
        .to eq(['example1.rb:2:2: C: Surrounding space missing for operator ' +
                "'='.",
                'x= 0 ',
                ' ^',
                'example1.rb:2:5: C: Trailing whitespace detected.',
                'x= 0 ',
                '    ^',
                'example1.rb:3:80: C: Line is too long. [85/79]',
                '###########################################################' +
                '##########################',
                '                                                           ' +
                '                    ^^^^^^',
                'example1.rb:4:2: C: Trailing whitespace detected.',
                'y ',
                ' ^',
                'example2.rb:2:1: C: Tab detected.',
                "\tx",
                '^^^^^',
                'example2.rb:4:1: C: Use 2 (not 3) spaces for indentation.',
                '   puts',
                '^^^',
                'example3.rb:2:5: C: Use snake_case for methods and ' +
                'variables.',
                'def badName',
                '    ^^^^^^^',
                'example3.rb:3:3: C: Favor modifier if/unless usage when ' +
                'you have a single-line body. Another good alternative is ' +
                'the usage of control flow &&/||.',
                '  if something',
                '  ^^',
                'example3.rb:5:5: W: end at 5, 4 is not aligned with if at ' +
                '3, 2',
                '    end',
                '    ^^^',
                '',
                '3 files inspected, 9 offences detected',
                ''].join("\n"))
    end

    it 'exits with error if asked to re-generate a todo list that is in use' do
      create_file('example1.rb', ['# encoding: utf-8',
                                  'x= 0 ',
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      todo_contents = ['# This configuration was generated with `rubocop' +
                       ' --auto-gen-config`',
                       '',
                       'LineLength:',
                       '  Enabled: false']
      create_file('rubocop-todo.yml', todo_contents)
      expect(IO.read('rubocop-todo.yml'))
        .to eq(todo_contents.join("\n") + "\n")
      create_file('.rubocop.yml', ['inherit_from: rubocop-todo.yml'])
      expect(cli.run(['--auto-gen-config'])).to eq(1)
      expect($stderr.string).to eq('Remove rubocop-todo.yml from the current' +
                                   ' configuration before generating it' +
                                   " again.\n")
    end

    it 'exits with error if file arguments are given with --auto-gen-config' do
      create_file('example1.rb', ['# encoding: utf-8',
                                  'x= 0 ',
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      expect(cli.run(['--auto-gen-config', 'example1.rb'])).to eq(1)
      expect($stderr.string).to eq('--auto-gen-config can not be combined ' +
                                   "with any other arguments.\n")
      expect($stdout.string).to eq('')
    end

    it 'can generate a todo list' do
      create_file('example1.rb', ['# encoding: utf-8',
                                  'x= 0 ',
                                  '#' * 85,
                                  'y ',
                                  'puts x'])
      create_file('example2.rb', ['# encoding: utf-8',
                                  "\tx = 0",
                                  'puts x'])
      expect(cli.run(['--auto-gen-config'])).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string).to include([
        'Created rubocop-todo.yml.',
        'Run rubocop with --config rubocop-todo.yml, or',
        'add inherit_from: rubocop-todo.yml in a .rubocop.yml file.',
        ''].join("\n"))
      expect(IO.read('rubocop-todo.yml'))
        .to eq(['# This configuration was generated by `rubocop' +
                ' --auto-gen-config`.',
                '# The point is for the user to remove these configuration' +
                ' records',
                '# one by one as the offences are removed from the code base.',
                '',
                'LineLength:',
                '  Enabled: false',
                '',
                'SpaceAroundOperators:',
                '  Enabled: false',
                '',
                'Tab:',
                '  Enabled: false',
                '',
                'TrailingWhitespace:',
                '  Enabled: false',
                ''].join("\n"))
    end

    it 'runs just one cop if --only is passed' do
      create_file('example.rb', ['if x== 0 ',
                                 "\ty",
                                 'end'])
      # IfUnlessModifier depends on the configuration of LineLength.
      # That configuration might have been set by other spec examples
      # so we reset it to emulate a start from scratch.
      Cop::Style::LineLength.config = nil

      expect(cli.run(['--format', 'simple',
                      '--only', 'IfUnlessModifier', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(['== example.rb ==',
                'C:  1:  1: Favor modifier if/unless usage when you have a ' +
                'single-line body. Another good alternative is the usage of ' +
                'control flow &&/||.',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))
    end

    it 'runs only lint cops if --lint is passed' do
      create_file('example.rb', ['if 0 ',
                                 "\ty",
                                 'end'])
      # IfUnlessModifier depends on the configuration of LineLength.
      # That configuration might have been set by other spec examples
      # so we reset it to emulate a start from scratch.
      Cop::Style::LineLength.config = nil

      expect(cli.run(['--format', 'simple', '--lint', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(['== example.rb ==',
                'W:  1:  4: Literal 0 appeared in a condition.',
                '',
                '1 file inspected, 1 offence detected',
                ''].join("\n"))

    end

    it 'exits with error if an incorrect cop name is passed to --only' do
      expect(cli.run(%w(--only 123))).to eq(1)

      expect($stderr.string).to eq("Unrecognized cop name: 123.\n")
    end

    context '--show-cops' do
      let(:cops) { Cop::Cop.all }
      let(:global_conf) do
        config_path = Rubocop::Config.configuration_file_for(Dir.pwd.to_s)
        Rubocop::Config.configuration_from_file(config_path)
      end
      before do
        cops.each do |cop_class|
          cop_class.config = global_conf.for_cop(cop_class.cop_name)
        end
      end

      subject do
        expect { cli.run ['--show-cops'] }.to exit_with_code(0)
        @stdout = $stdout.string
      end
      it 'prints all available cops and their description' do
        subject
        cops.each do |cop|
          expect(@stdout).to include cop.cop_name
          expect(@stdout).to include cop.short_description
        end
      end

      it 'prints all types' do
        subject
        cops
          .types
          .dup
          .map!(&:to_s)
          .map!(&:capitalize)
          .each { |type| expect(@stdout).to include(type) }
      end

      it 'prints all cops in their right type listing' do
        subject
        lines = @stdout.lines
        lines.slice_before(/Type /).each do |slice|
          types = cops.types.dup.map!(&:to_s).map!(&:capitalize)
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

      it 'prints the current configuration' do
        subject
        out = @stdout.lines.to_a
        cops.each do |cop|
          conf = global_conf[cop.cop_name].dup
          confstrt = out.find_index { |i| i.include?("- #{cop.cop_name}") } + 1
          c = out[confstrt, conf.keys.size].to_s
          conf.delete('Description')
          expect(c).to include(cop.short_description)
          conf.each do |k, v|
            # ugly hack to get hash/array content tested
            if v.kind_of?(Hash) || v.kind_of?(Array)
              expect(c).to include "#{k}: #{v.to_s.dump[2, -2]}"
            else
              expect(c).to include "#{k}: #{v}"
            end

          end
        end
      end
    end

    it 'shows config files when --debug is passed', ruby: 2.0 do
      create_file('example1.rb', "\tputs 0")
      expect(cli.run(['--debug', 'example1.rb'])).to eq(1)
      home = File.dirname(File.dirname(File.dirname(__FILE__)))
      expect($stdout.string.lines[2, 7].map(&:chomp).join("\n"))
        .to eq(["For #{abs('')}:" +
                " configuration from #{home}/config/default.yml",
                "Inheriting configuration from #{home}/config/enabled.yml",
                "Inheriting configuration from #{home}/config/disabled.yml",
                "AllCops/Excludes configuration from #{home}/.rubocop.yml",
                "Inheriting configuration from #{home}/config/default.yml",
                "Inheriting configuration from #{home}/config/enabled.yml",
                "Inheriting configuration from #{home}/config/disabled.yml"
               ].join("\n"))
    end

    it 'shows cop names when --debug is passed', ruby: 2.0 do
      create_file('example1.rb', "\tputs 0")
      expect(cli.run(['--format',
                      'emacs',
                      '--debug',
                      'example1.rb'])).to eq(1)
      expect($stdout.string.lines[-1]).to eq(
        ["#{abs('example1.rb')}:1:1: C: Tab: Tab detected.",
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
      expect($stdout.string).to eq(
        ['== example1.rb ==',
         'C:  1:  7: Trailing whitespace detected.',
         '',
         '1 file inspected, 1 offence detected',
         ''].join("\n"))
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
      expect($stdout.string).to eq(
        ['== example1.rb ==',
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
      expect($stdout.string).to eq(
        ['== example1.rb ==',
         'C:  1:  1: Favor modifier if/unless usage when you have a ' +
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
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(1)
      expect($stdout.string).to eq(
        ['== example_src/example1.rb ==',
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
      expect($stdout.string).to eq(
        ['',
         '0 files inspected, no offences detected',
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
      expect($stdout.string).to eq(
        ['',
         '0 files inspected, no offences detected',
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
      expect($stdout.string).to eq(
        ['Warning: unrecognized cop LyneLenth found in ' +
         File.expand_path('example/.rubocop.yml'),
         '== example/example1.rb ==',
         'C:  2: 80: Line is too long. [90/79]',
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

      expect(cli.run(%w(--format simple example))).to eq(1)
      expect($stdout.string).to eq(
        ['Warning: unrecognized parameter LineLength:Min found in ' +
         File.expand_path('example/.rubocop.yml'),
         '== example/example1.rb ==',
         'C:  2: 80: Line is too long. [90/79]',
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
        .to eq(["#{abs('example.rb')}:3:3: E: unexpected " +
                'token $end',
                ''].join("\n"))
    end

    it 'registers an offence for Parser warnings' do
      create_file('example.rb', [
                                 '# encoding: utf-8',
                                 'puts *test'
                                ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:2:6: W: " +
                "`*' interpreted as argument prefix",
                ''].join("\n"))
    end

    it 'can process a file with an invalid UTF-8 byte sequence' do
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
        ["#{abs('example.rb')}:8:80: C: Line is too long. [95/79]",
         "#{abs('example.rb')}:10:5: C: Prefer single-quoted strings when " +
         "you don't need string interpolation or special symbols.",
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
        ["#{abs('example.rb')}:8:80: C: Line is too long. [95/79]",
         "#{abs('example.rb')}:10:5: C: Prefer single-quoted strings when " +
         "you don't need string interpolation or special symbols.",
         ''].join("\n"))
    end

    it 'can have all cops disabled on a single line' do
      create_file('example.rb', [
        '# encoding: utf-8',
        'y("123", 123456) # rubocop:disable all'
      ])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
      expect($stdout.string).to be_empty
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
        ["#{abs('example.rb')}:3:80: C: Line is too long. [95/79]",
         ''].join("\n"))
    end

    it 'finds a file with no .rb extension but has a shebang line' do
      create_file('example', [
        '#!/usr/bin/env ruby',
        '# encoding: utf-8',
        'x = 0',
        'puts x'
      ])
      expect(cli.run(%w(--format simple))).to eq(0)
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
      expect(cli.run(%w(--format simple))).to eq(0)
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
      expect(cli.run(%w(--format simple))).to eq(0)
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
      expect(cli.run(%w(--format simple example))).to eq(0)
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
              'C:  2: 80: Line is too long. [90/79]'
            ].join("\n"))
          end
        end

        context 'when emacs format is specified' do
          it 'outputs with emacs format' do
            cli.run(['--format', 'emacs', 'example.rb'])
            expect($stdout.string).to include(
              "#{abs(target_file)}:2:80: C: Line is too long. [90/79]")
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
          'C:  2: 80: Line is too long. [90/79]',
          "#{abs(target_file)}:2:80: C: Line is too long. [90/79]"
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

      describe '-s/--silent option' do
        it 'raises error in RuboCop 1.0.0' do
          # This spec can be removed
          # once CLI#ignore_dropped_options is removed.
          expect(cli.run(['--silent'])).to eq(1)
          expect($stderr.string).to include('invalid option: --silent')
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
          'C:  2: 80: Line is too long. [90/79]',
          '',
          '1 file inspected, 1 offence detected',
          ''
        ].join("\n"))

        expect(File.read('emacs_output.txt')).to eq([
          "#{abs(target_file)}:2:80: C: Line is too long. [90/79]",
          ''
        ].join("\n"))
      end
    end

    describe '#display_error_summary' do
      it 'displays an error message to stderr when errors are present' do
        msg = 'An error occurred while Encoding cop was inspecting file.rb.'
        cli.display_error_summary([msg])
        expect($stderr.string.lines.to_a[-6..-5])
          .to eq(["1 error occurred:\n", "#{msg}\n"])
      end
    end
  end
end
