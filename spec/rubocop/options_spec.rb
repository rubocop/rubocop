# encoding: utf-8

require 'spec_helper'

describe Rubocop::Options, :isolated_environment do
  include FileHelper

  subject(:options) { described_class.new(config_store) }
  let(:config_store) { Rubocop::ConfigStore.new }

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

    describe '--version' do
      it 'exits cleanly' do
        expect { options.parse ['-v'] }.to exit_with_code(0)
        expect { options.parse ['--version'] }.to exit_with_code(0)
        expect($stdout.string).to eq((Rubocop::Version::STRING + "\n") * 2)
      end
    end

    describe '--only' do
      it 'exits with error if an incorrect cop name is passed' do
        expect { options.parse(%w(--only 123)) }
          .to raise_error(ArgumentError, /Unrecognized cop name: 123./)
      end
    end

    describe '--show-cops' do
      let(:cops) { Rubocop::Cop::Cop.all }

      let(:global_conf) do
        config_path =
          Rubocop::ConfigLoader.configuration_file_for(Dir.pwd.to_s)
        Rubocop::ConfigLoader.configuration_from_file(config_path)
      end

      let(:stdout) { $stdout.string }

      before do
        expect { options.parse ['--show-cops'] }.to exit_with_code(0)
      end

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
          expect(stdout).to include short_description_of_cop(cop)
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

      it 'prints the current configuration' do
        out = stdout.lines.to_a
        cops.each do |cop|
          conf = global_conf[cop.cop_name].dup
          confstrt =
            out.find_index { |i| i.include?("- #{cop.cop_name}") } + 1
          c = out[confstrt, conf.keys.size].to_s
          conf.delete('Description')
          expect(c).to include(short_description_of_cop(cop))
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
