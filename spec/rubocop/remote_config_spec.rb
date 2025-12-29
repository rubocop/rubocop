# frozen_string_literal: true

RSpec.describe RuboCop::RemoteConfig do
  include FileHelper

  subject(:remote_config) { described_class.new(remote_config_url, base_dir).file }

  let(:remote_config_url) { 'http://example.com/rubocop.yml' }
  let(:base_dir) { '.' }
  let(:cached_file_name) { 'rubocop-e32e465e27910f2bc7262515eebe6b63.yml' }
  let(:cached_file_path) { File.expand_path(cached_file_name, base_dir) }

  before do
    stub_request(:get, remote_config_url)
      .to_return(status: 200, body: "Style/Encoding:\n    Enabled: true")
  end

  after do
    FileUtils.rm_rf cached_file_path
  end

  describe '.file' do
    it 'downloads the file if the file does not exist' do
      expect(remote_config).to eq(cached_file_path)
      expect(File).to exist(cached_file_path)
    end

    it 'does not download the file if cache lifetime has not been reached' do
      FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 20)

      expect(remote_config).to eq(cached_file_path)
      assert_not_requested :get, remote_config_url
    end

    it 'downloads the file if cache lifetime has been reached' do
      FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 30)

      expect(remote_config).to eq(cached_file_path)
      assert_requested :get, remote_config_url
    end

    context 'when the remote URL is not a valid URI' do
      let(:remote_config_url) { 'http://example.com/rübocop.yml' }

      it 'raises a configuration error' do
        expect do
          remote_config
        end.to raise_error(RuboCop::ConfigNotFoundError, /is not a valid URI/)
      end
    end

    context 'when remote URL is configured with token auth' do
      let(:token) { 'personal_access_token' }
      let(:remote_config_url) { "http://#{token}@example.com/rubocop.yml" }
      let(:stripped_remote_config_url) { 'http://example.com/rubocop.yml' }
      let(:cached_file_name) { 'rubocop-ab4a54bcd0d0314614a65a4394745105.yml' }

      before do
        stub_request(:get, stripped_remote_config_url)
          .with(basic_auth: [token])
          .to_return(status: 200, body: "Style/Encoding:\n    Enabled: true")
      end

      it 'downloads the file if the file does not exist' do
        expect(remote_config).to eq(cached_file_path)
        expect(File).to exist(cached_file_path)
      end

      it 'does not download the file if cache lifetime has not been reached' do
        FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 20)

        expect(remote_config).to eq(cached_file_path)
        assert_not_requested :get, remote_config_url
      end

      it 'downloads the file if cache lifetime has been reached' do
        FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 30)

        expect(remote_config).to eq(cached_file_path)
        assert_requested :get, stripped_remote_config_url
      end

      context 'when the remote URL responds with 404' do
        before do
          stub_request(:get, stripped_remote_config_url).to_return(status: 404)
        end

        it 'raises error' do
          expect do
            remote_config
          end.to raise_error(Net::HTTPClientException,
                             '404 "" while downloading remote config file http://example.com/rubocop.yml')
        end
      end
    end

    context 'when remote URL is configured with basic auth' do
      let(:username) { 'username' }
      let(:password) { 'password' }
      let(:remote_config_url) { "http://#{username}:#{password}@example.com/rubocop.yml" }
      let(:stripped_remote_config_url) { 'http://example.com/rubocop.yml' }
      let(:cached_file_name) { 'rubocop-4a2057b5f7fe601a137248a7cfe411d1.yml' }

      before do
        stub_request(:get, stripped_remote_config_url)
          .with(basic_auth: [username, password])
          .to_return(status: 200, body: "Style/Encoding:\n    Enabled: true")
      end

      it 'downloads the file if the file does not exist' do
        expect(remote_config).to eq(cached_file_path)
        expect(File).to exist(cached_file_path)
      end

      it 'does not download the file if cache lifetime has not been reached' do
        FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 20)

        expect(remote_config).to eq(cached_file_path)
        assert_not_requested :get, remote_config_url
      end

      it 'downloads the file if cache lifetime has been reached' do
        FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 30)

        expect(remote_config).to eq(cached_file_path)
        assert_requested :get, stripped_remote_config_url
      end

      context 'when the remote URL responds with 404' do
        before do
          stub_request(:get, stripped_remote_config_url).to_return(status: 404)
        end

        it 'raises error' do
          expect do
            remote_config
          end.to raise_error(Net::HTTPClientException,
                             '404 "" while downloading remote config file http://example.com/rubocop.yml')
        end
      end

      context 'when the remote URL responds with 500' do
        before { stub_request(:get, stripped_remote_config_url).to_return(status: 500) }

        it 'raises error' do
          expect do
            remote_config
          end.to raise_error(Net::HTTPFatalError,
                             '500 "" while downloading remote config file http://example.com/rubocop.yml')
        end
      end
    end

    context 'when the remote URL responds with redirect' do
      let(:new_location) { 'http://cdn.example.com/rubocop.yml' }

      before do
        stub_request(:get, remote_config_url).to_return(headers: { 'Location' => new_location })

        stub_request(:get, new_location)
          .to_return(status: 200, body: "Style/Encoding:\n    Enabled: true")
      end

      it 'follows the redirect and downloads the file' do
        expect(remote_config).to eq(cached_file_path)
        expect(File).to exist(cached_file_path)
      end
    end

    context 'when the remote URL responds with not modified' do
      before { stub_request(:get, remote_config_url).to_return(status: 304) }

      it 'reuses the existing cached file' do
        FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 30)

        expect { remote_config }.not_to change(File.stat(cached_file_path), :mtime)
        assert_requested :get, remote_config_url
      end
    end

    context 'when the network is inaccessible' do
      before { stub_request(:get, remote_config_url).to_raise(SocketError) }

      it 'reuses the existing cached file' do
        expect(remote_config).to eq(cached_file_path)
      end
    end

    context 'when the remote URL responds with 500' do
      before { stub_request(:get, remote_config_url).to_return(status: 500) }

      it 'raises error' do
        expect do
          remote_config
        end.to raise_error(Net::HTTPFatalError,
                           '500 "" while downloading remote config file http://example.com/rubocop.yml')
      end
    end
  end

  describe '.inherit_from_remote' do
    context 'when the remote includes file starting with `./`' do
      let(:includes_file) { './base.yml' }

      it 'returns remote includes URI' do
        remote_config = described_class.new(remote_config_url, base_dir)
        includes_config = remote_config.inherit_from_remote(includes_file)

        expect(includes_config.uri).to eq URI.parse('http://example.com/base.yml')
      end
    end
  end

  describe '.cache_name_from_uri' do
    subject(:remote_config) { described_class.new(remote_config_url, base_dir) }

    let(:action) { remote_config.send(:cache_name_from_uri) }

    context 'without query parameters on the URL' do
      let(:remote_config_url) { 'http://example.com/rubocop.yml' }

      it 'returns a sanitized cache name' do
        expect(action).to eq('rubocop-e32e465e27910f2bc7262515eebe6b63.yml')
      end
    end

    context 'with query parameters on the URL' do
      let(:remote_config_url) { 'http://example.com/rubocop.yml?query=test' }

      it 'returns a sanitized cache name' do
        expect(action).to eq('rubocop-f1299382a3413262e0cad599fcb89efa.yml')
      end
    end

    context 'with basic auth on the URL' do
      let(:remote_config_url) { 'http://user:pass@example.com/rubocop.yml' }

      it 'returns a sanitized cache name' do
        expect(action).to eq('rubocop-89a9d79de790d798117fa34875199de3.yml')
      end
    end

    context 'with nested path on the URL' do
      let(:remote_config_url) { 'http://example.com/a/b/c/rubocop.yml' }

      it 'returns a sanitized cache name' do
        expect(action).to eq('rubocop-817dac820aa899cae8b77bfb00fe4d7f.yml')
      end
    end

    context 'with yaml file extension on the URL' do
      let(:remote_config_url) { 'http://example.com/rubocop.yaml' }

      it 'returns a sanitized cache name' do
        expect(action).to eq('rubocop-639250d27b76fc041f5a001712b47dff.yml')
      end
    end

    context 'with YAML file extension on the URL' do
      let(:remote_config_url) { 'http://example.com/rubocop.YAML' }

      it 'returns a sanitized cache name' do
        expect(action).to eq('rubocop-eba7c77758f4655c5b5f576d7596849a.yml')
      end
    end

    context 'with YML file extension on the URL' do
      let(:remote_config_url) { 'http://example.com/rubocop.YML' }

      it 'returns a sanitized cache name' do
        expect(action).to eq('rubocop-290a70e2e8136e0ac522ae9666202faf.yml')
      end
    end

    context 'with very long file name the URL' do
      let(:remote_config_url) { "http://example.com/rubocop-#{'a' * 500}.yml" }

      it 'returns a sanitized cache name' do
        expect(action).to eq("rubocop-#{'a' * 209}-4a4922719c4b0200afe9487254bd6a0c.yml")
      end

      it 'returns the truncated cache name' do
        expect(action.size).to be(254)
      end
    end
  end
end
