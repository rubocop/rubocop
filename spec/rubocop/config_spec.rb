# frozen_string_literal: true

RSpec.describe RuboCop::Config do
  include FileHelper

  subject(:configuration) { described_class.new(hash, loaded_path) }

  let(:hash) { {} }
  let(:loaded_path) { 'example/.rubocop.yml' }

  describe '#validate', :isolated_environment do
    subject(:configuration) do
      RuboCop::ConfigLoader.load_file(configuration_path)
    end

    let(:configuration_path) { '.rubocop.yml' }

    context 'when the configuration includes any unrecognized cop name' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          LyneLenth:
            Enabled: true
            Max: 100
        YAML
        $stderr = StringIO.new
      end

      after do
        $stderr = STDERR
      end

      it 'prints a warning message' do
        configuration # ConfigLoader.load_file will validate config
        expect($stderr.string).to match(/unrecognized cop LyneLenth/)
      end
    end

    context 'when the configuration includes an empty section' do
      before do
        create_file(configuration_path, ['Metrics/LineLength:'])
      end

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError,
                          %r{^empty section Metrics/LineLength})
      end
    end

    context 'when the empty section is AllCops' do
      before do
        create_file(configuration_path, ['AllCops:'])
      end

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError, /^empty section AllCops/)
      end
    end

    context 'when the configuration is in the base RuboCop config folder' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          InvalidProperty:
            Enabled: true
        YAML
        stub_const('RuboCop::ConfigLoader::RUBOCOP_HOME', rubocop_home_path)
      end

      let(:rubocop_home_path) { File.realpath('.') }
      let(:configuration_path) { 'config/.rubocop.yml' }

      it 'is not validated' do
        expect { configuration.validate }.not_to raise_error
      end
    end

    context 'when the configuration includes any unrecognized parameter' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Metrics/LineLength:
            Enabled: true
            Min: 10
        YAML
        $stderr = StringIO.new
      end

      after do
        $stderr = STDERR
      end

      it 'prints a warning message' do
        configuration # ConfigLoader.load_file will validate config
        expect($stderr.string).to match(
          %r{unrecognized parameter Metrics/LineLength:Min}
        )
      end
    end

    context 'when the configuration includes any common parameter' do
      # Common parameters are parameters that are not in the default
      # configuration, but are nonetheless allowed for any cop.
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Metrics/ModuleLength:
            Exclude:
              - lib/file.rb
            Include:
              - lib/file.xyz
            Severity: warning
            StyleGuide: https://example.com/some-style.html
        YAML
      end

      it 'does not raise validation error' do
        expect { configuration.validate }.not_to raise_error
      end
    end

    context 'when the configuration includes a valid EnforcedStyle' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Style/AndOr:
            EnforcedStyle: conditionals
        YAML
      end

      it 'does not raise validation error' do
        expect { configuration.validate }.not_to raise_error
      end
    end

    context 'when the configuration includes an invalid EnforcedStyle' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Style/AndOr:
            EnforcedStyle: itisinvalid
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError, /itisinvalid/)
      end
    end

    context 'when the configuration includes a valid EnforcedStyle' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Layout/SpaceAroundBlockParameters:
            EnforcedStyleInsidePipes: space
        YAML
      end

      it 'does not raise validation error' do
        expect { configuration.validate }.not_to raise_error
      end
    end

    context 'when the configuration includes an invalid EnforcedStyle' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Layout/SpaceAroundBlockParameters:
            EnforcedStyleInsidePipes: itisinvalid
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError, /itisinvalid/)
      end
    end

    context 'when the configuration includes an obsolete cop' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Style/MethodCallParentheses:
            Enabled: true
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError,
                          %r{Style/MethodCallWithoutArgsParentheses})
      end
    end

    context 'when the configuration includes an obsolete parameter' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Rails/UniqBeforePluck:
            EnforcedMode: conservative
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError, /EnforcedStyle/)
      end
    end

    shared_examples 'obsolete MaxLineLength parameter' do |cop_name|
      context "when the configuration includes the obsolete #{cop_name}: " \
              'MaxLineLength parameter' do
        before do
          create_file(configuration_path, <<-YAML.strip_indent)
            #{cop_name}:
              MaxLineLength: 100
          YAML
        end

        it 'raises validation error' do
          expect { configuration.validate }
            .to raise_error(RuboCop::ValidationError,
                            /`#{cop_name}: MaxLineLength` has been removed./)
        end
      end
    end

    include_examples 'obsolete MaxLineLength parameter',
                     'Style/WhileUntilModifier'
    include_examples 'obsolete MaxLineLength parameter',
                     'Style/IfUnlessModifier'

    context 'when the configuration includes obsolete parameters and cops' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          Rails/UniqBeforePluck:
            EnforcedMode: conservative
          Style/MethodCallParentheses:
            Enabled: false
          Lint/BlockAlignment:
            AlignWith: either
          Layout/SpaceBeforeModifierKeyword:
            Enabled: false
        YAML
      end

      it 'raises validation error' do
        message_matcher = lambda do |message|
          message.include?('EnforcedStyle') &&
            message.include?('MethodCallWithoutArgsParentheses') &&
            message.include?('EnforcedStyleAlignWith') &&
            message.include?('Layout/SpaceAroundKeyword')
        end
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError, message_matcher)
      end
    end

    context 'when all cops are both Enabled and Disabled by default' do
      before do
        create_file(configuration_path, <<-YAML.strip_indent)
          AllCops:
            EnabledByDefault: true
            DisabledByDefault: true
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(
            RuboCop::ValidationError,
            /Cops cannot be both enabled by default and disabled by default/
          )
      end
    end

    context 'when the configuration includes Lint/Syntax cop' do
      before do
        # Force reloading default configuration
        RuboCop::ConfigLoader.default_configuration = nil
      end

      context 'when the configuration matches the default' do
        before do
          create_file(configuration_path, <<-YAML.strip_indent)
            Lint/Syntax:
              Enabled: true
          YAML
        end

        it 'does not raise validation error' do
          expect { configuration.validate }.not_to raise_error
        end
      end

      context 'when the configuration does not match the default' do
        before do
          create_file(configuration_path, <<-YAML.strip_indent)
            Lint/Syntax:
              Enabled: false
          YAML
        end

        it 'raises validation error' do
          expect { configuration.validate }
            .to raise_error(
              RuboCop::ValidationError,
              /configuration for Syntax cop found/
            )
        end
      end
    end
  end

  describe '#make_excludes_absolute' do
    context 'when config is in root directory' do
      let(:hash) do
        {
          'AllCops' => {
            'Exclude' => [
              'config/environment',
              'spec'
            ]
          }
        }
      end

      before do
        allow(configuration)
          .to receive(:base_dir_for_path_parameters)
          .and_return('/home/foo/project')
        configuration.make_excludes_absolute
      end

      it 'generates valid absolute directory' do
        excludes = configuration['AllCops']['Exclude']
                   .map { |e| e.sub(/^[A-Z]:/, '') }
        expect(excludes)
          .to eq [
            '/home/foo/project/config/environment',
            '/home/foo/project/spec'
          ]
      end
    end

    context 'when config is in subdirectory' do
      let(:hash) do
        {
          'AllCops' => {
            'Exclude' => [
              '../../config/environment',
              '../../spec'
            ]
          }
        }
      end

      before do
        allow(configuration)
          .to receive(:base_dir_for_path_parameters)
          .and_return('/home/foo/project/config/tools')
        configuration.make_excludes_absolute
      end

      it 'generates valid absolute directory' do
        excludes = configuration['AllCops']['Exclude']
                   .map { |e| e.sub(/^[A-Z]:/, '') }
        expect(excludes)
          .to eq [
            '/home/foo/project/config/environment',
            '/home/foo/project/spec'
          ]
      end
    end
  end

  describe '#file_to_include?' do
    let(:hash) do
      {
        'AllCops' => {
          'Include' => ['**/Gemfile', 'config/unicorn.rb.example']
        }
      }
    end

    let(:loaded_path) { '/home/foo/project/.rubocop.yml' }

    context 'when the passed path matches any of patterns to include' do
      it 'returns true' do
        file_path = '/home/foo/project/Gemfile'
        expect(configuration.file_to_include?(file_path)).to be_truthy
      end
    end

    context 'when the passed path does not match any of patterns to include' do
      it 'returns false' do
        file_path = '/home/foo/project/Gemfile.lock'
        expect(configuration.file_to_include?(file_path)).to be_falsey
      end
    end
  end

  describe '#file_to_exclude?' do
    before { $stderr = StringIO.new }
    after { $stderr = STDERR }

    let(:hash) do
      {
        'AllCops' => {
          'Exclude' => [
            "#{Dir.pwd}/log/**/*",
            '**/bar.rb'
          ]
        }
      }
    end

    let(:loaded_path) { '/home/foo/project/.rubocop.yml' }

    context 'when the passed path matches any of patterns to exclude' do
      it 'returns true' do
        file_path = "#{Dir.pwd}/log/foo.rb"
        expect(configuration.file_to_exclude?(file_path)).to be_truthy

        expect(configuration.file_to_exclude?('log/foo.rb')).to be_truthy

        expect(configuration.file_to_exclude?('bar.rb')).to be_truthy
      end
    end

    context 'when the passed path does not match any of patterns to exclude' do
      it 'returns false' do
        file_path = "#{Dir.pwd}/log_file.rb"
        expect(configuration.file_to_exclude?(file_path)).to be_falsey

        expect(configuration.file_to_exclude?('app/controller.rb')).to be_falsey

        expect(configuration.file_to_exclude?('baz.rb')).to be_falsey
      end
    end
  end

  describe '#patterns_to_include' do
    subject(:patterns_to_include) do
      configuration = described_class.new(hash, loaded_path)
      configuration.patterns_to_include
    end

    let(:loaded_path) { 'example/.rubocop.yml' }

    context 'when config file has AllCops => Include key' do
      let(:hash) do
        {
          'AllCops' => {
            'Include' => ['**/Gemfile', 'config/unicorn.rb.example']
          }
        }
      end

      it 'returns the Include value' do
        expect(patterns_to_include).to eq([
                                            '**/Gemfile',
                                            'config/unicorn.rb.example'
                                          ])
      end
    end
  end

  describe '#possibly_include_hidden?' do
    subject(:configuration) do
      described_class.new(hash, loaded_path)
    end

    let(:loaded_path) { 'example/.rubocop.yml' }

    it 'returns true when Include config only includes regular paths' do
      configuration['AllCops'] = {
        'Include' => ['**/Gemfile', 'config/unicorn.rb.example']
      }

      expect(configuration.possibly_include_hidden?).to be(false)
    end

    it 'returns true when Include config includes a regex' do
      configuration['AllCops'] = { 'Include' => [/foo/] }

      expect(configuration.possibly_include_hidden?).to be(true)
    end

    it 'returns true when Include config includes a toplevel dotfile' do
      configuration['AllCops'] = { 'Include' => ['.foo'] }

      expect(configuration.possibly_include_hidden?).to be(true)
    end

    it 'returns true when Include config includes a dotfile in a path' do
      configuration['AllCops'] = { 'Include' => ['foo/.bar'] }

      expect(configuration.possibly_include_hidden?).to be(true)
    end
  end

  describe '#patterns_to_exclude' do
    subject(:patterns_to_exclude) do
      configuration = described_class.new(hash, loaded_path)
      configuration.patterns_to_exclude
    end

    let(:loaded_path) { 'example/.rubocop.yml' }

    context 'when config file has AllCops => Exclude key' do
      let(:hash) do
        {
          'AllCops' => {
            'Exclude' => ['log/*']
          }
        }
      end

      it 'returns the Exclude value' do
        expect(patterns_to_exclude).to eq(['log/*'])
      end
    end
  end

  describe '#check' do
    subject(:configuration) do
      described_class.new(hash, loaded_path)
    end

    let(:loaded_path) { 'example/.rubocop.yml' }

    context 'when a deprecated configuration is detected' do
      let(:hash) { { 'AllCops' => { 'Includes' => [] } } }

      before { $stderr = StringIO.new }
      after { $stderr = STDERR }

      it 'prints a warning message for the loaded path' do
        configuration.check
        expect($stderr.string).to include(
          "#{loaded_path} - AllCops/Includes was renamed"
        )
      end
    end
  end

  describe '#deprecation_check' do
    context 'when there is no AllCops configuration' do
      let(:hash) { {} }

      it 'does not yield' do
        expect { |b| configuration.deprecation_check(&b) }.not_to yield_control
      end
    end

    context 'when there is AllCops configuration' do
      context 'if there are no Excludes or Includes keys' do
        let(:hash) { { 'AllCops' => { 'Exclude' => [], 'Include' => [] } } }

        it 'does not yield' do
          expect do |b|
            configuration.deprecation_check(&b)
          end.not_to yield_control
        end
      end

      context 'if there are is an Includes key' do
        let(:hash) { { 'AllCops' => { 'Includes' => [] } } }

        it 'yields' do
          expect do |b|
            configuration.deprecation_check(&b)
          end.to yield_with_args(String)
        end
      end

      context 'if there are is an Excludes key' do
        let(:hash) { { 'AllCops' => { 'Excludes' => [] } } }

        it 'yields' do
          expect do |b|
            configuration.deprecation_check(&b)
          end.to yield_with_args(String)
        end
      end
    end
  end

  context 'whether the cop is enabled' do
    def cop_enabled(cop_class)
      configuration.for_cop(cop_class).fetch('Enabled')
    end

    context 'when an entire cop department is disabled' do
      context 'but an individual cop is enabled' do
        let(:hash) do
          {
            'Layout' => { 'Enabled' => false },
            'Layout/TrailingWhitespace' => { 'Enabled' => true }
          }
        end

        it 'still disables the cop' do
          cop_class = RuboCop::Cop::Layout::TrailingWhitespace
          expect(cop_enabled(cop_class)).to be false
        end
      end
    end

    context 'when an entire cop department is enabled' do
      context 'but an individual cop is disabled' do
        let(:hash) do
          {
            'Style' => { 'Enabled' => true },
            'Layout/TrailingWhitespace' => { 'Enabled' => false }
          }
        end

        it 'still disables the cop' do
          cop_class = RuboCop::Cop::Layout::TrailingWhitespace
          expect(cop_enabled(cop_class)).to be false
        end
      end
    end

    context 'when a cop has configuration but no explicit Enabled setting' do
      let(:hash) do
        {
          'Layout/TrailingWhitespace' => { 'Exclude' => ['foo'] }
        }
      end

      it 'enables the cop by default' do
        cop_class = RuboCop::Cop::Layout::TrailingWhitespace
        expect(cop_enabled(cop_class)).to be true
      end
    end
  end

  describe '#target_rails_version' do
    context 'when TargetRailsVersion is set' do
      let(:rails_version) { 4.0 }

      let(:hash) do
        {
          'AllCops' => {
            'TargetRailsVersion' => rails_version
          }
        }
      end

      it 'uses TargetRailsVersion' do
        expect(configuration.target_rails_version).to eq rails_version
      end
    end

    context 'when TargetRailsVersion is not set' do
      let(:hash) do
        {
          'AllCops' => {}
        }
      end

      it 'uses the default rails version' do
        default_version = RuboCop::Config::DEFAULT_RAILS_VERSION
        expect(configuration.target_rails_version).to eq default_version
      end
    end
  end

  describe '#target_ruby_version', :isolated_environment do
    context 'when TargetRubyVersion is set' do
      let(:ruby_version) { 2.1 }

      let(:hash) do
        {
          'AllCops' => {
            'TargetRubyVersion' => ruby_version
          }
        }
      end

      before do
        allow(File).to receive(:file?).and_call_original
      end

      it 'uses TargetRubyVersion' do
        expect(configuration.target_ruby_version).to eq ruby_version
      end

      it 'does not read .ruby-version' do
        configuration.target_ruby_version
        expect(File).not_to have_received(:file?).with('.ruby-version')
      end
    end

    context 'when TargetRubyVersion is not set' do
      context 'when .ruby-version is present' do
        before do
          dir = configuration.base_dir_for_path_parameters
          create_file(File.join(dir, '.ruby-version'), ruby_version)
        end

        context 'when .ruby-version contains an MRI version' do
          let(:ruby_version) { '2.2.4' }
          let(:ruby_version_to_f) { 2.2 }

          it 'reads it to determine the target ruby version' do
            expect(configuration.target_ruby_version).to eq ruby_version_to_f
          end
        end

        context 'when the MRI version contains multiple digits' do
          let(:ruby_version) { '10.11.0' }
          let(:ruby_version_to_f) { 10.11 }

          it 'reads it to determine the target ruby version' do
            expect(configuration.target_ruby_version).to eq ruby_version_to_f
          end
        end

        context 'when .ruby-version contains a version prefixed by "ruby-"' do
          let(:ruby_version) { 'ruby-2.3.0' }
          let(:ruby_version_to_f) { 2.3 }

          it 'correctly determines the target ruby version' do
            expect(configuration.target_ruby_version).to eq ruby_version_to_f
          end
        end

        context 'when .ruby-version contains a JRuby version' do
          let(:ruby_version) { 'jruby-9.1.2.0' }

          it 'uses the default target ruby version' do
            expect(configuration.target_ruby_version)
              .to eq described_class::DEFAULT_RUBY_VERSION
          end
        end

        context 'when .ruby-version contains a Rbx version' do
          let(:ruby_version) { 'rbx-3.42' }

          it 'uses the default target ruby version' do
            expect(configuration.target_ruby_version)
              .to eq described_class::DEFAULT_RUBY_VERSION
          end
        end

        context 'when .ruby-version contains "system" version' do
          let(:ruby_version) { 'system' }

          it 'uses the default target ruby version' do
            expect(configuration.target_ruby_version)
              .to eq described_class::DEFAULT_RUBY_VERSION
          end
        end
      end

      context 'when .ruby-version is not present' do
        it 'uses the default target ruby version' do
          expect(configuration.target_ruby_version)
            .to eq described_class::DEFAULT_RUBY_VERSION
        end
      end

      context 'when .ruby-version is in a parent directory' do
        before do
          dir = configuration.base_dir_for_path_parameters
          create_file(File.join(dir, '..', '.ruby-version'), '2.4.1')
        end

        it 'reads it to determine the target ruby version' do
          expect(configuration.target_ruby_version).to eq 2.4
        end
      end
    end
  end
end
