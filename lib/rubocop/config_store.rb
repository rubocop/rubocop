# encoding: utf-8

module Rubocop
  module ConfigStore
    module_function

    def prepare
      # @options_config stores a config that is specified in the command line.
      # This takes precedence over configs located in any directories
      @options_config = nil

      # @path_cache maps directories to configuration paths. We search
      # for .rubocop.yml only if we haven't already found it for the
      # given directory.
      @path_cache = {}

      # @object_cache maps configuration file paths to
      # configuration objects so we only need to load them once.
      @object_cache = {}
    end

    def set_options_config(options_config)
      loaded_config = Config.load_file(options_config)
      @options_config = Config.merge_with_default(loaded_config,
                                                  options_config)
    end

    def for(file)
      return @options_config if @options_config

      dir = File.dirname(file)
      @path_cache[dir] ||= Config.configuration_file_for(dir)
      path = @path_cache[dir]
      @object_cache[path] ||= Config.configuration_from_file(path)
    end
  end
end
