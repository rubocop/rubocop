# frozen_string_literal: true

RSpec.describe RuboCop::Options, :isolated_environment do
  include FileHelper

  subject(:options) { described_class.new }

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  def abs(path)
    File.expand_path(path)
  end

  describe 'option' do
    describe '-h/--help' do
      it 'exits cleanly' do
        expect { options.parse ['-h'] }.to exit_with_code(0)
        expect { options.parse ['--help'] }.to exit_with_code(0)
      end

      it 'shows help text' do
        begin
          options.parse(['--help'])
        rescue SystemExit # rubocop:disable Lint/SuppressedException
        end

        # rubocop:todo Naming/InclusiveLanguage
        expected_help = <<~OUTPUT
          Usage: rubocop [options] [file1, file2, ...]

          Basic Options:
              -l, --lint                       Run only lint cops.
              -x, --fix-layout                 Run only layout cops, with autocorrect on.
                  --safe                       Run only safe cops.
                  --except [COP1,COP2,...]     Exclude the given cop(s).
                  --only [COP1,COP2,...]       Run only the given cop(s).
                  --only-guide-cops            Run only cops for rules that link to a
                                               style guide.
              -F, --fail-fast                  Inspect files in order of modification
                                               time and stop after the first file
                                               containing offenses.
                  --disable-pending-cops       Run without pending cops.
                  --enable-pending-cops        Run with pending cops.
                  --ignore-disable-comments    Run cops even when they are disabled locally
                                               by a `rubocop:disable` directive.
                  --force-exclusion            Any files excluded by `Exclude` in configuration
                                               files will be excluded, even if given explicitly
                                               as arguments.
                  --only-recognized-file-types Inspect files given on the command line only if
                                               they are listed in `AllCops/Include` parameters
                                               of user configuration or default configuration.
                  --ignore-parent-exclusion    Prevent from inheriting `AllCops/Exclude` from
                                               parent folders.
                  --ignore-unrecognized-cops   Ignore unrecognized cops or departments in the config.
                  --force-default-config       Use default configuration even if configuration
                                               files are present in the directory tree.
              -s, --stdin FILE                 Pipe source from STDIN, using FILE in offense
                                               reports. This is useful for editor integration.
              -P, --[no-]parallel              Use available CPUs to execute inspection in
                                               parallel. Default is true.
                  --raise-cop-error            Raise cop-related errors with cause and location.
                                               This is used to prevent cops from failing silently.
                                               Default is false.
                  --fail-level SEVERITY        Minimum severity for exit with error code.
                                                 [A] autocorrect
                                                 [I] info
                                                 [R] refactor
                                                 [C] convention
                                                 [W] warning
                                                 [E] error
                                                 [F] fatal

          Caching:
              -C, --cache FLAG                 Use result caching (FLAG=true) or don't
                                               (FLAG=false), default determined by
                                               configuration parameter AllCops: UseCache.
                  --cache-root DIR             Set the cache root directory.
                                               Takes precedence over the configuration
                                               parameter AllCops: CacheRootDirectory and
                                               the $RUBOCOP_CACHE_ROOT environment variable.

          Server Options:
                  --[no-]server                If a server process has not been started yet, start
                                               the server process and execute inspection with server.
                                               Default is false.
                                               You can specify the server host and port with the
                                               $RUBOCOP_SERVER_HOST and the $RUBOCOP_SERVER_PORT
                                               environment variables.
                  --restart-server             Restart server process.
                  --start-server               Start server process.
                  --stop-server                Stop server process.
                  --server-status              Show server status.
                  --no-detach                  Run the server process in the foreground.

          Output Options:
              -f, --format FORMATTER           Choose an output formatter. This option
                                               can be specified multiple times to enable
                                               multiple formatters at the same time.
                                                 [a]utogenconf
                                                 [c]lang
                                                 [e]macs
                                                 [fi]les
                                                 [fu]ubar
                                                 [g]ithub
                                                 [h]tml
                                                 [j]son
                                                 [ju]nit
                                                 [m]arkdown
                                                 [o]ffenses
                                                 [pa]cman
                                                 [p]rogress (default)
                                                 [q]uiet
                                                 [s]imple
                                                 [t]ap
                                                 [w]orst
                                                 custom formatter class name
              -D, --[no-]display-cop-names     Display cop names in offense messages.
                                               Default is true.
              -E, --extra-details              Display extra details in offense messages.
              -S, --display-style-guide        Display style guide URLs in offense messages.
              -o, --out FILE                   Write output to a file instead of STDOUT.
                                               This option applies to the previously
                                               specified --format, or the default format
                                               if no format is specified.
                  --stderr                     Write all output to stderr except for the
                                               autocorrected source. This is especially useful
                                               when combined with --autocorrect and --stdin.
                  --display-time               Display elapsed time in seconds.
                  --display-only-failed        Only output offense messages. Omit passing
                                               cops. Only valid for --format junit.
                  --display-only-fail-level-offenses
                                               Only output offense messages at
                                               the specified --fail-level or above
                  --display-only-correctable   Only output correctable offense messages.
                  --display-only-safe-correctable
                                               Only output safe-correctable offense messages
                                               when combined with --display-only-correctable.

          Autocorrection:
              -a, --autocorrect                Autocorrect offenses (only when it's safe).
                  --auto-correct               (same, deprecated)
                  --safe-auto-correct          (same, deprecated)
              -A, --autocorrect-all            Autocorrect offenses (safe and unsafe).
                  --auto-correct-all           (same, deprecated)
                  --disable-uncorrectable      Used with --autocorrect to annotate any
                                               offenses that do not support autocorrect
                                               with `rubocop:todo` comments.

          Config Generation:
                  --auto-gen-config            Generate a configuration file acting as a
                                               TODO list.
                  --regenerate-todo            Regenerate the TODO configuration file using
                                               the last configuration. If there is no existing
                                               TODO file, acts like --auto-gen-config.
                  --exclude-limit COUNT        Set the limit for how many files to explicitly exclude.
                                               If there are more files than the limit, the cop will
                                               be disabled instead. Default is 15.
                  --no-exclude-limit           Do not set the limit for how many files to exclude.
                  --[no-]offense-counts        Include offense counts in configuration
                                               file generated by --auto-gen-config.
                                               Default is true.
                  --[no-]auto-gen-only-exclude Generate only Exclude parameters and not Max
                                               when running --auto-gen-config, except if the
                                               number of files with offenses is bigger than
                                               exclude-limit. Default is false.
                  --[no-]auto-gen-timestamp    Include the date and time when the --auto-gen-config
                                               was run in the file it generates. Default is true.
                  --[no-]auto-gen-enforced-style
                                               Add a setting to the TODO configuration file to enforce
                                               the style used, rather than a per-file exclusion
                                               if one style is used in all files for cop with
                                               EnforcedStyle as a configurable option
                                               when the --auto-gen-config was run
                                               in the file it generates. Default is true.

          Additional Modes:
              -L, --list-target-files          List all files RuboCop will inspect.
                  --show-cops [COP1,COP2,...]  Shows the given cops, or all cops by
                                               default, and their configurations for the
                                               current directory.
                  --show-docs-url [COP1,COP2,...]
                                               Display url to documentation for the given
                                               cops, or base url by default.

          General Options:
                  --init                       Generate a .rubocop.yml file in the current directory.
              -c, --config FILE                Specify configuration file.
              -d, --debug                      Display debug info.
              -r, --require FILE               Require Ruby file.
                  --[no-]color                 Force color output on or off.
              -v, --version                    Display version.
              -V, --verbose-version            Display verbose version.
        OUTPUT
        # rubocop:enable Naming/InclusiveLanguage

        if RUBY_ENGINE == 'ruby' && !RuboCop::Platform.windows?
          expected_help += <<~OUTPUT

            Profiling Options:
                    --profile                    Profile rubocop
                    --memory                     Profile rubocop memory usage
          OUTPUT
        end

        expect($stdout.string).to eq(expected_help)
      end

      it 'lists all builtin formatters' do
        begin
          options.parse(['--help'])
        rescue SystemExit # rubocop:disable Lint/SuppressedException
        end

        option_sections = $stdout.string.lines.slice_before(/^\s*-/)

        format_section = option_sections.find { |lines| /^\s*-f/.match?(lines.first) }

        formatter_keys = format_section.reduce([]) do |keys, line|
          match = line.match(/^ {39}(\[[a-z\]]+)/)
          next keys unless match

          keys << match.captures.first
        end.sort

        expected_formatter_keys =
          RuboCop::Formatter::FormatterSet::BUILTIN_FORMATTERS_FOR_KEYS.keys.sort

        expect(formatter_keys).to eq(expected_formatter_keys)
      end
    end

    describe 'incompatible cli options' do
      it 'rejects using -v with -V' do
        msg = 'Incompatible cli options: [:version, :verbose_version]'
        expect { options.parse %w[-vV] }.to raise_error(RuboCop::OptionArgumentError, msg)
      end

      it 'rejects using -v with --show-cops' do
        msg = 'Incompatible cli options: [:version, :show_cops]'
        expect { options.parse %w[-v --show-cops] }
          .to raise_error(RuboCop::OptionArgumentError, msg)
      end

      it 'rejects using -V with --show-cops' do
        msg = 'Incompatible cli options: [:verbose_version, :show_cops]'
        expect { options.parse %w[-V --show-cops] }
          .to raise_error(RuboCop::OptionArgumentError, msg)
      end

      it 'mentions all incompatible options when more than two are used' do
        msg = 'Incompatible cli options: [:version, :verbose_version, :show_cops]'
        expect { options.parse %w[-vV --show-cops] }
          .to raise_error(RuboCop::OptionArgumentError, msg)
      end
    end

    describe '--fix-layout' do
      it 'sets some autocorrect options' do
        options.parse %w[--fix-layout]
        expect_autocorrect_options_for_fix_layout
      end
    end

    describe '--parallel' do
      context 'combined with --cache false' do
        it 'ignores --parallel' do
          msg = '-P/--parallel is being ignored because it is not compatible with --cache false'
          options.parse %w[--parallel --cache false]
          expect($stdout.string.include?(msg)).to be(true)
          expect(options.instance_variable_get(:@options).key?(:parallel)).to be(false)
        end
      end

      context 'combined with an autocorrect argument' do
        context 'combined with --fix-layout' do
          it 'allows --parallel' do
            options.parse %w[--parallel --fix-layout]
            expect($stdout.string.include?('-P/--parallel is being ignored')).to be(false)
            expect(options.instance_variable_get(:@options).key?(:parallel)).to be(true)
          end
        end

        context 'combined with --autocorrect' do
          it 'allows --parallel' do
            options.parse %w[--parallel --autocorrect]
            expect($stdout.string.include?('-P/--parallel is being ignored')).to be(false)
            expect(options.instance_variable_get(:@options).key?(:parallel)).to be(true)
          end
        end

        context 'combined with --autocorrect-all' do
          it 'allows --parallel' do
            options.parse %w[--parallel --autocorrect-all]
            expect($stdout.string.include?('-P/--parallel is being ignored')).to be(false)
            expect(options.instance_variable_get(:@options).key?(:parallel)).to be(true)
          end
        end
      end

      context 'combined with --auto-gen-config' do
        it 'ignores --parallel' do
          msg = '-P/--parallel is being ignored because it is not compatible with --auto-gen-config'
          options.parse %w[--parallel --auto-gen-config]
          expect($stdout.string.include?(msg)).to be(true)
          expect(options.instance_variable_get(:@options).key?(:parallel)).to be(false)
        end
      end

      context 'combined with --fail-fast' do
        it 'ignores --parallel' do
          msg = '-P/--parallel is being ignored because it is not compatible with -F/--fail-fast'
          options.parse %w[--parallel --fail-fast]
          expect($stdout.string.include?(msg)).to be(true)
          expect(options.instance_variable_get(:@options).key?(:parallel)).to be(false)
        end
      end

      context 'combined with two incompatible arguments' do
        it 'ignores --parallel and lists both incompatible arguments' do
          options.parse %w[--parallel --fail-fast --autocorrect]
          expect($stdout.string.include?('-P/--parallel is being ignored because it is not ' \
                                         'compatible with -F/--fail-fast')).to be(true)
          expect(options.instance_variable_get(:@options).key?(:parallel)).to be(false)
        end
      end
    end

    describe '--no-parallel' do
      it 'disables parallel from file' do
        results = options.parse %w[--no-parallel]
        expect(results).to eq([{ parallel: false }, []])
      end
    end

    describe '--display-only-failed' do
      it 'fails if given without --format junit' do
        expect { options.parse %w[--display-only-failed] }
          .to raise_error(RuboCop::OptionArgumentError)
      end

      it 'works if given with --format junit' do
        expect { options.parse %w[--format junit --display-only-failed] }
          .not_to raise_error(RuboCop::OptionArgumentError)
      end
    end

    describe '--display-only-fail-level-offenses' do
      it 'fails if given with an autocorrect argument' do
        %w[--fix-layout -x --autocorrect -a --autocorrect-all -A].each do |o|
          expect { options.parse ['--display-only-correctable', o] }
            .to raise_error(RuboCop::OptionArgumentError)
        end
      end
    end

    describe '--display-only-correctable' do
      it 'fails if given with --display-only-failed' do
        expect { options.parse %w[--display-only-correctable --display-only-failed] }
          .to raise_error(RuboCop::OptionArgumentError)
      end

      it 'fails if given with an autocorrect argument' do
        %w[--fix-layout -x --autocorrect -a --autocorrect-all -A].each do |o|
          expect { options.parse ['--display-only-correctable', o] }
            .to raise_error(RuboCop::OptionArgumentError)
        end
      end
    end

    describe '--fail-level' do
      it 'accepts full severity names' do
        %w[info refactor convention warning error fatal].each do |severity|
          expect { options.parse(['--fail-level', severity]) }.not_to raise_error
        end
      end

      it 'accepts severity initial letters' do
        %w[I R C W E F].each do |severity|
          expect { options.parse(['--fail-level', severity]) }.not_to raise_error
        end
      end

      it 'accepts the "fake" severities A/autocorrect' do
        %w[autocorrect A].each do |severity|
          expect { options.parse(['--fail-level', severity]) }.not_to raise_error
        end
      end
    end

    describe '--raise-cop-error' do
      it 'raises cop errors' do
        results = options.parse %w[--raise-cop-error]
        expect(results).to eq([{ raise_cop_error: true }, []])
      end
    end

    describe '--require' do
      let(:required_file_path) { './path/to/required_file.rb' }

      before do
        create_empty_file('example.rb')

        create_file(required_file_path, "puts 'Hello from required file!'")
      end

      it 'requires the passed path' do
        options.parse(['--require', required_file_path, 'example.rb'])
        expect($stdout.string).to start_with('Hello from required file!')
      end
    end

    describe '--cache' do
      it 'fails if no argument is given' do
        expect { options.parse %w[--cache] }.to raise_error(OptionParser::MissingArgument)
      end

      it 'fails if unrecognized argument is given' do
        expect { options.parse %w[--cache maybe] }.to raise_error(RuboCop::OptionArgumentError)
      end

      it 'accepts true as argument' do
        expect { options.parse %w[--cache true] }.not_to raise_error
      end

      it 'accepts false as argument' do
        expect { options.parse %w[--cache false] }.not_to raise_error
      end
    end

    describe '--cache-root' do
      it 'fails if no argument is given' do
        expect { options.parse %w[--cache-root] }.to raise_error(OptionParser::MissingArgument)
      end

      it 'fails if also `--cache false` is given' do
        expect { options.parse %w[--cache false --cache-root /some/dir] }
          .to raise_error(RuboCop::OptionArgumentError)
      end

      it 'accepts a path as argument' do
        expect { options.parse %w[--cache-root /some/dir] }.not_to raise_error
      end
    end

    describe '--disable-uncorrectable' do
      it 'accepts together with a safe autocorrect argument' do
        %w[--fix-layout -x --autocorrect -a].each do |o|
          expect { options.parse ['--disable-uncorrectable', o] }.not_to raise_error
        end
      end

      it 'accepts together with an unsafe autocorrect argument' do
        %w[--fix-layout -x --autocorrect-all -A].each do |o|
          expect { options.parse ['--disable-uncorrectable', o] }.not_to raise_error
        end
      end

      it 'fails if given without an autocorrect argument' do
        expect { options.parse %w[--disable-uncorrectable] }
          .to raise_error(RuboCop::OptionArgumentError)
      end
    end

    describe '--exclude-limit' do
      it 'fails if given last without argument' do
        expect { options.parse %w[--auto-gen-config --exclude-limit] }
          .to raise_error(OptionParser::MissingArgument)
      end

      it 'fails if given alone without argument' do
        expect { options.parse %w[--exclude-limit] }.to raise_error(OptionParser::MissingArgument)
      end

      it 'fails if given first without argument' do
        expect { options.parse %w[--exclude-limit --auto-gen-config] }
          .to raise_error(OptionParser::MissingArgument)
      end

      it 'fails if given without --auto-gen-config' do
        expect { options.parse %w[--exclude-limit 10] }.to raise_error(RuboCop::OptionArgumentError)
      end
    end

    describe '--autocorrect' do
      context 'Specify only --autocorrect' do
        it 'sets some autocorrect options' do
          options.parse %w[--autocorrect]
          expect_autocorrect_options_for_autocorrect
        end
      end

      context 'Specify --autocorrect and --autocorrect-all' do
        it 'emits a warning and sets some autocorrect options' do
          expect { options.parse options.parse %w[--autocorrect --autocorrect-all] }.to raise_error(
            RuboCop::OptionArgumentError,
            /Error: Both safe and unsafe autocorrect options are specified, use only one./
          )
        end
      end
    end

    describe '--autocorrect-all' do
      it 'sets some autocorrect options' do
        options.parse %w[--autocorrect-all]
        expect_autocorrect_options_for_autocorrect_all
      end
    end

    describe '--auto-gen-only-exclude' do
      it 'fails if given without --auto-gen-config' do
        expect { options.parse %w[--auto-gen-only-exclude] }
          .to raise_error(RuboCop::OptionArgumentError)
      end
    end

    describe '--auto-gen-config' do
      it 'accepts other options' do
        expect { options.parse %w[--auto-gen-config --lint] }.not_to raise_error
      end
    end

    describe '--regenerate-todo' do
      subject(:parsed_options) { options.parse(command_line_options).first }

      let(:config_regeneration) do
        instance_double(RuboCop::ConfigRegeneration, options: todo_options)
      end
      let(:todo_options) { { auto_gen_config: true, exclude_limit: '100', offense_counts: false } }

      before do
        allow(RuboCop::ConfigRegeneration).to receive(:new).and_return(config_regeneration)
      end

      context 'when no other options are given' do
        let(:command_line_options) { %w[--regenerate-todo] }
        let(:expected_options) do
          {
            auto_gen_config: true,
            exclude_limit: '100',
            offense_counts: false,
            regenerate_todo: true
          }
        end

        it { is_expected.to eq(expected_options) }
      end

      context 'when todo options are overridden before --regenerate-todo' do
        let(:command_line_options) { %w[--exclude-limit 50 --regenerate-todo] }
        let(:expected_options) do
          {
            auto_gen_config: true,
            exclude_limit: '50',
            offense_counts: false,
            regenerate_todo: true
          }
        end

        it { is_expected.to eq(expected_options) }
      end

      context 'when todo options are overridden after --regenerate-todo' do
        let(:command_line_options) { %w[--regenerate-todo --exclude-limit 50] }
        let(:expected_options) do
          {
            auto_gen_config: true,
            exclude_limit: '50',
            offense_counts: false,
            regenerate_todo: true
          }
        end

        it { is_expected.to eq(expected_options) }
      end

      context 'when disabled options are overridden to be enabled' do
        let(:command_line_options) { %w[--regenerate-todo --offense-counts] }
        let(:expected_options) do
          {
            auto_gen_config: true,
            exclude_limit: '100',
            offense_counts: true,
            regenerate_todo: true
          }
        end

        it { is_expected.to eq(expected_options) }
      end
    end

    describe '-s/--stdin' do
      before do
        $stdin = StringIO.new
        $stdin.puts("{ foo: 'bar' }")
        $stdin.rewind
      end

      it 'fails if no paths are given' do
        expect { options.parse %w[-s] }.to raise_error(OptionParser::MissingArgument)
      end

      it 'succeeds with exactly one path' do
        expect { options.parse %w[--stdin foo] }.not_to raise_error
      end

      it 'fails if more than one path is given' do
        expect { options.parse %w[--stdin foo bar] }.to raise_error(RuboCop::OptionArgumentError)
      end
    end

    # rubocop:todo Naming/InclusiveLanguage
    describe 'deprecated options' do
      describe '--auto-correct' do
        it 'emits a warning and sets the correct options instead' do
          options.parse %w[--auto-correct]
          expect($stderr.string.include?('--auto-correct is deprecated; use --autocorrect'))
            .to be(true)
          expect(options.instance_variable_get(:@options).key?(:auto_correct)).to be(false)
          expect_autocorrect_options_for_autocorrect
        end
      end

      describe '--safe-auto-correct' do
        it 'emits a warning and sets the correct options instead' do
          options.parse %w[--safe-auto-correct]
          expect($stderr.string.include?('--safe-auto-correct is deprecated; use --autocorrect'))
            .to be(true)
          expect(options.instance_variable_get(:@options).key?(:safe_auto_correct)).to be(false)
          expect_autocorrect_options_for_autocorrect
        end
      end

      describe '--auto-correct-all' do
        it 'emits a warning and sets the correct options instead' do
          options.parse %w[--auto-correct-all]
          expect($stderr.string.include?('--auto-correct-all is deprecated; ' \
                                         'use --autocorrect-all')).to be(true)
          expect(options.instance_variable_get(:@options).key?(:auto_correct_all)).to be(false)
          expect_autocorrect_options_for_autocorrect_all
        end
      end
    end
    # rubocop:enable Naming/InclusiveLanguage

    # rubocop:disable Metrics/AbcSize
    def expect_autocorrect_options_for_fix_layout
      options_keys = options.instance_variable_get(:@options).keys
      expect(options_keys.include?(:fix_layout)).to be(true)
      expect(options_keys.include?(:autocorrect)).to be(true)
      expect(options_keys.include?(:safe_autocorrect)).to be(false)
      expect(options_keys.include?(:autocorrect_all)).to be(false)
    end

    def expect_autocorrect_options_for_autocorrect
      options_keys = options.instance_variable_get(:@options).keys
      expect(options_keys.include?(:fix_layout)).to be(false)
      expect(options_keys.include?(:autocorrect)).to be(true)
      expect(options_keys.include?(:safe_autocorrect)).to be(true)
      expect(options_keys.include?(:autocorrect_all)).to be(false)
    end

    def expect_autocorrect_options_for_autocorrect_all
      options_keys = options.instance_variable_get(:@options).keys
      expect(options_keys.include?(:fix_layout)).to be(false)
      expect(options_keys.include?(:autocorrect)).to be(true)
      expect(options_keys.include?(:safe_autocorrect)).to be(false)
      expect(options_keys.include?(:autocorrect_all)).to be(true)
    end
    # rubocop:enable Metrics/AbcSize
  end

  describe 'options precedence' do
    def with_env_options(options)
      ENV['RUBOCOP_OPTS'] = options
      yield
    ensure
      ENV.delete('RUBOCOP_OPTS')
    end

    subject(:parsed_options) { options.parse(command_line_options).first }

    let(:command_line_options) { %w[--no-color] }

    describe '.rubocop file' do
      before { create_file('.rubocop', '--color --fail-level C') }

      it 'has lower precedence then command line options' do
        expect(parsed_options).to eq(color: false, fail_level: :convention)
      end

      it 'has lower precedence then options from RUBOCOP_OPTS env variable' do
        with_env_options '--fail-level W' do
          expect(parsed_options).to eq(color: false, fail_level: :warning)
        end
      end
    end

    describe '.rubocop directory' do
      before { FileUtils.mkdir '.rubocop' }

      it 'is ignored and command line options are used' do
        expect(parsed_options).to eq(color: false)
      end
    end

    context 'RUBOCOP_OPTS environment variable' do
      it 'has lower precedence then command line options' do
        with_env_options '--color' do
          expect(parsed_options).to eq(color: false)
        end
      end

      it 'has higher precedence then options from .rubocop file' do
        create_file('.rubocop', '--color --fail-level C')

        with_env_options '--fail-level W' do
          expect(parsed_options).to eq(color: false, fail_level: :warning)
        end
      end
    end
  end
end
