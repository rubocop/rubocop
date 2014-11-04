# encoding: utf-8

require 'set'

module RuboCop
  # This class finds target files to inspect by scanning the directory tree
  # and picking ruby files.
  class TargetFinder
    def initialize(config_store, options = {})
      @config_store = config_store
      @options = options
    end

    def force_exclusion?
      @options[:force_exclusion]
    end

    def debug?
      @options[:debug]
    end

    def fail_fast?
      @options[:fail_fast]
    end

    # Generate a list of target files by expanding globbing patterns
    # (if any). If args is empty, recursively find all Ruby source
    # files under the current directory
    # @return [Array] array of file paths
    def find(args)
      return target_files_in_dir if args.empty?

      files = []

      args.uniq.each do |arg|
        files += if File.directory?(arg)
                   target_files_in_dir(arg.chomp(File::SEPARATOR))
                 else
                   process_explicit_path(arg)
                 end
      end

      files.map { |f| File.expand_path(f) }.uniq
    end

    # Finds all Ruby source files under the current or other supplied
    # directory. A Ruby source file is defined as a file with the `.rb`
    # extension or a file with no extension that has a ruby shebang line
    # as its first line.
    # It is possible to specify includes and excludes using the config file,
    # so you can include other Ruby files like Rakefiles and gemspecs.
    # @param base_dir Root directory under which to search for
    #   ruby source files
    # @return [Array] Array of filenames
    def target_files_in_dir(base_dir = Dir.pwd)
      # Support Windows: Backslashes from command-line -> forward slashes
      if File::ALT_SEPARATOR
        base_dir.gsub!(File::ALT_SEPARATOR, File::SEPARATOR)
      end
      all_files = find_files(base_dir, File::FNM_DOTMATCH)
      hidden_files = Set.new(all_files - find_files(base_dir, 0))
      base_dir_config = @config_store.for(base_dir)

      target_files = all_files.select do |file|
        to_inspect?(file, hidden_files, base_dir_config)
      end

      # Most recently modified file first.
      target_files.sort_by! { |path| -File.mtime(path).to_i } if fail_fast?

      target_files
    end

    def to_inspect?(file, hidden_files, base_dir_config)
      return false if base_dir_config.file_to_exclude?(file)
      unless hidden_files.include?(file)
        return true if File.extname(file) == '.rb'
        return true if ruby_executable?(file)
      end
      base_dir_config.file_to_include?(file)
    end

    def find_files(base_dir, flags)
      Dir.glob("#{base_dir}/**/*", flags).select { |path| FileTest.file?(path) }
    end

    def ruby_executable?(file)
      return false unless File.extname(file).empty?
      first_line = File.open(file) { |f| f.readline }
      first_line =~ /#!.*ruby/
    rescue EOFError, ArgumentError => e
      warn "Unprocessable file #{file}: #{e.class}, #{e.message}" if debug?
      false
    end

    def process_explicit_path(path)
      files = if path.include?('*')
                Dir[path]
              else
                [path]
              end

      return files unless force_exclusion?

      files.reject do |file|
        config = @config_store.for(file)
        config.file_to_exclude?(file)
      end
    end
  end
end
