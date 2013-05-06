# encoding: utf-8

require 'yaml'

module Rubocop
  class Configuration
    RUBOCOP_HOME_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__),
                                                   '../..',
                                                   '.rubocop.yml'))

    # Returns the configuration hash from .rubocop.yml searching
    # upwards in the directory structure starting at the given
    # directory where the inspected file is. If no .rubocop.yml is
    # found there, the user's home directory is checked.
    def self.configuration_for_path(target_file_dir)
      return unless target_file_dir
      dir = target_file_dir
      while dir != '/'
        path = File.join(dir, '.rubocop.yml')
        if File.exist?(path)
          config = load_file(path)
          config['ConfigDirectory'] = dir
          return config
        end
        dir = File.expand_path('..', dir)
      end
      path = File.join(Dir.home, '.rubocop.yml')
      if File.exists?(path)
        config = load_file(path)
        config['ConfigDirectory'] = Dir.home
        return config
      end
      nil
    end

    def self.load_file(path)
      config = YAML.load_file(path)
      valid_cop_names, invalid_cop_names = config.keys.partition do |key|
        RUBOCOP_HOME_CONFIG.keys.include?(key)
      end
      invalid_cop_names.each do |name|
        puts "Warning: unrecognized cop #{name} found in #{path}".color(:red)
      end
      valid_cop_names.each do |name|
        config[name].keys.each do |param|
          unless RUBOCOP_HOME_CONFIG[name].keys.include?(param)
            puts(("Warning: unrecognized parameter #{name}:#{param} found " +
                  "in #{path}").color(:red))
          end
        end
      end
      config
    end
  end
end
