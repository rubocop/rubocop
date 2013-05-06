# encoding: utf-8

require 'spec_helper'

describe Rubocop::Configuration, :isolated_environment do
  include FileHelper

  describe '.configuration_for_path' do
    subject(:configuration_for_path) do
      Rubocop::Configuration.configuration_for_path(file_path)
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
            ''
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
          ''
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
          ''
        ])

        create_file('dir/.rubocop.yml', [
          'Encoding:',
          '  Enabled: false',
          ''
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

  describe '.load_file' do
    subject(:load_file) do
      Rubocop::Configuration.load_file(configuration_path)
    end

    let(:configuration_path) { '.rubocop.yml' }

    it 'returns a configuration loaded from the passed path' do
      create_file(configuration_path, [
        'Encoding:',
        '  Enabled: true',
        ''
      ])
      configuration = load_file
      expect(configuration['Encoding']).to eq({
        'Enabled' => true
      })
    end
  end
end
