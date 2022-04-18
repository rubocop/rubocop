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
                  --force-default-config       Use default configuration even if configuration
                                               files are present in the directory tree.
              -s, --stdin FILE                 Pipe source from STDIN, using FILE in offense
                                               reports. This is useful for editor integration.
              -P, --[no-]parallel              Use available CPUs to execute inspection in
                                               parallel. Default is true.
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
                                               when combined with --auto-correct and --stdin.
                  --display-time               Display elapsed time in seconds.
                  --display-only-failed        Only output offense messages. Omit passing
                                               cops. Only valid for --format junit.
                  --display-only-fail-level-offenses
                                               Only output offense messages at
                                               the specified --fail-level or above

          Autocorrection:
              -a, --auto-correct               Autocorrect offenses (only when it's safe).
                  --safe-auto-correct          (same, deprecated)
              -A, --auto-correct-all           Autocorrect offenses (safe and unsafe)
                  --disable-uncorrectable      Used with --auto-correct to annotate any
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
                  --[no-]offense-counts        Include offense counts in configuration
                                               file generated by --auto-gen-config.
                                               Default is true.
                  --[no-]auto-gen-only-exclude Generate only Exclude parameters and not Max
                                               when running --auto-gen-config, except if the
                                               number of files with offenses is bigger than
                                               exclude-limit. Default is false.
                  --[no-]auto-gen-timestamp    Include the date and time when the --auto-gen-config
                                               was run in the file it generates. Default is true.

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

    describe '--parallel' do
      context 'combined with --cache false' do
        it 'ignores parallel' do
          msg = '-P/--parallel is being ignored because it is not compatible with --cache false'
          options.parse %w[--parallel --cache false]
          expect($stdout.string).to include(msg)
          expect(options.instance_variable_get(:@options).keys).not_to include(:parallel)
        end
      end

      context 'combined with --auto-correct' do
        it 'ignores parallel' do
          msg = '-P/--parallel is being ignored because it is not compatible with --auto-correct'
          options.parse %w[--parallel --auto-correct]
          expect($stdout.string).to include(msg)
          expect(options.instance_variable_get(:@options).keys).not_to include(:parallel)
        end
      end

      context 'combined with --auto-gen-config' do
        it 'ignore parallel' do
          msg = '-P/--parallel is being ignored because it is not compatible with --auto-gen-config'
          options.parse %w[--parallel --auto-gen-config]
          expect($stdout.string).to include(msg)
          expect(options.instance_variable_get(:@options).keys).not_to include(:parallel)
        end
      end

      context 'combined with --fail-fast' do
        it 'ignores parallel' do
          msg = '-P/--parallel is being ignored because it is not compatible with -F/--fail-fast'
          options.parse %w[--parallel --fail-fast]
          expect($stdout.string).to include(msg)
          expect(options.instance_variable_get(:@options).keys).not_to include(:parallel)
        end
      end
    end

    context 'combined with --auto-correct and --fail-fast' do
      it 'ignores parallel' do
        msg = '-P/--parallel is being ignored because it is not compatible with -F/--fail-fast'
        options.parse %w[--parallel --fail-fast --auto-correct]
        expect($stdout.string).to include(msg)
        expect(options.instance_variable_get(:@options).keys).not_to include(:parallel)
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
      it 'accepts together with --auto-correct' do
        expect { options.parse %w[--auto-correct --disable-uncorrectable] }.not_to raise_error
      end

      it 'accepts together with --auto-correct-all' do
        expect { options.parse %w[--auto-correct-all --disable-uncorrectable] }.not_to raise_error
      end

      it 'fails if given alone without --auto-correct/-a' do
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

    describe '--safe-auto-correct' do
      it 'is a deprecated alias' do
        expect { options.parse %w[--safe-auto-correct] }.to output(/deprecated/).to_stderr
      end
    end
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
