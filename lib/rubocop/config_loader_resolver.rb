# encoding: utf-8
# frozen_string_literal: true

require 'yaml'
require 'pathname'

module RuboCop
  # A mixin to break up ConfigLoader
  module ConfigLoaderResolver
    def resolve_requires(path, hash)
      config_dir = File.dirname(path)
      Array(hash.delete('require')).each do |r|
        if r.start_with?('.')
          require(File.join(config_dir, r))
        else
          require(r)
        end
      end
    end

    def resolve_inheritance(path, hash)
      base_configs(path, hash['inherit_from']).reverse_each do |base_config|
        base_config.each do |k, v|
          hash[k] = hash.key?(k) ? merge(v, hash[k]) : v if v.is_a?(Hash)
        end
      end
    end

    def resolve_inheritance_from_gems(hash, gems)
      (gems || {}).each_pair do |gem_name, config_path|
        if gem_name == 'rubocop'
          raise ArgumentError,
                "can't inherit configuration from the rubocop gem"
        end

        hash['inherit_from'] = Array(hash['inherit_from'])
        Array(config_path).reverse.each do |path|
          # Put gem configuration first so local configuration overrides it.
          hash['inherit_from'].unshift gem_config_path(gem_name, path)
        end
      end
    end
  end
end
