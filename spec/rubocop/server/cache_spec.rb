# frozen_string_literal: true

RSpec.describe RuboCop::Server::Cache do
  subject(:cache_class) { described_class }

  include_context 'cli spec behavior'

  describe '.cache_path' do
    context 'when cache root path is not specified as default' do
      before do
        cache_class.cache_root_path = nil
      end

      it 'is the default path' do
        expect(cache_class.cache_path).to eq("#{Dir.home}/.cache/rubocop_cache/server")
      end
    end

    context 'when cache root path is specified path' do
      before do
        cache_class.cache_root_path = '/tmp'
      end

      it 'is the specified path' do
        if RuboCop::Platform.windows?
          expect(cache_class.cache_path).to eq('D:/tmp/rubocop_cache/server')
        else
          expect(cache_class.cache_path).to eq('/tmp/rubocop_cache/server')
        end
      end
    end

    context 'when `CacheRootDirectory` configure value is not set', :isolated_environment do
      after { cache_class.cache_path }

      it 'does not require `erb` and `yaml`' do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            DisabledByDefault: true
        YAML

        expect(described_class).not_to receive(:require).with('erb')
        expect(described_class).not_to receive(:require).with('yaml')
      end
    end

    context 'when `CacheRootDirectory` configure value is set', :isolated_environment do
      context 'when cache root path is not specified path' do
        let(:cache_path) { File.join('/tmp/cache-root-directory', 'rubocop_cache', 'server') }

        before do
          cache_class.cache_root_path = nil
        end

        it 'contains the root from `CacheRootDirectory` configure value' do
          create_file('.rubocop.yml', <<~YAML)
            AllCops:
              CacheRootDirectory: '/tmp/cache-root-directory'
          YAML

          expect(described_class).to receive(:require).with('erb')
          expect(described_class).to receive(:require).with('yaml')

          if RuboCop::Platform.windows?
            expect(cache_class.cache_path).to eq(cache_path.prepend('D:'))
          else
            expect(cache_class.cache_path).to eq(cache_path)
          end
        end
      end

      context 'when cache root path is not specified path and `XDG_CACHE_HOME` environment variable is specified' do
        let(:cache_path) { File.join('/tmp/cache-root-directory', 'rubocop_cache', 'server') }

        around do |example|
          cache_class.cache_root_path = nil

          ENV['XDG_CACHE_HOME'] = '/tmp/cache-from-xdg-env'
          begin
            example.run
          ensure
            ENV.delete('XDG_CACHE_HOME')
          end
        end

        it 'contains the root from `CacheRootDirectory` configure value' do
          create_file('.rubocop.yml', <<~YAML)
            AllCops:
              CacheRootDirectory: '/tmp/cache-root-directory'
          YAML

          if RuboCop::Platform.windows?
            expect(cache_class.cache_path).to eq(cache_path.prepend('D:'))
          else
            expect(cache_class.cache_path).to eq(cache_path)
          end
        end
      end

      context 'when cache root path is specified path' do
        before do
          cache_class.cache_root_path = '/tmp'
        end

        it 'contains the root from cache root path' do
          create_file('.rubocop.yml', <<~YAML)
            AllCops:
              CacheRootDirectory: '/tmp/cache-root-directory'
          YAML

          if RuboCop::Platform.windows?
            expect(cache_class.cache_path).to eq(File.join('D:/tmp', 'rubocop_cache', 'server'))
          else
            expect(cache_class.cache_path).to eq(File.join('/tmp', 'rubocop_cache', 'server'))
          end
        end
      end
    end

    context 'when `RUBOCOP_CACHE_ROOT` environment variable is set' do
      around do |example|
        ENV['RUBOCOP_CACHE_ROOT'] = '/tmp/rubocop-cache-root-env'
        begin
          example.run
        ensure
          ENV.delete('RUBOCOP_CACHE_ROOT')
        end
      end

      context 'when cache root path is not specified path' do
        let(:cache_path) { File.join('/tmp/rubocop-cache-root-env', 'rubocop_cache', 'server') }

        before do
          cache_class.cache_root_path = nil
        end

        it 'contains the root from `RUBOCOP_CACHE_ROOT`' do
          if RuboCop::Platform.windows?
            expect(cache_class.cache_path).to eq(cache_path.prepend('D:'))
          else
            expect(cache_class.cache_path).to eq(cache_path)
          end
        end
      end

      context 'when cache root path is not specified path and `XDG_CACHE_HOME` environment variable is specified' do
        let(:cache_path) { File.join('/tmp/rubocop-cache-root-env', 'rubocop_cache', 'server') }

        around do |example|
          cache_class.cache_root_path = nil

          ENV['XDG_CACHE_HOME'] = '/tmp/cache-from-xdg-env'
          begin
            example.run
          ensure
            ENV.delete('XDG_CACHE_HOME')
          end
        end

        it 'contains the root from `RUBOCOP_CACHE_ROOT`' do
          if RuboCop::Platform.windows?
            expect(cache_class.cache_path).to eq(cache_path.prepend('D:'))
          else
            expect(cache_class.cache_path).to eq(cache_path)
          end
        end
      end

      context 'when cache root path is specified path' do
        before do
          cache_class.cache_root_path = '/tmp'
        end

        it 'contains the root from cache root path' do
          if RuboCop::Platform.windows?
            expect(cache_class.cache_path).to eq(File.join('D:/tmp', 'rubocop_cache', 'server'))
          else
            expect(cache_class.cache_path).to eq(File.join('/tmp', 'rubocop_cache', 'server'))
          end
        end
      end
    end

    context 'when `XDG_CACHE_HOME` environment variable is set' do
      around do |example|
        ENV['XDG_CACHE_HOME'] = '/tmp/cache-from-xdg-env'
        begin
          example.run
        ensure
          ENV.delete('XDG_CACHE_HOME')
        end
      end

      context 'when cache root path is not specified path' do
        let(:puid) { Process.uid.to_s }
        let(:cache_path) { File.join('/tmp/cache-from-xdg-env', puid, 'rubocop_cache', 'server') }

        before do
          cache_class.cache_root_path = nil
        end

        it 'contains the root from `XDG_CACHE_HOME`' do
          if RuboCop::Platform.windows?
            expect(cache_class.cache_path).to eq(cache_path.prepend('D:'))
          else
            expect(cache_class.cache_path).to eq(cache_path)
          end
        end
      end

      context 'when cache root path is specified path' do
        before do
          cache_class.cache_root_path = '/tmp'
        end

        it 'contains the root from cache root path' do
          if RuboCop::Platform.windows?
            expect(cache_class.cache_path).to eq(File.join('D:/tmp', 'rubocop_cache', 'server'))
          else
            expect(cache_class.cache_path).to eq(File.join('/tmp', 'rubocop_cache', 'server'))
          end
        end
      end
    end

    context 'when .rubocop.yml is empty', :isolated_environment do
      context 'when cache root path is not specified path' do
        before do
          cache_class.cache_root_path = nil
        end

        it 'does not raise an error' do
          create_empty_file('.rubocop.yml')

          expect { cache_class.cache_path }.not_to raise_error
        end
      end
    end

    context 'when ERB pre-processing of the configuration file', :isolated_environment do
      context 'when cache root path is not specified path' do
        before do
          cache_class.cache_root_path = nil
        end

        it 'does not raise an error' do
          create_file('.rubocop.yml', <<~YAML)
            Style/Encoding:
              Enabled: <%= 1 == 1 %>
              Exclude:
              <% Dir['*.rb'].sort.each do |name| %>
                - <%= name %>
              <% end %>
          YAML

          expect { cache_class.cache_path }.not_to raise_error
        end
      end
    end

    context 'when using YAML alias in .rubocop.yml', :isolated_environment do
      it 'does not raise an error' do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            Style/StringLiterals: &config
              Enable: true
            Style/HashSyntax:
              <<: *config
        YAML

        expect { cache_class.cache_path }.not_to raise_error
      end
    end
  end

  unless RuboCop::Platform.windows?
    describe '.pid_running?', :isolated_environment do
      it 'works properly when concurrency with server stopping and cleaning cache dir' do
        expect(described_class).to receive(:pid_path).and_wrap_original do |method|
          result = method.call
          described_class.dir.rmtree # server stopping behavior
          result
        end
        expect(described_class.pid_running?).to be(false)
      end

      it 'works properly when insufficient permissions to server cache dir are granted' do
        expect(described_class).to receive(:pid_path).and_wrap_original do |method|
          result = method.call
          described_class.dir.chmod(0o644) # Make insufficient permissions.
          result
        end
        expect(described_class.pid_running?).to be(false)
      end
    end
  end
end
