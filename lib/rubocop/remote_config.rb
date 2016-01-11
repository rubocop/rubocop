# encoding: utf-8
# frozen_string_literal: true

require 'net/http'

module RuboCop
  # Common methods and behaviors for dealing with remote config files.
  class RemoteConfig
    CACHE_LIFETIME = 24 * 60 * 60

    def initialize(url)
      @uri = URI.parse(url)
    end

    def file
      return cache_path unless cache_path_expired?

      http = Net::HTTP.new(@uri.hostname, @uri.port)
      http.use_ssl = true if @uri.instance_of? URI::HTTPS

      request = Net::HTTP::Get.new(@uri.request_uri)
      if cache_path_exists?
        request['If-Modified-Since'] = File.stat(cache_path).mtime.rfc2822
      end
      response = http.request(request)

      cache_path.tap do |f|
        if response.is_a?(Net::HTTPSuccess)
          open f, 'w' do |io|
            io.write response.body
          end
        end
      end
    end

    private

    def cache_path
      ".rubocop-#{cache_name_from_uri}"
    end

    def cache_path_exists?
      @cache_path_exists ||= File.exist?(cache_path)
    end

    def cache_path_expired?
      return true unless cache_path_exists?

      @cache_path_expired ||= begin
        file_age = (Time.now - File.stat(cache_path).mtime).to_f
        (file_age / CACHE_LIFETIME) > 1
      end
    end

    def cache_name_from_uri
      uri = @uri.clone
      uri.query = nil
      uri.to_s.gsub!(/[^0-9A-Za-z]/, '-')
    end
  end
end
