# frozen_string_literal: true

RSpec.describe RuboCop::CacheConfig do
  include_context 'cli spec behavior'

  describe '.root_dir_from_toplevel_config' do
    context 'when no CacheRootDirectory is set', :isolated_environment do
      before do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            DisabledByDefault: true
        YAML
      end

      it 'returns the default cache directory in home' do
        expected = File.join(File.realpath(Dir.home), '.cache', 'rubocop_cache')
        expect(described_class.root_dir_from_toplevel_config).to eq(expected)
      end

      it 'does not require erb and yaml' do
        expect(described_class).not_to receive(:require).with('erb')
        expect(described_class).not_to receive(:require).with('yaml')
      end

      context 'when cache_root_override is given' do
        it 'uses the override' do
          expect(described_class.root_dir_from_toplevel_config('/tmp/override'))
            .to eq('/tmp/override/rubocop_cache')
        end
      end
    end

    context 'when CacheRootDirectory is set in the toplevel config file', :isolated_environment do
      it 'returns a configured directory with rubocop_cache suffix' do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            CacheRootDirectory: '/tmp/custom-cache'
        YAML

        expect(described_class.root_dir_from_toplevel_config)
          .to eq('/tmp/custom-cache/rubocop_cache')
      end

      context 'when cache_root_override is given' do
        it 'uses the override' do
          expect(described_class.root_dir_from_toplevel_config('/tmp/override'))
            .to eq('/tmp/override/rubocop_cache')
        end
      end
    end

    context 'when CacheRootDirectory is set in an inherited config file', :isolated_environment do
      it 'ignores the inherited setting and uses the default' do
        create_file('.rubocop.yml', <<~YAML)
          inherit_from: 'inherited.yml'
          AllCops:
            DisabledByDefault: true
        YAML

        create_file('inherited.yml', <<~YAML)
          AllCops:
            CacheRootDirectory: '/tmp/inherited-cache'
        YAML

        expected = File.join(File.realpath(Dir.home), '.cache', 'rubocop_cache')
        expect(described_class.root_dir_from_toplevel_config).to eq(expected)
      end

      context 'when CacheRootDirectory is also set in the toplevel config' do
        it 'uses the toplevel setting' do
          create_file('.rubocop.yml', <<~YAML)
            inherit_from: 'inherited.yml'
            AllCops:
              CacheRootDirectory: '/tmp/toplevel-cache'
          YAML

          create_file('inherited.yml', <<~YAML)
            AllCops:
              CacheRootDirectory: '/tmp/inherited-cache'
          YAML

          expect(described_class.root_dir_from_toplevel_config)
            .to eq('/tmp/toplevel-cache/rubocop_cache')
        end
      end
    end

    context 'when RUBOCOP_CACHE_ROOT environment variable is set' do
      around do |example|
        original = ENV.fetch('RUBOCOP_CACHE_ROOT', nil)
        ENV['RUBOCOP_CACHE_ROOT'] = '/tmp/env-cache-root'
        begin
          example.run
        ensure
          ENV['RUBOCOP_CACHE_ROOT'] = original
        end
      end

      context 'with no CacheRootDirectory in config', :isolated_environment do
        it 'takes precedence over default' do
          create_file('.rubocop.yml', <<~YAML)
            AllCops:
              DisabledByDefault: true
          YAML

          expect(described_class.root_dir_from_toplevel_config)
            .to eq('/tmp/env-cache-root/rubocop_cache')
        end
      end

      context 'with CacheRootDirectory in config', :isolated_environment do
        it 'takes precedence over configured directory' do
          create_file('.rubocop.yml', <<~YAML)
            AllCops:
              CacheRootDirectory: '/tmp/config-cache'
          YAML

          expect(described_class.root_dir_from_toplevel_config)
            .to eq('/tmp/env-cache-root/rubocop_cache')
        end
      end

      context 'when cache_root_override is given' do
        it 'takes precedence over the override' do
          expect(described_class.root_dir_from_toplevel_config('/tmp/override'))
            .to eq('/tmp/env-cache-root/rubocop_cache')
        end
      end
    end

    context 'when XDG_CACHE_HOME environment variable is set' do
      around do |example|
        original = ENV.fetch('XDG_CACHE_HOME', nil)
        ENV['XDG_CACHE_HOME'] = '/tmp/xdg-cache'
        begin
          example.run
        ensure
          ENV['XDG_CACHE_HOME'] = original
        end
      end

      context 'with no CacheRootDirectory in config', :isolated_environment do
        it 'uses XDG_CACHE_HOME with process UID' do
          create_file('.rubocop.yml', <<~YAML)
            AllCops:
              DisabledByDefault: true
          YAML

          puid = Process.uid.to_s
          expected = File.join('/tmp/xdg-cache', puid, 'rubocop_cache')
          expect(described_class.root_dir_from_toplevel_config).to eq(expected)
        end

        context 'when cache_root_override is given' do
          it 'uses the override' do
            expect(described_class.root_dir_from_toplevel_config('/tmp/override'))
              .to eq('/tmp/override/rubocop_cache')
          end
        end
      end

      context 'with CacheRootDirectory in config', :isolated_environment do
        it 'prefers CacheRootDirectory over XDG_CACHE_HOME' do
          create_file('.rubocop.yml', <<~YAML)
            AllCops:
              CacheRootDirectory: '/tmp/config-cache'
          YAML

          expect(described_class.root_dir_from_toplevel_config)
            .to eq('/tmp/config-cache/rubocop_cache')
        end

        context 'when cache_root_override is given' do
          it 'uses the override' do
            expect(described_class.root_dir_from_toplevel_config('/tmp/override'))
              .to eq('/tmp/override/rubocop_cache')
          end
        end
      end
    end

    context 'when .rubocop.yml contains ERB templates', :isolated_environment do
      it 'does not raise an error' do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            CacheRootDirectory: '/tmp/cache-<%= "test" %>'
          Style/Encoding:
            Enabled: <%= 1 == 1 %>
            Exclude:
            <% Dir['*.rb'].sort.each do |name| %>
              - <%= name %>
            <% end %>
        YAML

        expect { described_class.root_dir_from_toplevel_config }.not_to raise_error
        expect(described_class.root_dir_from_toplevel_config).to eq('/tmp/cache-test/rubocop_cache')
      end
    end

    context 'when .rubocop.yml is empty', :isolated_environment do
      it 'does not raise an error' do
        create_empty_file('.rubocop.yml')

        expect { described_class.root_dir_from_toplevel_config }.not_to raise_error
      end
    end

    context 'when .rubocop.yml contains YAML aliases', :isolated_environment do
      it 'does not raise an error' do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            CacheRootDirectory: '/tmp/yaml-alias-cache'
            Style/StringLiterals: &config
              Enable: true
            Style/HashSyntax:
              <<: *config
        YAML

        expect { described_class.root_dir_from_toplevel_config }.not_to raise_error
        expect(described_class.root_dir_from_toplevel_config)
          .to eq('/tmp/yaml-alias-cache/rubocop_cache')
      end
    end
  end
end
