# frozen_string_literal: true

RSpec.describe RuboCop::Config do
  include FileHelper

  subject(:configuration) { described_class.new(hash, loaded_path) }

  let(:hash) { {} }
  let(:loaded_path) { 'example/.rubocop.yml' }

  describe '.new' do
    context 'without arguments' do
      subject(:configuration) { described_class.new }

      it { expect(configuration['Lint/BooleanSymbol']['SafeAutoCorrect']).to be(false) }
    end
  end

  describe '#validate', :isolated_environment do
    subject(:configuration) do
      # ConfigLoader.load_file will validate config
      RuboCop::ConfigLoader.load_file(configuration_path)
    end

    let(:configuration_path) { '.rubocop.yml' }

    context 'when the configuration includes any unrecognized cop name' do
      include_context 'mock console output'

      before do
        create_file(configuration_path, <<~YAML)
          LyneLenth:
            Enabled: true
            Max: 100
        YAML
      end

      it 'raises an validation error' do
        expect { configuration }.to raise_error(
          RuboCop::ValidationError,
          'unrecognized cop or department LyneLenth found in .rubocop.yml'
        )
      end
    end

    context 'when the configuration includes any unrecognized cop name and given `--ignore-unrecognized-cops` option' do
      context 'there is unrecognized cop' do
        include_context 'mock console output'

        before do
          create_file(configuration_path, <<~YAML)
            LyneLenth:
              Enabled: true
              Max: 100
          YAML
          RuboCop::ConfigLoader.ignore_unrecognized_cops = true
        end

        after do
          RuboCop::ConfigLoader.ignore_unrecognized_cops = nil
        end

        it 'prints a warning about the cop' do
          configuration
          expect($stderr.string)
            .to eq("The following cops or departments are not recognized and will be ignored:\n" \
                   "unrecognized cop or department LyneLenth found in .rubocop.yml\n")
        end
      end

      context 'there are no unrecognized cops' do
        include_context 'mock console output'

        before do
          create_file(configuration_path, <<~YAML)
            Layout/LineLength:
              Enabled: true
          YAML
          RuboCop::ConfigLoader.ignore_unrecognized_cops = true
        end

        after do
          RuboCop::ConfigLoader.ignore_unrecognized_cops = nil
        end

        it 'does not print any warnings' do
          configuration
          expect($stderr.string).to eq('')
        end
      end
    end

    context 'when the configuration includes an empty section' do
      before { create_file(configuration_path, ['Layout/LineLength:']) }

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError,
                          %r{^empty section Layout/LineLength})
      end
    end

    context 'when the empty section is AllCops' do
      before { create_file(configuration_path, ['AllCops:']) }

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError, /^empty section AllCops/)
      end
    end

    context 'when the configuration is in the base RuboCop config folder' do
      before do
        create_file(configuration_path, <<~YAML)
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
      include_context 'mock console output'

      before do
        create_file(configuration_path, <<~YAML)
          Layout/LineLength:
            Enabled: true
            Min: 10
        YAML
      end

      it 'prints a warning message' do
        configuration # ConfigLoader.load_file will validate config
        expect($stderr.string).to match(%r{Layout/LineLength does not support Min parameter.})
      end
    end

    context 'when the configuration includes any common parameter' do
      # Common parameters are parameters that are not in the default
      # configuration, but are nonetheless allowed for any cop.
      before do
        create_file(configuration_path, <<~YAML)
          Metrics/ModuleLength:
            Exclude:
              - lib/file.rb
            Include:
              - lib/file.xyz
            Severity: warning
            inherit_mode:
              merge:
                - Exclude
            StyleGuide: https://example.com/some-style.html
        YAML
      end

      it 'does not raise validation error' do
        expect { configuration.validate }.not_to raise_error
      end
    end

    context 'when the configuration includes a valid EnforcedStyle' do
      before do
        create_file(configuration_path, <<~YAML)
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
        create_file(configuration_path, <<~YAML)
          Style/AndOr:
            EnforcedStyle: itisinvalid
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }.to raise_error(RuboCop::ValidationError, /itisinvalid/)
      end
    end

    context 'when the configuration includes a valid enforced style' do
      before do
        create_file(configuration_path, <<~YAML)
          Layout/SpaceAroundBlockParameters:
            EnforcedStyleInsidePipes: space
        YAML
      end

      it 'does not raise validation error' do
        expect { configuration.validate }.not_to raise_error
      end
    end

    context 'when the configuration includes an invalid enforced style' do
      before do
        create_file(configuration_path, <<~YAML)
          Layout/SpaceAroundBlockParameters:
            EnforcedStyleInsidePipes: itisinvalid
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }.to raise_error(RuboCop::ValidationError, /itisinvalid/)
      end
    end

    context 'when the configuration includes multiple valid enforced styles' do
      before do
        create_file(configuration_path, <<~YAML)
          Layout/HashAlignment:
            EnforcedHashRocketStyle:
              - key
              - table
        YAML
      end

      it 'does not raise validation error' do
        expect { configuration.validate }.not_to raise_error
      end
    end

    context 'when the configuration includes multiple valid enforced styles ' \
            'and one invalid style' do
      before do
        create_file(configuration_path, <<~YAML)
          Layout/HashAlignment:
            EnforcedHashRocketStyle:
              - key
              - trailing_comma
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }.to raise_error(RuboCop::ValidationError, /trailing_comma/)
      end
    end

    context 'when the configuration includes multiple but config does not allow' do
      before do
        create_file(configuration_path, <<~YAML)
          Layout/SpaceAroundBlockParameters:
            EnforcedStyleInsidePipes:
              - space
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }.to raise_error(RuboCop::ValidationError, /space/)
      end
    end

    context 'when the configuration includes multiple invalid enforced styles' do
      before do
        create_file(configuration_path, <<~YAML)
          Layout/HashAlignment:
            EnforcedHashRocketStyle:
              - table
              - itisinvalid
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }.to raise_error(RuboCop::ValidationError, /itisinvalid/)
      end
    end

    context 'when the configuration includes an obsolete cop' do
      before do
        create_file(configuration_path, <<~YAML)
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
        create_file(configuration_path, <<~YAML)
          Rails/UniqBeforePluck:
            EnforcedMode: conservative
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }.to raise_error(RuboCop::ValidationError, /EnforcedStyle/)
      end
    end

    context 'when the configuration includes an obsolete EnforcedStyle parameter' do
      before do
        create_file(configuration_path, <<~YAML)
          Layout/IndentationConsistency:
            EnforcedStyle: rails
        YAML
      end

      it 'raises validation error' do
        expect { configuration.validate }
          .to raise_error(RuboCop::ValidationError,
                          /EnforcedStyle: rails` has been renamed/)
      end
    end

    shared_examples 'obsolete MaxLineLength parameter' do |cop_name|
      context "when the configuration includes the obsolete #{cop_name}: " \
              'MaxLineLength parameter' do
        before do
          create_file(configuration_path, <<~YAML)
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

    include_examples 'obsolete MaxLineLength parameter', 'Style/WhileUntilModifier'
    include_examples 'obsolete MaxLineLength parameter', 'Style/IfUnlessModifier'

    context 'when the configuration includes obsolete parameters and cops' do
      before do
        create_file(configuration_path, <<~YAML)
          Rails/UniqBeforePluck:
            EnforcedMode: conservative
          Style/MethodCallParentheses:
            Enabled: false
          Layout/BlockAlignment:
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
        expect { configuration.validate }.to raise_error(RuboCop::ValidationError, message_matcher)
      end
    end

    context 'when all cops are both Enabled and Disabled by default' do
      before do
        create_file(configuration_path, <<~YAML)
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
          create_file(configuration_path, <<~YAML)
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
          create_file(configuration_path, <<~YAML)
            Lint/Syntax:
              Enabled: false
          YAML
        end

        it 'raises validation error' do
          expect { configuration.validate }
            .to raise_error(
              RuboCop::ValidationError,
              %r{configuration for Lint/Syntax cop found}
            )
        end
      end
    end

    describe 'conflicting Safe settings' do
      context 'when the configuration includes an unsafe cop that is ' \
              'explicitly declared to have a safe autocorrection' do
        before do
          create_file(configuration_path, <<~YAML)
            Style/PreferredHashMethods:
              Safe: false
              SafeAutoCorrect: true
          YAML
        end

        it 'raises validation error' do
          expect { configuration.validate }
            .to raise_error(
              RuboCop::ValidationError,
              /Unsafe cops cannot have a safe autocorrection/
            )
        end
      end

      context 'when the configuration includes an unsafe cop without ' \
              'a declaration of its autocorrection' do
        before do
          create_file(configuration_path, <<~YAML)
            Style/PreferredHashMethods:
              Safe: false
          YAML
        end

        it 'does not raise validation error' do
          expect { configuration.validate }.not_to raise_error
        end
      end
    end
  end

  describe '#make_excludes_absolute' do
    context 'when config is in root directory' do
      let(:hash) { { 'AllCops' => { 'Exclude' => ['config/environment', 'spec'] } } }

      before do
        allow(configuration)
          .to receive(:base_dir_for_path_parameters)
          .and_return('/home/foo/project')
        configuration.make_excludes_absolute
      end

      it 'generates valid absolute directory' do
        excludes = configuration['AllCops']['Exclude'].map { |e| e.sub(/^[A-Z]:/i, '') }
        expect(excludes).to eq ['/home/foo/project/config/environment', '/home/foo/project/spec']
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
        excludes = configuration['AllCops']['Exclude'].map { |e| e.sub(/^[A-Z]:/i, '') }
        expect(excludes).to eq ['/home/foo/project/config/environment', '/home/foo/project/spec']
      end
    end
  end

  describe '#file_to_include?' do
    let(:hash) { { 'AllCops' => { 'Include' => ['**/Gemfile', 'config/unicorn.rb.example'] } } }

    let(:loaded_path) { '/home/foo/project/.rubocop.yml' }

    context 'when the passed path matches any of patterns to include' do
      it 'returns true' do
        file_path = '/home/foo/project/Gemfile'
        expect(configuration).to be_file_to_include(file_path)
      end
    end

    context 'when the passed path does not match any of patterns to include' do
      it 'returns false' do
        file_path = '/home/foo/project/Gemfile.lock'
        expect(configuration).not_to be_file_to_include(file_path)
      end
    end
  end

  describe '#file_to_exclude?' do
    include_context 'mock console output'

    let(:hash) { { 'AllCops' => { 'Exclude' => ["#{Dir.pwd}/log/**/*", '**/bar.rb'] } } }

    let(:loaded_path) { '/home/foo/project/.rubocop.yml' }

    context 'when the passed path matches any of patterns to exclude' do
      it 'returns true' do
        file_path = "#{Dir.pwd}/log/foo.rb"
        expect(configuration).to be_file_to_exclude(file_path)

        expect(configuration).to be_file_to_exclude('log/foo.rb')

        expect(configuration).to be_file_to_exclude('bar.rb')
      end
    end

    context 'when the passed path does not match any of patterns to exclude' do
      it 'returns false' do
        file_path = "#{Dir.pwd}/log_file.rb"
        expect(configuration).not_to be_file_to_exclude(file_path)

        expect(configuration).not_to be_file_to_exclude('app/controller.rb')

        expect(configuration).not_to be_file_to_exclude('baz.rb')
      end
    end
  end

  describe '#allowed_camel_case_file?' do
    subject { configuration.allowed_camel_case_file?(file_path) }

    let(:hash) { { 'AllCops' => { 'Include' => ['**/Gemfile'] } } }

    context 'when the passed path matches allowed camel case patterns to include' do
      let(:file_path) { '/home/foo/project/Gemfile' }

      it { is_expected.to be true }
    end

    context 'when the passed path does not match allowed camel case patterns to include' do
      let(:file_path) { '/home/foo/project/testCase' }

      it { is_expected.to be false }
    end

    context 'when the passed path is a gemspec' do
      let(:file_path) { '/home/foo/project/my-project.gemspec' }

      it { is_expected.to be true }
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
        expect(patterns_to_include).to eq(['**/Gemfile', 'config/unicorn.rb.example'])
      end
    end
  end

  describe '#possibly_include_hidden?' do
    subject(:configuration) { described_class.new(hash, loaded_path) }

    let(:loaded_path) { 'example/.rubocop.yml' }

    it 'returns true when Include config only includes regular paths' do
      configuration['AllCops'] = { 'Include' => ['**/Gemfile', 'config/unicorn.rb.example'] }

      expect(configuration).not_to be_possibly_include_hidden
    end

    it 'returns true when Include config includes a regex' do
      configuration['AllCops'] = { 'Include' => [/foo/] }

      expect(configuration).to be_possibly_include_hidden
    end

    it 'returns true when Include config includes a toplevel dotfile' do
      configuration['AllCops'] = { 'Include' => ['.foo'] }

      expect(configuration).to be_possibly_include_hidden
    end

    it 'returns true when Include config includes a dotfile in a path' do
      configuration['AllCops'] = { 'Include' => ['foo/.bar'] }

      expect(configuration).to be_possibly_include_hidden
    end
  end

  describe '#patterns_to_exclude' do
    subject(:patterns_to_exclude) do
      configuration = described_class.new(hash, loaded_path)
      configuration.patterns_to_exclude
    end

    let(:loaded_path) { 'example/.rubocop.yml' }

    context 'when config file has AllCops => Exclude key' do
      let(:hash) { { 'AllCops' => { 'Exclude' => ['log/*'] } } }

      it 'returns the Exclude value' do
        expect(patterns_to_exclude).to eq(['log/*'])
      end
    end
  end

  describe '#check' do
    subject(:configuration) { described_class.new(hash, loaded_path) }

    let(:loaded_path) { 'example/.rubocop.yml' }

    context 'when a deprecated configuration is detected' do
      include_context 'mock console output'

      let(:hash) { { 'AllCops' => { 'Includes' => [] } } }

      it 'prints a warning message for the loaded path' do
        configuration.check
        expect($stderr.string).to include("#{loaded_path} - AllCops/Includes was renamed")
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
          expect { |b| configuration.deprecation_check(&b) }.not_to yield_control
        end
      end

      context 'if there are is an Includes key' do
        let(:hash) { { 'AllCops' => { 'Includes' => [] } } }

        it 'yields' do
          expect { |b| configuration.deprecation_check(&b) }.to yield_with_args(String)
        end
      end

      context 'if there are is an Excludes key' do
        let(:hash) { { 'AllCops' => { 'Excludes' => [] } } }

        it 'yields' do
          expect { |b| configuration.deprecation_check(&b) }.to yield_with_args(String)
        end
      end
    end
  end

  describe '#for_badge' do
    let(:hash) do
      {
        'Style' => { 'Foo' => 42, 'Bar' => 666 },
        'Layout/TrailingWhitespace' => { 'Bar' => 43 },
        'Style/Alias' => { 'Bar' => 44 }
      }
    end

    it 'takes into account the department' do
      expect(configuration.for_badge(RuboCop::Cop::Style::Alias.badge)).to eq(
        { 'Enabled' => true,
          'Foo' => 42,
          'Bar' => 44 }
      )
    end

    it 'works if department has no config' do
      expect(configuration.for_badge(RuboCop::Cop::Layout::TrailingWhitespace.badge)).to eq(
        { 'Enabled' => true,
          'Bar' => 43 }
      )
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

        it 'the cop setting overrides the department' do
          cop_class = RuboCop::Cop::Layout::TrailingWhitespace
          expect(cop_enabled(cop_class)).to be true
        end
      end
    end

    context 'when an nested cop department is disabled' do
      context 'but an individual cop is enabled' do
        let(:hash) do
          {
            'Foo/Bar' => { 'Enabled' => false },
            'Foo/Bar/BazCop' => { 'Enabled' => true }
          }
        end

        it 'the cop setting overrides the department' do
          cop_class = 'Foo/Bar/BazCop'
          expect(cop_enabled(cop_class)).to be true
        end
      end

      context 'and an individual cop is not specified' do
        let(:hash) { { 'Foo/Bar' => { 'Enabled' => false } } }

        it 'the cop setting overrides the department' do
          cop_class = 'Foo/Bar/BazCop'
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
      let(:hash) { { 'Layout/TrailingWhitespace' => { 'Exclude' => ['foo'] } } }

      it 'enables the cop by default' do
        cop_class = RuboCop::Cop::Layout::TrailingWhitespace
        expect(cop_enabled(cop_class)).to be true
      end
    end

    context 'when configuration has no mention of a cop' do
      let(:hash) { {} }

      it 'enables the cop that is not mentioned' do
        expect(cop_enabled('VeryCustomDepartment/CustomCop')).to be true
      end

      context 'when all cops are disabled by default' do
        let(:hash) { { 'AllCops' => { 'DisabledByDefault' => true } } }

        it 'disables the cop that is not mentioned' do
          expect(cop_enabled('VeryCustomDepartment/CustomCop')).to be false
        end
      end

      context 'when all cops are explicitly enabled by default' do
        let(:hash) { { 'AllCops' => { 'EnabledByDefault' => true } } }

        it 'enables the cop that is not mentioned' do
          expect(cop_enabled('VeryCustomDepartment/CustomCop')).to be true
        end
      end
    end
  end

  describe '#gem_versions_in_target', :isolated_environment do
    ['Gemfile.lock', 'gems.locked'].each do |file_name|
      let(:base_path) { configuration.base_dir_for_path_parameters }
      let(:lockfile_path) { File.join(base_path, file_name) }

      context "and #{file_name} exists" do
        it 'returns the locked gem versions' do
          content =
            <<~LOCKFILE
              GEM
                remote: https://rubygems.org/
                specs:
                  a (1.1.1)
                  b (2.2.2)
                  c (3.3.3)
                  d (4.4.4)
                    a (= 1.1.1)
                    b (>= 1.1.1, < 3.3.3)
                    c (~> 3.3)

              PLATFORMS
                ruby

              DEPENDENCIES
                rails (= 4.1.0)

              BUNDLED WITH
                2.4.19
            LOCKFILE

          expected = {
            'a' => Gem::Version.new('1.1.1'),
            'b' => Gem::Version.new('2.2.2'),
            'c' => Gem::Version.new('3.3.3'),
            'd' => Gem::Version.new('4.4.4')
          }

          create_file(lockfile_path, content)
          expect(configuration.gem_versions_in_target).to eq expected
        end
      end
    end

    context 'and neither Gemfile.lock nor gems.locked exist' do
      it 'returns nil' do
        expect(configuration.gem_versions_in_target).to be_nil
      end
    end
  end

  describe '#target_rails_version', :isolated_environment do
    let(:base_path) { configuration.base_dir_for_path_parameters }
    let(:lockfile_path) { File.join(base_path, 'Gemfile.lock') }

    context 'when bundler is loaded' do
      context 'when a lockfile with railties exists' do
        it 'returns the correct target rails version' do
          content = <<~LOCKFILE
            GEM
              remote: https://rubygems.org/
              specs:
                rails (7.1.3.2)
                  railties (= 7.1.3.2)
                railties (7.1.3.2)

            DEPENDENCIES
              rails (= 7.1.3.2)
          LOCKFILE

          create_file(lockfile_path, content)
          expect(configuration.target_rails_version).to eq 7.1
        end
      end

      context 'when a lockfile with railties from a prerelease exists' do
        it 'returns the correct target rails version' do
          content = <<~LOCKFILE
            GEM
              remote: https://rubygems.org/
              specs:
                rails (8.0.0.alpha)
                  railties (= 8.0.0.alpha)
                railties (8.0.0.alpha)

            DEPENDENCIES
              rails (= 8.0.0.alpha)
          LOCKFILE

          create_file(lockfile_path, content)
          expect(configuration.target_rails_version).to eq 8.0
        end
      end
    end

    context 'when bundler is not loaded' do
      before { hide_const('Bundler') }

      it 'falls back to the default rails version' do
        content = <<~LOCKFILE
          GEM
            remote: https://rubygems.org/
            specs:
              rails (7.1.3.2)
                railties (= 7.1.3.2)
              railties (7.1.3.2)

          DEPENDENCIES
            rails (= 7.1.3.2)
        LOCKFILE

        create_file(lockfile_path, content)
        expect(configuration.target_rails_version).to eq RuboCop::Config::DEFAULT_RAILS_VERSION
      end
    end
  end

  describe '#for_department', :restore_registry do
    let(:hash) do
      {
        'Foo' => { 'Bar' => 42, 'Baz' => true },
        'Foo/Foo' => { 'Bar' => 42, 'Qux' => true }
      }
    end

    before { stub_cop_class('RuboCop::Foo::Foo') }

    it "always returns the department's config" do
      expect(configuration.for_department('Foo')).to eq hash['Foo']
    end

    it 'accepts a Symbol' do
      expect(configuration.for_department(:Foo)).to eq hash['Foo']
    end
  end
end
