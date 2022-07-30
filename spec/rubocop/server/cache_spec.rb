# frozen_string_literal: true

RSpec.describe RuboCop::Server::Cache do
  subject(:cache_class) { described_class }

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
  end
end
