# encoding: utf-8

require 'spec_helper'

describe Rubocop::Options, :isolated_environment do
  include FileHelper

  subject(:options) { described_class.new }

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

  describe 'option' do
    describe '-h/--help' do
      it 'exits cleanly' do
        expect { options.parse ['-h'] }.to exit_with_code(0)
        expect { options.parse ['--help'] }.to exit_with_code(0)
      end

      it 'shows help text' do
        begin
          options.parse(['--help'])
        rescue SystemExit # rubocop:disable HandleExceptions
        end

        expected_help = <<-END
Usage: rubocop [options] [file1, file2, ...]
        --only COP                   Run just one cop.
    -c, --config FILE                Specify configuration file.
        --auto-gen-config            Generate a configuration file acting as a
                                     TODO list.
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
        --show-cops [cop1,cop2,...]  Shows the given cops, or all cops by
                                     default, and their configurations for the
                                     current directory.
    -d, --debug                      Display debug info.
    -D, --display-cop-names          Display cop names in offence messages.
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
          options.parse(['--help'])
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
          Rubocop::Formatter::FormatterSet::BUILTIN_FORMATTERS_FOR_KEYS
          .keys.sort

        expect(formatter_keys).to eq(expected_formatter_keys)
      end
    end

    describe '--only' do
      it 'exits with error if an incorrect cop name is passed' do
        expect { options.parse(%w(--only 123)) }
          .to raise_error(ArgumentError, /Unrecognized cop name: 123./)
      end
    end

    describe '--require' do
      let(:required_file_path) { './path/to/required_file.rb' }

      before do
        create_file('example.rb', '# encoding: utf-8')

        create_file(required_file_path, [
                                         '# encoding: utf-8',
                                         "puts 'Hello from required file!'"
                                        ])
      end

      it 'requires the passed path' do
        options.parse(['--require', required_file_path, 'example.rb'])
        expect($stdout.string).to start_with('Hello from required file!')
      end
    end
  end

  unless Rubocop::Version::STRING.start_with?('0')
    describe '-e/--emacs option' do
      it 'is dropped in RuboCop 1.0.0' do
        # This spec can be removed once the option is dropped.
        expect { options.parse(['--emacs']) }
          .to raise_error(OptionParser::InvalidOption)
      end
    end

    describe '-s/--silent option' do
      it 'raises error in RuboCop 1.0.0' do
        # This spec can be removed
        # once Options#ignore_dropped_options is removed.
        expect { options.parse(['--silent']) }
          .to raise_error(OptionParser::InvalidOption)
      end
    end
  end
end
