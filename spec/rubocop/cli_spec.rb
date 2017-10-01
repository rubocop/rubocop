# frozen_string_literal: true

require 'timeout'

describe RuboCop::CLI, :isolated_environment do
  include_context 'cli spec behavior'

  subject(:cli) { described_class.new }

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
          .to eq(<<-RESULT.strip_indent)
            == #{abs('Rakefile')} ==
            W:  1:  1: Useless assignment to variable - x.

            1 file inspected, 1 offense detected
        RESULT
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

  context 'when lines end with CR+LF' do
    it 'reports an offense' do
      create_file('example.rb', <<-RUBY.strip_indent)
        x = 0\r
        puts x\r
      RUBY
      # Make Style/EndOfLine give same output regardless of platform.
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        Layout/EndOfLine:
          EnforcedStyle: lf
      YAML
      result = cli.run(['--format', 'simple', 'example.rb'])
      expect(result).to eq(1)
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)
          == example.rb ==
          C:  1:  1: Carriage return character detected.

          1 file inspected, 1 offense detected
      RESULT
    end
  end

  context 'when checking a correct file' do
    it 'returns 0' do
      create_file('example.rb', ['x = 0', 'puts x'])
      expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)

          1 file inspected, no offenses detected
      RESULT
    end

    context 'when super is used with a block' do
      it 'still returns 0' do
        create_file('example.rb', <<-RUBY.strip_indent)
          # frozen_string_literal: true

          # this is a class
          class Thing
            def super_with_block
              super { |response| }
            end

            def and_with_args
              super(arg1, arg2) { |response| }
            end
          end
        RUBY
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Lint/UnusedBlockArgument:
            IgnoreEmptyBlocks: true
        YAML
        expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
        expect($stdout.string)
          .to eq(<<-RESULT.strip_indent)

            1 file inspected, no offenses detected
        RESULT
      end
    end
  end

  it 'checks a given file with faults and returns 1' do
    create_file('example.rb', ['x = 0 ', 'puts x'])
    expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq <<-RESULT.strip_indent
        == example.rb ==
        C:  1:  6: Trailing whitespace detected.

        1 file inspected, 1 offense detected
    RESULT
  end

  it 'registers an offense for a syntax error' do
    create_file('example.rb', ['class Test', 'en'])
    expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq(["#{abs('example.rb')}:3:1: E: unexpected " \
              'token $end (Using Ruby 2.1 parser; configure using ' \
              '`TargetRubyVersion` parameter, under `AllCops`)',
              ''].join("\n"))
  end

  it 'registers an offense for Parser warnings' do
    create_file('example.rb', ['puts *test', 'if a then b else c end'])
    aggregate_failures('CLI output') do
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(["#{abs('example.rb')}:1:6: W: " \
                'Ambiguous splat operator. Parenthesize the method arguments ' \
                "if it's surely a splat operator, or add a whitespace to the " \
                'right of the `*` if it should be a multiplication.',
                "#{abs('example.rb')}:2:1: C: " \
                'Favor the ternary operator (`?:`) over `if/then/else/end` ' \
                'constructs.',
                ''].join("\n"))
    end
  end

  it 'can process a file with an invalid UTF-8 byte sequence' do
    create_file('example.rb', ["# #{'f9'.hex.chr}#{'29'.hex.chr}"])
    expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
    expect($stdout.string)
      .to eq(<<-RESULT.strip_indent)
        #{abs('example.rb')}:1:1: F: Invalid byte sequence in utf-8.
    RESULT
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
      src = ['# rubocop:disable all',
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
        .to eq(["#{abs('example.rb')}:7:81: C: Line is too long. [95/80]",
                "#{abs('example.rb')}:9:5: C: Prefer single-quoted " \
                "strings when you don't need string interpolation or " \
                'special symbols.',
                ''].join("\n"))
    end

    context 'when --auto-correct is given' do
      it 'does not trigger UnneededDisable due to lines moving around' do
        src = ['a = 1 # rubocop:disable Lint/UselessAssignment']
        create_file('example.rb', src)
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Style/FrozenStringLiteralComment:
            Enabled: true
            EnforcedStyle: always
        YAML
        expect(cli.run(['--format', 'offenses', '-a', 'example.rb'])).to eq(0)
        expect($stdout.string).to eq(<<-RESULT.strip_indent)

          1  Layout/EmptyLineAfterMagicComment
          1  Style/FrozenStringLiteralComment
          --
          2  Total

        RESULT
        expect(IO.read('example.rb'))
          .to eq(<<-RUBY.strip_indent)
            # frozen_string_literal: true

            a = 1 # rubocop:disable Lint/UselessAssignment
        RUBY
      end
    end

    it 'can disable selected cops in a code section' do
      create_file('example.rb',
                  ['# rubocop:disable Style/LineLength,' \
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
        .to eq(["#{abs('example.rb')}:7:81: C: Line is too long. [95/80]",
                "#{abs('example.rb')}:9:5: C: Prefer single-quoted " \
                "strings when you don't need string interpolation or " \
                'special symbols.',
                ''].join("\n"))
    end

    it 'can disable all cops on a single line' do
      create_file('example.rb', 'y("123", 123456) # rubocop:disable all')
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
      expect($stdout.string).to be_empty
    end

    it 'can disable selected cops on a single line' do
      create_file('example.rb',
                  ['a' * 90 + ' # rubocop:disable Metrics/LineLength',
                   '#' * 95,
                   'y("123", 123456) # rubocop:disable Style/StringLiterals,' \
                   'Style/NumericLiterals'])
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)
          #{abs('example.rb')}:2:81: C: Line is too long. [95/80]
      RESULT
    end

    context 'without using namespace' do
      it 'can disable selected cops on a single line' do
        create_file('example.rb',
                    ['a' * 90 + ' # rubocop:disable LineLength',
                     '#' * 95,
                     'y("123") # rubocop:disable StringLiterals'])
        expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(<<-RESULT.strip_indent)
            #{abs('example.rb')}:2:81: C: Line is too long. [95/80]
        RESULT
      end
    end

    context 'when not necessary' do
      it 'causes an offense to be reported' do
        create_file('example.rb',
                    ['#' * 95,
                     '# rubocop:disable all',
                     'a' * 10 + ' # rubocop:disable LineLength,ClassLength',
                     'y(123) # rubocop:disable all'])
        expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(1)
        expect($stderr.string).to eq('')
        expect($stdout.string)
          .to eq(["#{abs('example.rb')}:1:81: C: Line is too long. [95/80]",
                  "#{abs('example.rb')}:2:1: W: Unnecessary disabling of " \
                  'all cops.',
                  "#{abs('example.rb')}:3:12: W: Unnecessary disabling of " \
                  '`Metrics/ClassLength`, `Metrics/LineLength`.',
                  "#{abs('example.rb')}:4:8: W: Unnecessary disabling of " \
                  'all cops.',
                  ''].join("\n"))
      end

      context 'and there are no other offenses' do
        it 'exits with error code' do
          create_file('example.rb', 'a' * 10 + ' # rubocop:disable LineLength')
          expect(cli.run(['example.rb'])).to eq(1)
        end
      end

      shared_examples 'UnneededDisable not run' do |state, config|
        context "and UnneededDisable is #{state}" do
          it 'does not report UnneededDisable offenses' do
            create_file('example.rb',
                        ['#' * 95,
                         '# rubocop:disable all',
                         'a' * 10 + ' # rubocop:disable LineLength,ClassLength',
                         'y(123) # rubocop:disable all'])
            create_file('.rubocop.yml', config)
            expect(cli.run(['--format', 'emacs'])).to eq(1)
            expect($stderr.string).to eq('')
            expect($stdout.string)
              .to eq(<<-RESULT.strip_indent)
                #{abs('example.rb')}:1:81: C: Line is too long. [95/80]
              RESULT
          end
        end
      end

      include_examples 'UnneededDisable not run',
                       'individually disabled', <<-YAML.strip_indent
        Lint/UnneededDisable:
          Enabled: false
      YAML
      include_examples 'UnneededDisable not run',
                       'individually excluded', <<-YAML.strip_indent
        Lint/UnneededDisable:
          Exclude:
            - example.rb
      YAML
      include_examples 'UnneededDisable not run',
                       'disabled through department', <<-YAML.strip_indent
        Lint:
          Enabled: false
      YAML
    end
  end

  it 'finds a file with no .rb extension but has a shebang line' do
    allow_any_instance_of(File::Stat)
      .to receive(:executable?).and_return(true)
    create_file('example', ['#!/usr/bin/env ruby', 'x = 0', 'puts x'])
    expect(cli.run(%w[--format simple])).to eq(0)
    expect($stdout.string)
      .to eq(['', '1 file inspected, no offenses detected', ''].join("\n"))
  end

  it 'does not register any offenses for an empty file' do
    create_file('example.rb', '')
    expect(cli.run(%w[--format simple])).to eq(0)
    expect($stdout.string)
      .to eq(['', '1 file inspected, no offenses detected', ''].join("\n"))
  end

  describe 'style guide only usage' do
    context 'via the cli option' do
      describe '--only-guide-cops' do
        it 'skips cops that have no link to a style guide' do
          create_file('example.rb', 'raise')
          create_file('.rubocop.yml', <<-YAML.strip_indent)
            Metrics/LineLength:
              Enabled: true
              StyleGuide: ~
              Max: 2
          YAML

          expect(cli.run(['--format', 'simple', '--only-guide-cops',
                          'example.rb'])).to eq(0)
        end

        it 'runs cops for rules that link to a style guide' do
          create_file('example.rb', 'raise')
          create_file('.rubocop.yml', <<-YAML.strip_indent)
            Metrics/LineLength:
              Enabled: true
              StyleGuide: "http://an.example/url"
              Max: 2
          YAML

          expect(cli.run(['--format', 'simple', '--only-guide-cops',
                          'example.rb'])).to eq(1)

          expect($stdout.string)
            .to eq(<<-RESULT.strip_indent)
              == example.rb ==
              C:  1:  3: Line is too long. [5/2]

              1 file inspected, 1 offense detected
            RESULT
        end

        it 'overrides configuration of AllCops/StyleGuideCopsOnly' do
          create_file('example.rb', 'raise')
          create_file('.rubocop.yml', <<-YAML.strip_indent)
            AllCops:
              StyleGuideCopsOnly: false
            Metrics/LineLength:
              Enabled: true
              StyleGuide: ~
              Max: 2
          YAML

          expect(cli.run(['--format', 'simple', '--only-guide-cops',
                          'example.rb'])).to eq(0)
        end
      end
    end

    context 'via the config' do
      before do
        create_file('example.rb', 'do_something or raise')
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          AllCops:
            StyleGuideCopsOnly: #{guide_cops_only}
            DisabledByDefault: #{disabled_by_default}
          Metrics/LineLength:
            Enabled: true
            StyleGuide: ~
            Max: 2
        YAML
      end

      describe 'AllCops/StyleGuideCopsOnly' do
        let(:disabled_by_default) { 'false' }

        context 'when it is true' do
          let(:guide_cops_only) { 'true' }

          it 'skips cops that have no link to a style guide' do
            expect(cli.run(['--format', 'offenses', 'example.rb'])).to eq(1)

            expect($stdout.string).to eq(<<-RESULT.strip_indent)

              1  Style/AndOr
              --
              1  Total

            RESULT
          end
        end

        context 'when it is false' do
          let(:guide_cops_only) { 'false' }

          it 'runs cops for rules regardless of any link to the style guide' do
            expect(cli.run(['--format', 'offenses', 'example.rb'])).to eq(1)

            expect($stdout.string).to eq(<<-RESULT.strip_indent)

              1  Metrics/LineLength
              1  Style/AndOr
              --
              2  Total

            RESULT
          end
        end
      end

      describe 'AllCops/DisabledByDefault' do
        let(:guide_cops_only) { 'false' }

        context 'when it is true' do
          let(:disabled_by_default) { 'true' }

          it 'runs only the cop configured in .rubocop.yml' do
            expect(cli.run(['--format', 'offenses', 'example.rb'])).to eq(1)

            expect($stdout.string).to eq(<<-RESULT.strip_indent)

              1  Metrics/LineLength
              --
              1  Total

            RESULT
          end
        end

        context 'when it is false' do
          let(:disabled_by_default) { 'false' }

          it 'runs all cops that are enabled in default configuration' do
            expect(cli.run(['--format', 'offenses', 'example.rb'])).to eq(1)

            expect($stdout.string).to eq(<<-RESULT.strip_indent)

              1  Metrics/LineLength
              1  Style/AndOr
              --
              2  Total

            RESULT
          end
        end
      end
    end
  end

  describe 'rails cops' do
    before(:each) do
      RuboCop::ConfigLoader.default_configuration = nil
    end

    describe 'enabling/disabling' do
      it 'by default does not run rails cops' do
        create_file('app/models/example1.rb', 'read_attribute(:test)')
        expect(cli.run(['--format', 'simple', 'app/models/example1.rb']))
          .to eq(0)
      end

      it 'with -R given runs rails cops' do
        create_file('app/models/example1.rb', 'read_attribute(:test)')
        expect(cli.run(['--format', 'simple', '-R', 'app/models/example1.rb']))
          .to eq(1)
        expect($stdout.string).to include('Prefer self[:attr]')
      end

      it 'with configuration option true in one dir runs rails cops there' do
        source = 'read_attribute(:test)'
        create_file('dir1/app/models/example1.rb', source)
        create_file('dir1/.rubocop.yml', <<-YAML.strip_indent)
          Rails:
            Enabled: true

          Rails/ReadWriteAttribute:
            Include:
              - app/models/**/*.rb
        YAML
        create_file('dir2/app/models/example2.rb', source)
        create_file('dir2/.rubocop.yml', <<-YAML.strip_indent)
          Rails:
            Enabled: false

          Rails/ReadWriteAttribute:
            Include:
              - app/models/**/*.rb
        YAML
        expect(cli.run(%w[--format simple dir1 dir2])).to eq(1)
        expect($stdout.string)
          .to eq(['== dir1/app/models/example1.rb ==',
                  'C:  1:  1: Prefer self[:attr] over read_attribute' \
                  '(:attr).',
                  '',
                  '2 files inspected, 1 offense detected',
                  ''].join("\n"))
      end

      it 'with configuration option false but -R given runs rails cops' do
        create_file('app/models/example1.rb', 'read_attribute(:test)')
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Rails:
            Enabled: false
        YAML
        expect(cli.run(['--format', 'simple', '-R', 'app/models/example1.rb']))
          .to eq(1)
        expect($stdout.string).to include('Prefer self[:attr]')
      end

      context 'with obsolete RunRailsCops config option' do
        it 'prints a warning' do
          create_file('.rubocop.yml', <<-YAML.strip_indent)
            AllCops:
              RunRailsCops: false
          YAML
          expect(cli.run([])).to eq(2)
          expect($stderr.string).to include('obsolete parameter RunRailsCops ' \
                                            '(for AllCops) found')
        end
      end
    end

    describe 'including/excluding' do
      it 'honors Exclude settings in .rubocop_todo.yml one level up' do
        create_file('lib/example.rb', 'puts %x(ls)')
        create_file('.rubocop.yml', 'inherit_from: .rubocop_todo.yml')
        create_file('.rubocop_todo.yml', <<-YAML.strip_indent)
          Style/CommandLiteral:
            Exclude:
              - lib/example.rb
        YAML
        Dir.chdir('lib') { expect(cli.run([])).to eq(0) }
        expect($stdout.string).to include('no offenses detected')
      end

      it 'includes some directories by default' do
        source = ['read_attribute(:test)', "default_scope order: 'position'"]
        # Several rails cops include app/models by default.
        create_file('dir1/app/models/example1.rb', source)
        create_file('dir1/app/models/example2.rb', source)
        # No rails cops include app/views by default.
        create_file('dir1/app/views/example3.rb', source)
        # The .rubocop.yml file inherits from default.yml where the Include
        # config parameter is set for the rails cops. The paths are interpreted
        # as relative to dir1 because .rubocop.yml is placed there.
        create_file('dir1/.rubocop.yml', <<-YAML.strip_indent)
          Rails:
            Enabled: true

          Rails/ReadWriteAttribute:
            Exclude:
              - "**/example2.rb"
        YAML
        # No .rubocop.yml file in dir2 means that the paths from default.yml
        # are interpreted as relative to the current directory, so they don't
        # match.
        create_file('dir2/app/models/example4.rb', source)

        expect(cli.run(%w[--format simple dir1 dir2])).to eq(1)
        expect($stdout.string)
          .to eq(['== dir1/app/models/example1.rb ==',
                  'C:  1:  1: Prefer self[:attr] over read_attribute' \
                  '(:attr).',
                  '',
                  '4 files inspected, 1 offense detected',
                  ''].join("\n"))
      end
    end
  end

  describe 'cops can exclude files based on config' do
    it 'ignores excluded files' do
      create_file('example.rb', 'x = 0')
      create_file('regexp.rb', 'x = 0')
      create_file('exclude_glob.rb', ['#!/usr/bin/env ruby', 'x = 0'])
      create_file('dir/thing.rb', 'x = 0')
      create_file('.rubocop.yml', <<-'YAML'.strip_indent)
        Lint/UselessAssignment:
          Exclude:
            - example.rb
            - !ruby/regexp /regexp.rb\z/
            - "exclude_*"
            - "dir/*"
      YAML
      allow_any_instance_of(File::Stat)
        .to receive(:executable?).and_return(true)
      expect(cli.run(%w[--format simple])).to eq(0)
      expect($stdout.string)
        .to eq(['', '4 files inspected, no offenses detected',
                ''].join("\n"))
    end
  end

  describe 'configuration from file' do
    before(:each) do
      RuboCop::ConfigLoader.default_configuration = nil
    end

    context 'when configured for rails style indentation' do
      it 'accepts rails style indentation' do
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Layout/IndentationConsistency:
            EnforcedStyle: rails
        YAML
        create_file('example.rb', <<-RUBY.strip_indent)

          # A feline creature
          class Cat
            def meow
              puts('Meow!')
            end

            protected

              def can_we_be_friends?(another_cat)
                some_logic(another_cat)
              end

            private

              def meow_at_3am?
                rand < 0.8
              end
          end
        RUBY
        result = cli.run(%w[--format simple])
        expect($stderr.string).to eq('')
        expect(result).to eq(0)
        expect($stdout.string)
          .to eq(['', '1 file inspected, no offenses detected',
                  ''].join("\n"))
      end

      %w[class module].each do |parent|
        it "registers offense for normal indentation in #{parent}" do
          create_file('.rubocop.yml', <<-YAML.strip_indent)
            Layout/IndentationConsistency:
              EnforcedStyle: rails
          YAML
          create_file('example.rb', <<-RUBY.strip_indent)

            # A feline creature
            #{parent} Cat
              def meow
                puts('Meow!')
              end

              protected

              def can_we_be_friends?(another_cat)
                some_logic(another_cat)
              end

              private

              def meow_at_3am?
                rand < 0.8
              end

              def meow_at_4am?
                rand < 0.8
              end
            end
          RUBY
          result = cli.run(%w[--format simple])
          expect($stderr.string).to eq('')
          expect(result).to eq(1)
          expect($stdout.string)
            .to eq(<<-RESULT.strip_indent)
              == example.rb ==
              C: 10:  3: Use 2 (not 0) spaces for rails indentation.
              C: 16:  3: Use 2 (not 0) spaces for rails indentation.

              1 file inspected, 2 offenses detected
          RESULT
        end
      end
    end

    context 'when obsolete MultiSpaceAllowedForOperators param is used' do
      it 'displays a warning' do
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Layout/SpaceAroundOperators:
            MultiSpaceAllowedForOperators:
              - "="
        YAML
        expect(cli.run([])).to eq(2)
        expect($stderr.string).to include('obsolete parameter ' \
                                          'MultiSpaceAllowedForOperators ' \
                                          '(for Layout/SpaceAroundOperators)' \
                                          ' found')
      end
    end

    context 'when MultilineMethodCallIndentation is used with aligned ' \
            'style and IndentationWidth parameter' do
      it 'fails with an error message' do
        create_file('example.rb', 'puts 1')
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Layout/MultilineMethodCallIndentation:
            EnforcedStyle: aligned
            IndentationWidth: 1
        YAML
        expect(cli.run(['example.rb'])).to eq(2)
        expect($stderr.string.strip).to eq(
          'Error: The `Layout/MultilineMethodCallIndentation` cop only ' \
          'accepts an `IndentationWidth` configuration parameter when ' \
          '`EnforcedStyle` is `indented`.'
        )
      end
    end

    context 'when MultilineOperationIndentation is used with aligned ' \
            'style and IndentationWidth parameter' do
      it 'fails with an error message' do
        create_file('example.rb', 'puts 1')
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Layout/MultilineOperationIndentation:
            EnforcedStyle: aligned
            IndentationWidth: 1
        YAML
        expect(cli.run(['example.rb'])).to eq(2)
        expect($stderr.string.strip).to eq(
          'Error: The `Layout/MultilineOperationIndentation` cop only accepts' \
          ' an `IndentationWidth` configuration parameter when ' \
          '`EnforcedStyle` is `indented`.'
        )
      end
    end

    it 'allows the default configuration file as the -c argument' do
      create_file('example.rb', ['x = 0', 'puts x'])
      create_file('.rubocop.yml', [])

      expect(cli.run(%w[--format simple -c .rubocop.yml])).to eq(0)
      expect($stdout.string)
        .to eq(['', '1 file inspected, no offenses detected',
                ''].join("\n"))
    end

    context 'when --force-default-config option is specified' do
      shared_examples 'ignores config file' do
        it 'ignores config file' do
          create_file('example.rb', ['x = 0 ', 'puts x'])
          create_file('.rubocop.yml', <<-YAML.strip_indent)
            Layout/TrailingWhitespace:
              Enabled: false
          YAML

          expect(cli.run(args)).to eq(1)
          expect($stdout.string)
            .to eq(<<-RESULT.strip_indent)
              == example.rb ==
              C:  1:  6: Trailing whitespace detected.

              1 file inspected, 1 offense detected
            RESULT
        end
      end

      context 'when no config file specified' do
        let(:args) { %w[--format simple --force-default-config] }
        include_examples 'ignores config file'
      end

      context 'when config file specified with -c' do
        let(:args) do
          %w[--format simple --force-default-config -c .rubocop.yml]
        end
        include_examples 'ignores config file'
      end
    end

    it 'displays cop names if DisplayCopNames is true' do
      source = ['x = 0 ', 'puts x']
      create_file('example1.rb', source)

      # DisplayCopNames: false inherited from config/default.yml
      create_file('.rubocop.yml', [])

      create_file('dir/example2.rb', source)
      create_file('dir/.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          DisplayCopNames: true
      YAML

      expect(cli.run(%w[--format simple])).to eq(1)
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  1:  6: Trailing whitespace detected.',
                '== dir/example2.rb ==',
                'C:  1:  6: Layout/TrailingWhitespace: Trailing whitespace' \
                ' detected.',
                '',
                '2 files inspected, 2 offenses detected',
                ''].join("\n"))
    end

    it 'displays style guide URLs if DisplayStyleGuide is true' do
      source = ['x = 0 ', 'puts x']
      create_file('example1.rb', source)

      # DisplayCopNames: false inherited from config/default.yml
      create_file('.rubocop.yml', [])

      create_file('dir/example2.rb', source)
      create_file('dir/.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          DisplayStyleGuide: true
      YAML

      url = 'https://github.com/bbatsov/ruby-style-guide#no-trailing-whitespace'

      expect(cli.run(%w[--format simple])).to eq(1)
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  1:  6: Trailing whitespace detected.',
                '== dir/example2.rb ==',
                'C:  1:  6: Trailing whitespace' \
                " detected. (#{url})",
                '',
                '2 files inspected, 2 offenses detected',
                ''].join("\n"))
    end

    it 'uses the DefaultFormatter if another formatter is not specified' do
      source = ['x = 0 ', 'puts x']
      create_file('example1.rb', source)
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          DefaultFormatter: offenses
      YAML

      expect(cli.run([])).to eq(1)
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)

          1  Layout/TrailingWhitespace
          --
          1  Total

        RESULT
    end

    it 'finds included files' do
      create_file('file.rb', 'x=0') # Included by default
      create_file('example', 'x=0')
      create_file('regexp', 'x=0')
      create_file('.dot1/file.rb', 'x=0') # Hidden but explicitly included
      create_file('.dot2/file.rb', 'x=0') # Hidden, excluded by default
      create_file('.dot3/file.rake', 'x=0') # Hidden, not included by wildcard
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Include:
            - example
            - "**/*.rake"
            - !ruby/regexp /regexp$/
            - .dot1/**/*
      YAML
      expect(cli.run(%w[--format files])).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string.split($RS).sort).to eq([abs('.dot1/file.rb'),
                                                    abs('example'),
                                                    abs('file.rb'),
                                                    abs('regexp')])
    end

    it 'ignores excluded files' do
      create_file('example.rb', ['x = 0', 'puts x'])
      create_file('regexp.rb', ['x = 0', 'puts x'])
      create_file('exclude_glob.rb', ['#!/usr/bin/env ruby', 'x = 0', 'puts x'])
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Exclude:
            - example.rb
            - !ruby/regexp /regexp.rb$/
            - "exclude_*"
      YAML
      expect(cli.run(%w[--format simple])).to eq(0)
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'only reads configuration in explicitly included hidden directories' do
      create_file('.hidden/example.rb', 'x=0')
      # This file contains configuration for an unknown cop. This would cause a
      # warning to be printed on stderr if the file was read. But it's in a
      # hidden directory, so it's not read.
      create_file('.hidden/.rubocop.yml', <<-YAML.strip_indent)
        SymbolName:
          Enabled: false
      YAML

      create_file('.other/example.rb', 'x=0')
      # The .other directory is explicitly included, so the configuration file
      # is read, and modifies the behavior.
      create_file('.other/.rubocop.yml', <<-YAML.strip_indent)
        Layout/SpaceAroundOperators:
          Enabled: false
      YAML
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Include:
            - .other/**/*
      YAML
      expect(cli.run(%w[--format simple])).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)
          == .other/example.rb ==
          W:  1:  1: Useless assignment to variable - x.

          1 file inspected, 1 offense detected
        RESULT
    end

    it 'does not consider Include parameters in subdirectories' do
      create_file('dir/example.ruby3', 'x=0')
      create_file('dir/.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Include:
            - "*.ruby3"
      YAML
      expect(cli.run(%w[--format simple])).to eq(0)
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)

          0 files inspected, no offenses detected
        RESULT
    end

    it 'matches included/excluded files correctly when . argument is given' do
      create_file('example.rb', 'x = 0')
      create_file('special.dsl', 'setup { "stuff" }')
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Include:
            - "*.dsl"
          Exclude:
            - example.rb
      YAML
      expect(cli.run(%w[--format simple .])).to eq(1)
      expect($stdout.string)
        .to eq(['== special.dsl ==',
                "C:  1:  9: Prefer single-quoted strings when you don't " \
                'need string interpolation or special symbols.',
                '',
                '1 file inspected, 1 offense detected',
                ''].join("\n"))
    end

    # With rubinius 2.0.0.rc1 + rspec 2.13.1,
    # File.stub(:open).and_call_original causes SystemStackError.
    it 'does not read files in excluded list', broken: :rbx do
      %w[rb.rb non-rb.ext without-ext].each do |filename|
        create_file("example/ignored/#{filename}", '#' * 90)
      end

      create_file('example/.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Exclude:
            - ignored/**
      YAML
      expect(File).not_to receive(:open).with(%r{/ignored/})
      allow(File).to receive(:open).and_call_original
      expect(cli.run(%w[--format simple example])).to eq(0)
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'can be configured with option to disable a certain error' do
      create_file('example1.rb', 'puts 0 ')
      create_file('rubocop.yml', <<-YAML.strip_indent)
        Style/Encoding:
          Enabled: false

        Layout/CaseIndentation:
          Enabled: false
      YAML
      expect(cli.run(['--format', 'simple',
                      '-c', 'rubocop.yml', 'example1.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)
          == example1.rb ==
          C:  1:  7: Trailing whitespace detected.

          1 file inspected, 1 offense detected
        RESULT
    end

    context 'without using namespace' do
      it 'can be configured with option to disable a certain error' do
        create_file('example1.rb', 'puts 0 ')
        create_file('rubocop.yml', <<-YAML.strip_indent)
          Encoding:
            Enabled: false

          CaseIndentation:
            Enabled: false
        YAML
        expect(cli.run(['--format', 'simple',
                        '-c', 'rubocop.yml', 'example1.rb'])).to eq(1)
        expect($stdout.string)
          .to eq(<<-RESULT.strip_indent)
            == example1.rb ==
            C:  1:  7: Trailing whitespace detected.

            1 file inspected, 1 offense detected
          RESULT
      end
    end

    it 'can disable parser-derived offenses with warning severity' do
      # `-' interpreted as argument prefix
      create_file('example.rb', 'puts -1')
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        Style/Encoding:
          Enabled: false

        Lint/AmbiguousOperator:
          Enabled: false
      YAML
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(0)
    end

    it 'cannot disable Syntax offenses' do
      create_file('example.rb', 'class Test')
      create_file('.rubocop.yml', <<-YAML.strip_indent)
        Style/Encoding:
          Enabled: false

        Syntax:
          Enabled: false
      YAML
      expect(cli.run(['--format', 'emacs', 'example.rb'])).to eq(2)
      expect($stderr.string).to include(
        'Error: configuration for Syntax cop found'
      )
      expect($stderr.string).to include('This cop cannot be configured.')
    end

    it 'can be configured to merge a parameter that is a hash' do
      create_file('example1.rb', ['puts %w(a b c)', 'puts %q|hi|'])
      # We want to change the preferred delimiters for word arrays. The other
      # settings from default.yml are unchanged.
      create_file('rubocop.yml', <<-YAML.strip_indent)
        Style/PercentLiteralDelimiters:
          PreferredDelimiters:
            '%w': '[]'
            '%W': '[]'
      YAML
      cli.run(['--format', 'simple', '-c', 'rubocop.yml', 'example1.rb'])
      expect($stdout.string)
        .to eq(['== example1.rb ==',
                'C:  1:  6: %w-literals should be delimited by [ and ].',
                'C:  2:  6: %q-literals should be delimited by ( and ).',
                'C:  2:  6: Use %q only for strings that contain both single ' \
                'quotes and double quotes.',
                '',
                '1 file inspected, 3 offenses detected',
                ''].join("\n"))
    end

    it 'can be configured to override a parameter that is a hash in a ' \
       'special case' do
      create_file('example1.rb', <<-RUBY.strip_indent)
        arr.select { |e| e > 0 }.collect { |e| e * 2 }
        a2.find_all { |e| e > 0 }
      RUBY
      # We prefer find_all over select. This setting overrides the default
      # select over find_all. Other preferred methods appearing in the default
      # config (e.g., map over collect) are kept.
      create_file('rubocop.yml', <<-YAML.strip_indent)
        Style/CollectionMethods:
          PreferredMethods:
            select: find_all
      YAML
      cli.run(['--format',
               'simple',
               '-c',
               'rubocop.yml',
               '--only',
               'CollectionMethods',
               'example1.rb'])
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)
          == example1.rb ==
          C:  1:  5: Prefer find_all over select.
          C:  1: 26: Prefer map over collect.

          1 file inspected, 2 offenses detected
        RESULT
    end

    it 'works when a cop that others depend on is disabled' do
      create_file('example1.rb', <<-RUBY.strip_indent)
        if a
          b
        end
      RUBY
      create_file('rubocop.yml', <<-YAML.strip_indent)
        Style/Encoding:
          Enabled: false

        Metrics/LineLength:
          Enabled: false
      YAML
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
      create_file('example_src/.rubocop.yml', <<-YAML.strip_indent)
        Style/Encoding:
          Enabled: false

        Layout/CaseIndentation:
          Enabled: false
      YAML
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(1)
      expect($stdout.string)
        .to eq(<<-RESULT.strip_indent)
          == example_src/example1.rb ==
          C:  1:  7: Trailing whitespace detected.

          1 file inspected, 1 offense detected
        RESULT
    end

    it 'can use an alternative max line length from a config file' do
      create_file('example_src/example1.rb', '#' * 90)
      create_file('example_src/.rubocop.yml', <<-YAML.strip_indent)
        Metrics/LineLength:
          Enabled: true
          Max: 100
      YAML
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(0)
      expect($stdout.string)
        .to eq(['', '1 file inspected, no offenses detected', ''].join("\n"))
    end

    it 'can have different config files in different directories' do
      %w[src lib].each do |dir|
        create_file("example/#{dir}/example1.rb", '#' * 90)
      end
      create_file('example/src/.rubocop.yml', <<-YAML.strip_indent)
        Metrics/LineLength:
          Enabled: true
          Max: 100
      YAML
      expect(cli.run(%w[--format simple example])).to eq(1)
      expect($stdout.string).to eq(<<-RESULT.strip_indent)
        == example/lib/example1.rb ==
        C:  1: 81: Line is too long. [90/80]

        2 files inspected, 1 offense detected
      RESULT
    end

    it 'prefers a config file in ancestor directory to another in home' do
      create_file('example_src/example1.rb', '#' * 90)
      create_file('example_src/.rubocop.yml', <<-YAML.strip_indent)
        Metrics/LineLength:
          Enabled: true
          Max: 100
      YAML
      create_file("#{Dir.home}/.rubocop.yml", <<-YAML.strip_indent)
        Metrics/LineLength:
          Enabled: true
          Max: 80
      YAML
      expect(cli.run(['--format', 'simple',
                      'example_src/example1.rb'])).to eq(0)
      expect($stdout.string)
        .to eq(['', '1 file inspected, no offenses detected', ''].join("\n"))
    end

    it 'can exclude directories relative to .rubocop.yml' do
      %w[src etc/test etc/spec tmp/test tmp/spec].each do |dir|
        create_file("example/#{dir}/example1.rb", '#' * 90)
      end

      # Hidden subdirectories should also be excluded.
      create_file('example/etc/.dot/example1.rb', '#' * 90)

      create_file('example/.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Exclude:
            - src/**
            - etc/**/*
            - tmp/spec/**
      YAML

      expect(cli.run(%w[--format simple example])).to eq(1)
      expect($stderr.string).to eq('')
      expect($stdout.string).to eq(<<-RESULT.strip_indent)
        == example/tmp/test/example1.rb ==
        C:  1: 81: Line is too long. [90/80]

        1 file inspected, 1 offense detected
      RESULT
    end

    it 'can exclude a typical vendor directory' do
      create_file(
        'vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/.rubocop.yml',
        <<-YAML.strip_indent
          AllCops:
            Exclude:
              - lib/parser/lexer.rb
        YAML
      )

      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/lib/ex.rb',
                  '#' * 90)

      create_file('.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Exclude:
            - vendor/**/*
      YAML

      cli.run(%w[--format simple])
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'excludes the vendor directory by default' do
      create_file('vendor/ex.rb', '#' * 90)

      cli.run(%w[--format simple])
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
                  '#' * 90)

      create_file('.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Exclude:
            - vendor/**/*
      YAML

      cli.run(%w[--format simple])
      expect($stderr.string).to eq('')
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    # Relative exclude paths in .rubocop.yml files are relative to that file,
    # but in configuration files with other names they will be relative to
    # whatever file inherits from them.
    it 'can exclude a vendor directory indirectly' do
      create_file(
        'vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/.rubocop.yml',
        <<-YAML.strip_indent
          AllCops:
            Exclude:
              - lib/parser/lexer.rb
        YAML
      )

      create_file('vendor/bundle/ruby/1.9.1/gems/parser-2.0.0/lib/ex.rb',
                  '#' * 90)

      create_file('.rubocop.yml',
                  ['inherit_from: config/default.yml'])

      create_file('config/default.yml', <<-YAML.strip_indent)
        AllCops:
          Exclude:
            - vendor/**/*
      YAML

      cli.run(%w[--format simple])
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'prints a warning for an unrecognized cop name in .rubocop.yml' do
      create_file('example/example1.rb', '#' * 90)

      create_file('example/.rubocop.yml', <<-YAML.strip_indent)
        Style/LyneLenth:
          Enabled: true
          Max: 100
      YAML

      expect(cli.run(%w[--format simple example])).to eq(1)
      expect($stderr.string)
        .to eq(['Warning: unrecognized cop Style/LyneLenth found in ' +
                abs('example/.rubocop.yml'),
                ''].join("\n"))
    end

    it 'prints a warning for an unrecognized configuration parameter' do
      create_file('example/example1.rb', '#' * 90)

      create_file('example/.rubocop.yml', <<-YAML.strip_indent)
        Metrics/LineLength:
          Enabled: true
          Min: 10
      YAML

      expect(cli.run(%w[--format simple example])).to eq(1)
      expect($stderr.string)
        .to eq(['Warning: unrecognized parameter Metrics/LineLength:Min ' \
                'found in ' + abs('example/.rubocop.yml'),
                ''].join("\n"))
    end

    it 'prints an error message for an unrecognized EnforcedStyle' do
      create_file('example/example1.rb', 'puts "hello"')
      create_file('example/.rubocop.yml', <<-YAML.strip_indent)
        Style/BracesAroundHashParameters:
          EnforcedStyle: context
      YAML

      expect(cli.run(%w[--format simple example])).to eq(2)
      expect($stderr.string)
        .to eq(["Error: invalid EnforcedStyle 'context' for " \
                'Style/BracesAroundHashParameters found in ' +
                abs('example/.rubocop.yml'),
                'Valid choices are: braces, no_braces, context_dependent',
                ''].join("\n"))
    end

    it 'works when a configuration file passed by -c specifies Exclude ' \
       'with regexp' do
      create_file('example/example1.rb', '#' * 90)

      create_file('rubocop.yml', <<-'YAML'.strip_indent)
        AllCops:
          Exclude:
            - !ruby/regexp /example1\.rb$/
      YAML

      cli.run(%w[--format simple -c rubocop.yml])
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    it 'works when a configuration file passed by -c specifies Exclude ' \
       'with strings' do
      create_file('example/example1.rb', '#' * 90)

      create_file('rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Exclude:
            - example/**
      YAML

      cli.run(%w[--format simple -c rubocop.yml])
      expect($stdout.string)
        .to eq(['', '0 files inspected, no offenses detected',
                ''].join("\n"))
    end

    shared_examples 'specified Severity' do |key|
      it 'works when a configuration file specifies Severity for ' \
         "Metrics/ParameterLists and #{key}" do
        create_file('example/example1.rb', <<-RUBY.strip_indent)
          def method(a, b, c, d, e, f) end #{'#' * 57}
        RUBY

        create_file('rubocop.yml', <<-YAML.strip_indent)
          #{key}:
            Severity: error
          Metrics/ParameterLists:
            Severity: convention
        YAML

        cli.run(%w[--format simple -c rubocop.yml])
        expect($stdout.string).to eq(<<-RESULT.strip_indent)
            == example/example1.rb ==
            C:  1: 11: Avoid parameter lists longer than 5 parameters. [6/5]
            E:  1: 81: Line is too long. [90/80]

            1 file inspected, 2 offenses detected
        RESULT
        expect($stderr.string).to eq('')
      end
    end

    include_examples 'specified Severity', 'Metrics/LineLength'
    include_examples 'specified Severity', 'Metrics'

    it 'fails when a configuration file specifies an invalid Severity' do
      create_file('example/example1.rb', '#' * 90)

      create_file('rubocop.yml', <<-YAML.strip_indent)
        Metrics/LineLength:
          Severity: superbad
      YAML

      cli.run(%w[--format simple -c rubocop.yml])
      expect($stderr.string)
        .to eq(["Warning: Invalid severity 'superbad'. " \
                'Valid severities are refactor, convention, ' \
                'warning, error, fatal.',
                ''].join("\n"))
    end

    it 'fails when a configuration file has invalid YAML syntax' do
      create_file('example/.rubocop.yml', <<-YAML.strip_indent)
        AllCops:
          Exclude:
            - **/*_old.rb
      YAML

      cli.run(['example'])
      # MRI and JRuby return slightly different error messages.
      expect($stderr.string)
        .to match(%r{^\(\S+example/\.rubocop\.yml\):\ (did\ not\ find\ )?
                  expected\ alphabetic\ or \ numeric\ character}x)
    end

    context 'when a file inherits from a higher level' do
      before do
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Metrics/LineLength:
            Exclude:
              - dir/example.rb
        YAML
        create_file('dir/.rubocop.yml', 'inherit_from: ../.rubocop.yml')
        create_file('dir/example.rb', '#' * 90)
      end

      it 'inherits relative excludes correctly' do
        expect(cli.run([])).to eq(0)
      end
    end

    context 'when configuration is taken from $HOME/.rubocop.yml' do
      before do
        create_file("#{Dir.home}/.rubocop.yml", <<-YAML.strip_indent)
          Metrics/LineLength:
            Exclude:
              - dir/example.rb
        YAML
        create_file('dir/example.rb', '#' * 90)
      end

      it 'handles relative excludes correctly when run from project root' do
        expect(cli.run([])).to eq(0)
      end
    end

    it 'shows an error if the input file cannot be found' do
      begin
        cli.run(%w[/tmp/not_a_file])
      rescue SystemExit => e
        expect(e.status).to eq(1)
        expect(e.message)
          .to eq 'rubocop: No such file or directory -- /tmp/not_a_file'
      end
    end
  end

  describe 'configuration of target Ruby versions' do
    context 'when configured with an unknown version' do
      it 'fails with an error message' do
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          AllCops:
            TargetRubyVersion: 2.5
        YAML
        expect(cli.run([])).to eq(2)
        expect($stderr.string.strip).to match(
          /\AError: Unknown Ruby version 2.5 found in `TargetRubyVersion`/
        )
        expect($stderr.string.strip).to match(
          /Known versions: 2.0, 2.1, 2.2, 2.3, 2.4/
        )
      end
    end
  end

  describe 'obsolete cops' do
    context 'when configuration for TrailingComma is given' do
      it 'fails with an error message' do
        create_file('example1.rb', "puts 'hello'")
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Style/TrailingComma:
            Enabled: true
        YAML
        expect(cli.run(['example1.rb'])).to eq(2)
        expect($stderr.string.strip).to eq(
          ['Error: The `Style/TrailingComma` cop no longer exists. Please ' \
           'use `Style/TrailingCommaInLiteral` and/or ' \
           '`Style/TrailingCommaInArguments` instead.',
           "(obsolete configuration found in #{abs('.rubocop.yml')}, " \
           'please update it)'].join("\n")
        )
      end
    end
  end
end
