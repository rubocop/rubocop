# frozen_string_literal: true

RSpec.describe RuboCop::Server::Cache do
  subject(:cache_class) { described_class }

  include_context 'cli spec behavior'

  describe '.cache_path' do
    context 'when cache root path is not specified as default' do
      before do
        cache_class.cache_root_path = nil
        allow(RuboCop::CacheConfig)
          .to receive(:root_dir_from_toplevel_config)
          .and_return('/tmp/toplevel-cache/rubocop_cache')
      end

      it 'is under the configured path' do
        expected = '/tmp/toplevel-cache/rubocop_cache/server'
        expected = "D:#{expected}" if RuboCop::Platform.windows?
        expect(cache_class.cache_path).to eq(expected)
      end
    end

    context 'when cache root path is specified path' do
      before do
        cache_class.cache_root_path = '/tmp'
      end

      it 'is under the specified path' do
        expected = '/tmp/rubocop_cache/server'
        expected = "D:#{expected}" if RuboCop::Platform.windows?
        expect(cache_class.cache_path).to eq(expected)
      end
    end
  end

  unless RuboCop::Platform.windows?
    describe '.restart_key', :isolated_environment do
      subject(:restart_key) do
        described_class.restart_key(args_config_file_path: args_config_file_path)
      end

      let(:args_config_file_path) { nil }
      let(:hexdigest) do
        Digest::SHA1.hexdigest(contents)
      end

      context 'when a local path is used in `inherit_from` of .rubocop.yml' do
        let(:contents) do
          RuboCop::Version::STRING + File.read('.rubocop.yml') + File.read('.rubocop_todo.yml')
        end

        before do
          create_file('.rubocop_todo.yml', <<~YAML)
            Metrics/ClassLength:
              Max: 192
          YAML
        end

        context 'when `inherit_from` is specified as a string path' do
          before do
            create_file('.rubocop.yml', <<~YAML)
              inherit_from: .rubocop_todo.yml
            YAML
          end

          it { expect(restart_key).to eq(hexdigest) }
        end

        context 'when `inherit_from` is specified as an array path' do
          before do
            create_file('.rubocop.yml', <<~YAML)
              inherit_from:
                - .rubocop_todo.yml
            YAML
          end

          it { expect(restart_key).to eq(hexdigest) }
        end
      end

      context 'when a remote path is used in `inherit_from` of .rubocop.yml' do
        let(:contents) do
          RuboCop::Version::STRING + File.read('.rubocop.yml')
        end

        context 'when `inherit_from` is specified as a string path' do
          before do
            create_file('.rubocop.yml', <<~YAML)
              inherit_from: https://example.com
            YAML
          end

          it { expect(restart_key).to eq(hexdigest) }
        end
      end

      context 'when a local path is used in `require` of .rubocop.yml' do
        let(:contents) do
          RuboCop::Version::STRING + File.read('.rubocop.yml') + File.read('local_file.rb')
        end

        before do
          create_file('local_file.rb', <<~RUBY)
            do_something
          RUBY
        end

        context 'when `inherit_from` is specified as a string path' do
          before do
            create_file('.rubocop.yml', <<~YAML)
              require: ./local_file
            YAML
          end

          it { expect(restart_key).to eq(hexdigest) }
        end

        context 'when `inherit_from` is specified as an array path' do
          before do
            create_file('.rubocop.yml', <<~YAML)
              require:
                ./local_file
            YAML
          end

          it { expect(restart_key).to eq(hexdigest) }
        end
      end

      context 'when a load path may be used in `require` of .rubocop.yml' do
        let(:contents) do
          RuboCop::Version::STRING + File.read('.rubocop.yml')
        end

        context 'when `inherit_from` is specified as a string path' do
          before do
            create_file('.rubocop.yml', <<~YAML)
              inherit_from: rubocop-performance
            YAML
          end

          it { expect(restart_key).to eq(hexdigest) }
        end
      end

      context 'when ERB pre-processing of the configuration file', :isolated_environment do
        context 'when `CacheRootDirectory` configure value is set' do
          it 'does not raise an error' do
            create_file('.rubocop.yml', <<~YAML)
              AllCops:
                CacheRootDirectory: '/tmp/cache-root-directory'
              Style/Encoding:
                Enabled: <%= 1 == 1 %>
                Exclude:
                <% Dir['*.rb'].sort.each do |name| %>
                  - <%= name %>
                <% end %>
            YAML

            expect { restart_key }.not_to raise_error
          end
        end
      end

      context 'when args_config_file_path is specified' do
        let(:args_config_file_path) { '.rubocop_todo.yml' }
        let(:contents) do
          RuboCop::Version::STRING + File.read('.rubocop_todo.yml')
        end

        before do
          create_file('.rubocop_todo.yml', <<~YAML)
            Metrics/ClassLength:
              Max: 192
          YAML
        end

        it { expect(restart_key).to eq(hexdigest) }
      end
    end

    describe '.pid_running?', :isolated_environment do
      it 'works properly when concurrency with server stopping and cleaning cache dir' do
        expect(described_class).to receive(:pid_path).and_wrap_original do |method|
          result = method.call
          described_class.dir.rmtree # server stopping behavior
          result
        end
        expect(described_class).not_to be_pid_running
      end

      it 'works properly when insufficient permissions to server cache dir are granted' do
        expect(described_class).to receive(:pid_path).and_wrap_original do |method|
          result = method.call
          described_class.dir.chmod(0o644) # Make insufficient permissions.
          result
        end
        expect(described_class).not_to be_pid_running
      end

      it 'works properly when the file system is read-only' do
        expect(described_class).to receive(:pid_path).and_wrap_original do |method|
          result = method.call
          allow(result).to receive(:read).and_raise(Errno::EROFS)
          result
        end
        expect(described_class).not_to be_pid_running
      end
    end
  end
end
