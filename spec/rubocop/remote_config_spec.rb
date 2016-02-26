# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::RemoteConfig do
  include FileHelper

  let(:remote_config_url) { 'http://example.com/rubocop.yml' }
  let(:base_dir) { '.' }
  let(:cached_file_name) { '.rubocop-http---example-com-rubocop-yml' }
  let(:cached_file_path) { File.expand_path(cached_file_name, base_dir) }

  subject(:remote_config) do
    described_class.new(remote_config_url, base_dir).file
  end

  before do
    stub_request(:get, /example.com/)
      .to_return(status: 200, body: "Style/Encoding:\n    Enabled: true")
  end

  after do
    File.unlink cached_file_path if File.exist? cached_file_path
  end

  describe '.file' do
    it 'downloads the file if the file does not exist' do
      expect(subject).to eq(cached_file_path)
      expect(File.exist?(cached_file_path)).to be_truthy
    end

    it 'does not download the file if cache lifetime has not been reached' do
      FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 20)

      expect(subject).to eq(cached_file_path)
      assert_not_requested :get, remote_config_url
    end

    it 'downloads the file if cache lifetime has been reached' do
      FileUtils.touch cached_file_path, mtime: Time.now - ((60 * 60) * 30)

      expect(subject).to eq(cached_file_path)
      assert_requested :get, remote_config_url
    end
  end
end
