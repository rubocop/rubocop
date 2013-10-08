# encoding: utf-8

require 'spec_helper'

describe Rubocop::Config do
  include FileHelper

  subject(:configuration) { described_class.new(hash, loaded_path) }
  let(:hash) { {} }
  let(:loaded_path) { 'example/.rubocop.yml' }

  describe '#validate', :isolated_environment do
    # TODO: Because Config.load_file now outputs the validation warning,
    #       it is inserting text into the rspec test output here.
    #       The next 2 lines should be removed eventually.
    before(:each) { $stdout = StringIO.new }
    after(:each) { $stdout = STDOUT }

    subject(:configuration) do
      Rubocop::ConfigLoader.load_file(configuration_path)
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
        e = described_class::ValidationError
        expect { configuration.validate }.to raise_error(e) do |error|
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
        e = described_class::ValidationError
        expect { configuration.validate }.to raise_error(e) do |error|
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
          'Excludes' => ['/home/foo/project/log/*']
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
      configuration = described_class.new(hash, loaded_path)
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
  end

  describe '#patterns_to_exclude' do
    subject(:patterns_to_exclude) do
      configuration = described_class.new(hash, loaded_path)
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
  end
end
