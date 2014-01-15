# encoding: utf-8

require 'spec_helper'

describe Rubocop::ConfigLoader do
  include FileHelper

  let(:default_config) { Rubocop::ConfigLoader.default_configuration }

  describe '.configuration_file_for', :isolated_environment do
    subject(:configuration_file_for) do
      described_class.configuration_file_for(dir_path)
    end

    context 'when no config file exists in ancestor directories' do
      let(:dir_path) { 'dir' }
      before { create_file('dir/example.rb', '') }

      context 'but a config file exists in home directory' do
        before { create_file('~/.rubocop.yml', '') }

        it 'returns the path to the file in home directory' do
          expect(configuration_file_for).to end_with('home/.rubocop.yml')
        end
      end

      context 'and no config file exists in home directory' do
        it 'falls back to the provided default file' do
          expect(configuration_file_for).to end_with('config/default.yml')
        end
      end
    end

    context 'when a config file exists in the parent directory' do
      let(:dir_path) { 'dir' }

      before do
        create_file('dir/example.rb', '')
        create_file('.rubocop.yml', '')
      end

      it 'returns the path to that configuration file' do
        expect(configuration_file_for).to end_with('work/.rubocop.yml')
      end
    end

    context 'when multiple config files exist in ancestor directories' do
      let(:dir_path) { 'dir' }

      before do
        create_file('dir/example.rb', '')
        create_file('dir/.rubocop.yml', '')
        create_file('.rubocop.yml', '')
      end

      it 'prefers closer config file' do
        expect(configuration_file_for).to end_with('dir/.rubocop.yml')
      end
    end
  end

  describe '.configuration_from_file', :isolated_environment do
    subject(:configuration_from_file) do
      described_class.configuration_from_file(file_path)
    end

    context 'with any config file' do
      let(:file_path) { '.rubocop.yml' }

      before do
        create_file(file_path, ['Encoding:',
                                '  Enabled: false'])
      end
      it 'returns a configuration inheriting from default.yml' do
        config = default_config['Encoding'].dup
        config['Enabled'] = false
        expect(configuration_from_file)
          .to eql(default_config.merge('Encoding' => config))
      end
    end

    context 'when multiple config files exist in ancestor directories' do
      let(:file_path) { 'dir/.rubocop.yml' }

      before do
        create_file('.rubocop.yml',
                    ['AllCops:',
                     '  Excludes:',
                     '    - vendor/**'
                    ])

        create_file(file_path,
                    ['AllCops:',
                     '  Excludes: []'
                    ])
      end

      it 'gets AllCops/Excludes from the highest directory level' do
        excludes = configuration_from_file['AllCops']['Excludes']
        expect(excludes).to eq([File.expand_path('vendor/**')])
      end
    end

    context 'when a file inherits from a parent file' do
      let(:file_path) { 'dir/.rubocop.yml' }

      before do
        create_file('.rubocop.yml',
                    ['AllCops:',
                     '  Excludes:',
                     '    - vendor/**',
                     '    - !ruby/regexp /[A-Z]/'
                    ])

        create_file(file_path, ['inherit_from: ../.rubocop.yml'])
      end

      it 'gets an absolute AllCops/Excludes' do
        excludes = configuration_from_file['AllCops']['Excludes']
        expect(excludes).to eq([File.expand_path('vendor/**'), /[A-Z]/])
      end
    end

    context 'when a file inherits from an empty parent file' do
      let(:file_path) { 'dir/.rubocop.yml' }

      before do
        create_file('.rubocop.yml', [''])

        create_file(file_path, ['inherit_from: ../.rubocop.yml'])
      end

      it 'does not fail to load' do
        expect { configuration_from_file }.not_to raise_error
      end
    end

    context 'when a file inherits from a sibling file' do
      let(:file_path) { 'dir/.rubocop.yml' }

      before do
        create_file('src/.rubocop.yml',
                    ['AllCops:',
                     '  Excludes:',
                     '    - vendor/**'
                    ])

        create_file(file_path, ['inherit_from: ../src/.rubocop.yml'])
      end

      it 'gets an absolute AllCops/Exclude' do
        excludes = configuration_from_file['AllCops']['Excludes']
        expect(excludes).to eq([File.expand_path('src/vendor/**')])
      end
    end

    context 'when a file inherits from a parent and grandparent file' do
      let(:file_path) { 'dir/subdir/.rubocop.yml' }

      before do
        create_file('dir/subdir/example.rb', '')

        create_file('.rubocop.yml',
                    ['LineLength:',
                     '  Enabled: false',
                     '  Max: 77'])

        create_file('dir/.rubocop.yml',
                    ['inherit_from: ../.rubocop.yml',
                     '',
                     'MethodLength:',
                     '  Enabled: true',
                     '  CountComments: false',
                     '  Max: 10'
                    ])

        create_file(file_path,
                    ['inherit_from: ../.rubocop.yml',
                     '',
                     'LineLength:',
                     '  Enabled: true',
                     '',
                     'MethodLength:',
                     '  Max: 5'
                    ])
      end

      it 'returns the ancestor configuration plus local overrides' do
        config = default_config
                   .merge('LineLength' => {
                          'Description' =>
                             default_config['LineLength']['Description'],
                          'Enabled' => true,
                          'Max' => 77
                          },
                          'MethodLength' => {
                            'Description' =>
                               default_config['MethodLength']['Description'],
                            'Enabled' => true,
                            'CountComments' => false,
                            'Max' => 5
                          })
        expect(configuration_from_file).to eq(config)
      end
    end

    context 'when a file inherits from two configurations' do
      let(:file_path) { '.rubocop.yml' }

      before do
        create_file('example.rb', '')

        create_file('normal.yml',
                    ['MethodLength:',
                     '  Enabled: false',
                     '  CountComments: true',
                     '  Max: 79'])

        create_file('special.yml',
                    ['MethodLength:',
                     '  Enabled: false',
                     '  Max: 200'])

        create_file(file_path,
                    ['inherit_from:',
                     '  - normal.yml',
                     '  - special.yml',
                     '',
                     'MethodLength:',
                     '  Enabled: true'
                    ])
      end

      it 'returns values from the last one when possible' do
        expected = { 'Enabled' => true,        # overridden in .rubocop.yml
                     'CountComments' => true,  # only defined in normal.yml
                     'Max' => 200 }            # special.yml takes precedence
        expect(configuration_from_file['MethodLength'].to_set)
          .to be_superset(expected.to_set)
      end
    end
  end

  describe '.load_file', :isolated_environment do
    subject(:load_file) do
      described_class.load_file(configuration_path)
    end

    let(:configuration_path) { '.rubocop.yml' }

    it 'returns a configuration loaded from the passed path' do
      create_file(configuration_path, [
        'Encoding:',
        '  Enabled: true'
      ])
      configuration = load_file
      expect(configuration['Encoding']).to eq(
        'Enabled' => true
      )
    end
  end

  describe '.merge' do
    subject(:merge) { described_class.merge(base, derived) }

    let(:base) do
      {
        'AllCops' => {
          'Includes' => ['**/*.gemspec', '**/Rakefile'],
          'Excludes' => []
        }
      }
    end
    let(:derived) do
      { 'AllCops' => { 'Excludes' => ['example.rb', 'exclude_*'] } }
    end

    it 'returns a recursive merge of its two arguments' do
      expect(merge).to eq('AllCops' => {
                            'Includes' => ['**/*.gemspec', '**/Rakefile'],
                            'Excludes' => ['example.rb', 'exclude_*']
                          })
    end
  end

  describe 'configuration for SymbolArray', :isolated_environment do
    let(:config) do
      config_path = described_class.configuration_file_for('.')
      described_class.configuration_from_file(config_path)
    end

    context 'when no config file exists for the target file' do
      it 'is disabled' do
        expect(config.cop_enabled?('SymbolArray')).to be_false
      end
    end

    context 'when a config file which does not mention SymbolArray exists' do
      it 'is disabled' do
        create_file('.rubocop.yml', [
          'LineLength:',
          '  Max: 79'
        ])
        expect(config.cop_enabled?('SymbolArray')).to be_false
      end
    end

    context 'when a config file which explicitly enables SymbolArray exists' do
      it 'is enabled' do
        create_file('.rubocop.yml', [
          'SymbolArray:',
          '  Enabled: true'
        ])
        expect(config.cop_enabled?('SymbolArray')).to be_true
      end
    end
  end

  describe 'configuration for AssignmentInCondition' do
    describe 'AllowSafeAssignment' do
      it 'is enabled by default' do
        default_config = described_class.default_configuration
        symbol_name_config = default_config.for_cop('AssignmentInCondition')
        expect(symbol_name_config['AllowSafeAssignment']).to be_true
      end
    end
  end
end
