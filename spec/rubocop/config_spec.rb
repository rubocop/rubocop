# encoding: utf-8

require 'spec_helper'

describe Rubocop::Config do
  include FileHelper

  subject(:configuration) { Rubocop::Config.new(hash, loaded_path) }
  let(:hash) { {} }
  let(:loaded_path) { 'example/.rubocop.yml' }

  before { Rubocop::ConfigStore.prepare }

  describe '.configuration_for_path', :isolated_environment do
    subject(:configuration_for_path) do
      Rubocop::Config.configuration_for_path(file_path)
    end

    context 'when the passed path is nil' do
      let(:file_path) { nil }
      it 'returns nil' do
        expect(configuration_for_path).to be_nil
      end
    end

    context 'when no config file exists in ancestor directories' do
      let(:file_path) { 'dir/example.rb' }
      before { create_file(file_path, '') }

      context 'but a config file exists in home directory' do
        before do
          create_file('~/.rubocop.yml', [
            'Encoding:',
            '  Enabled: true',
          ])
        end

        it 'returns a configuration loaded from the file in home directory' do
          configuration = configuration_for_path
          expect(configuration['Encoding']).to eq({
            'Enabled' => true
          })
        end
      end

      context 'and no config file exists in home directory' do
        it 'returns nil' do
          expect(configuration_for_path).to be_nil
        end
      end
    end

    context 'when a config file exists in ancestor directories' do
      let(:file_path) { 'dir/example.rb' }

      before do
        create_file(file_path, '')

        create_file('.rubocop.yml', [
          'Encoding:',
          '  Enabled: true',
        ])
      end

      it 'returns a configuration loaded from the file' do
        configuration = configuration_for_path
        expect(configuration['Encoding']).to eq({
          'Enabled' => true
        })
      end
    end

    context 'when multiple config files exist in ancestor directories' do
      let(:file_path) { 'dir/example.rb' }

      before do
        create_file(file_path, '')

        create_file('.rubocop.yml', [
          'Encoding:',
          '  Enabled: true',
        ])

        create_file('dir/.rubocop.yml', [
          'Encoding:',
          '  Enabled: false',
        ])
      end

      it 'prefers closer config file' do
        configuration = configuration_for_path
        expect(configuration['Encoding']).to eq({
          'Enabled' => false
        })
      end
    end
  end

  describe '.load_file', :isolated_environment do
    subject(:load_file) do
      Rubocop::Config.load_file(configuration_path)
    end

    let(:configuration_path) { '.rubocop.yml' }

    it 'returns a configuration loaded from the passed path' do
      create_file(configuration_path, [
        'Encoding:',
        '  Enabled: true',
      ])
      configuration = load_file
      expect(configuration['Encoding']).to eq({
        'Enabled' => true
      })
    end
  end

  describe '#validate!', :isolated_environment do
    # TODO: Because Config.load_file now outputs the validation warning,
    #       it is inserting text into the rspec test output here.
    #       The next 2 lines should be removed eventually.
    before(:each) { $stdout = StringIO.new }
    after(:each) { $stdout = STDOUT }

    subject(:configuration) do
      Rubocop::Config.load_file(configuration_path)
    end

    let(:configuration_path) { '.rubocop.yml' }

    context 'when the configuration includes any unrecognized cop name' do
      before do
        create_file(configuration_path, [
          'LyneLenth:',
          '  Enabled: true',
          '  Max: 100',
        ])
      end

      it 'raises validation error' do
        expect do
          configuration.validate!
        end.to raise_error(Rubocop::Config::ValidationError) do |error|
          expect(error.message).to start_with('unrecognized cop LyneLenth')
        end
      end
    end

    context 'when the configuration includes any unrecognized parameter' do
      before do
        create_file(configuration_path, [
          'LineLength:',
          '  Enabled: true',
          '  Min: 10',
        ])
      end

      it 'raises validation error' do
        expect do
          configuration.validate!
        end.to raise_error(Rubocop::Config::ValidationError) do |error|
          expect(error.message).to
            start_with('unrecognized parameter LineLength:Min')
        end
      end
    end
  end

  describe '#file_to_include?' do
    let(:hash) do
      {
        'AllCops' => {
          'Includes' => ['Gemfile', 'config/unicorn.rb.example']
        }
      }
    end

    let(:loaded_path) { '/home/foo/project/.rubocop.yml' }

    context 'when the passed path matches any of patterns to include' do
      it 'returns true' do
        file_path = '/home/foo/project/Gemfile'
        expect(configuration.file_to_include?(file_path)).to be_true
      end
    end

    context 'when the passed path does not match any of patterns to include' do
      it 'returns false' do
        file_path = '/home/foo/project/Gemfile.lock'
        expect(configuration.file_to_include?(file_path)).to be_false
      end
    end
  end

  describe '#file_to_exclude?' do
    let(:hash) do
      {
        'AllCops' => {
          'Excludes' => ['log/*']
        }
      }
    end

    let(:loaded_path) { '/home/foo/project/.rubocop.yml' }

    context 'when the passed path matches any of patterns to exclude' do
      it 'returns true' do
        file_path = '/home/foo/project/log/foo.rb'
        expect(configuration.file_to_exclude?(file_path)).to be_true
      end
    end

    context 'when the passed path does not match any of patterns to exclude' do
      it 'returns false' do
        file_path = '/home/foo/project/log_file.rb'
        expect(configuration.file_to_exclude?(file_path)).to be_false
      end
    end
  end

  describe '#patterns_to_include' do
    subject(:patterns_to_include) do
      configuration = Rubocop::Config.new(hash, loaded_path)
      configuration.patterns_to_include
    end

    let(:hash) { {} }
    let(:loaded_path) { 'example/.rubocop.yml' }

    context 'when config file has AllCops => Includes key' do
      let(:hash) do
        {
          'AllCops' => {
            'Includes' => ['Gemfile', 'config/unicorn.rb.example']
          }
        }
      end

      it 'returns the Includes value' do
        expect(patterns_to_include).to eq([
          'Gemfile',
          'config/unicorn.rb.example'
        ])
      end
    end

    context 'when config file does not have AllCops => Includes key' do
      it 'returns "**/*.gemspec" and "**/Rakefile"' do
        expect(patterns_to_include).to eq(['**/*.gemspec', '**/Rakefile'])
      end
    end
  end

  describe '#patterns_to_exclude' do
    subject(:patterns_to_exclude) do
      configuration = Rubocop::Config.new(hash, loaded_path)
      configuration.patterns_to_exclude
    end

    let(:hash) { {} }
    let(:loaded_path) { 'example/.rubocop.yml' }

    context 'when config file has AllCops => Excludes key' do
      let(:hash) do
        {
          'AllCops' => {
            'Excludes' => ['log/*']
          }
        }
      end

      it 'returns the Excludes value' do
        expect(patterns_to_exclude).to eq(['log/*'])
      end
    end

    context 'when config file does not have AllCops => Excludes key' do
      it 'returns an empty array' do
        expect(patterns_to_exclude).to be_empty
      end
    end
  end

  describe 'configuration for SymbolArray', :isolated_environment do
    before do
      create_file('example.rb', '# encoding: utf-8')
    end

    context 'when no config file exists for the target file' do
      it 'is disabled' do
        configuration = Rubocop::ConfigStore.for('example.rb')
        expect(configuration.cop_enabled?('SymbolArray')).to be_false
      end
    end

    context 'when a config file which does not mention SymbolArray exists' do
      it 'is disabled' do
        create_file('.rubocop.yml', [
          'LineLength:',
          '  Max: 79'
        ])
        configuration = Rubocop::ConfigStore.for('example.rb')
        expect(configuration.cop_enabled?('SymbolArray')).to be_false
      end
    end

    context 'when a config file which explicitly enables SymbolArray exists' do
      it 'is enabled' do
        create_file('.rubocop.yml', [
          'SymbolArray:',
          '  Enabled: true'
        ])
        configuration = Rubocop::ConfigStore.for('example.rb')
        expect(configuration.cop_enabled?('SymbolArray')).to be_true
      end
    end
  end
end
