# encoding: utf-8

module Rubocop
  module ConfigStore
    module_function

    def prepare
      # @options_config stores a config that is specified in the command line.
      # This takes precedence over configs located in any directories
      @options_config = nil

      # @config_cache is a cache that maps directories to
      # configurations. We search for .rubocop.yml only if we haven't
      # already found it for the given directory.
      @config_cache = {}
    end

    def set_options_config(options_config)
      loaded_config = Config.load_file(options_config)
      @options_config = Config.merge_with_default(loaded_config,
                                                  options_config)
    end

    def for(file)
      return @options_config if @options_config

      dir = File.dirname(file)
      return @config_cache[dir] if @config_cache[dir]

      config = Config.configuration_for_path(dir)
      @config_cache[dir] = config if config

      config or Config.new
    end
  end
end
