# frozen_string_literal: true

module RuboCop
  # This class finds target files to inspect by scanning the directory tree
  # and picking ruby files.
  # @api private
  class TargetFinder
    HIDDEN_PATH_SUBSTRING = "#{File::SEPARATOR}."

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
    def find(args, mode)
      return target_files_in_dir if args.empty?

      files = []

      args.uniq.each do |arg|
        files += if File.directory?(arg)
                   target_files_in_dir(arg.chomp(File::SEPARATOR))
                 else
                   process_explicit_path(arg, mode)
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
      base_dir = base_dir.gsub(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
      all_files = find_files(base_dir, File::FNM_DOTMATCH)
      # use file.include? for performance optimization
      hidden_files = all_files.select { |file| file.include?(HIDDEN_PATH_SUBSTRING) }.sort
      base_dir_config = @config_store.for(base_dir)

      target_files = all_files.select do |file|
        to_inspect?(file, hidden_files, base_dir_config)
      end

      target_files.sort_by!(&order)
    end

    def to_inspect?(file, hidden_files, base_dir_config)
      return false if base_dir_config.file_to_exclude?(file)
      return true if !hidden_files.bsearch do |hidden_file|
        file <=> hidden_file
      end && ruby_file?(file)

      base_dir_config.file_to_include?(file)
    end

    # Search for files recursively starting at the given base directory using
    # the given flags that determine how the match is made. Excluded files will
    # be removed later by the caller, but as an optimization find_files removes
    # the top level directories that are excluded in configuration in the
    # normal way (dir/**/*).
    def find_files(base_dir, flags)
      # get all wanted directories first to improve speed of finding all files
      exclude_pattern = combined_exclude_glob_patterns(base_dir)
      dir_flags = flags | File::FNM_PATHNAME | File::FNM_EXTGLOB
      patterns = wanted_dir_patterns(base_dir, exclude_pattern, dir_flags)
      patterns.map! { |dir| File.join(dir, '*') }
      # We need this special case to avoid creating the pattern
      # /**/* which searches the entire file system.
      patterns = [File.join(dir, '**/*')] if patterns.empty?

      Dir.glob(patterns, flags).select { |path| FileTest.file?(path) }
    end

    def wanted_dir_patterns(base_dir, exclude_pattern, flags)
      dirs = Dir.glob(File.join(base_dir.gsub('/**/', '/\**/'), '*/'), flags)
                .reject do |dir|
                  dir.end_with?('/./', '/../') || File.fnmatch?(exclude_pattern, dir, flags)
                end
      dirs.flat_map { |dir| wanted_dir_patterns(dir, exclude_pattern, flags) }
          .unshift(base_dir)
    end

    def combined_exclude_glob_patterns(base_dir)
      exclude = @config_store.for(base_dir).for_all_cops['Exclude']
      patterns = exclude.select { |pattern| pattern.is_a?(String) && pattern.end_with?('/**/*') }
                        .map { |pattern| pattern.sub("#{base_dir}/", '') }
      "#{base_dir}/{#{patterns.join(',')}}"
    end

    def ruby_extension?(file)
      ruby_extensions.include?(File.extname(file))
    end

    def ruby_extensions
      @ruby_extensions ||= begin
        ext_patterns = all_cops_include.select do |pattern|
          pattern.start_with?('**/*.')
        end
        ext_patterns.map { |pattern| pattern.sub('**/*', '') }
      end
    end

    def ruby_filename?(file)
      ruby_filenames.include?(File.basename(file))
    end

    def ruby_filenames
      @ruby_filenames ||= begin
        file_patterns = all_cops_include.reject do |pattern|
          pattern.start_with?('**/*.')
        end
        file_patterns.map { |pattern| pattern.sub('**/', '') }
      end
    end

    def all_cops_include
      @all_cops_include ||=
        @config_store.for_pwd.for_all_cops['Include'].map(&:to_s)
    end

    def ruby_executable?(file)
      return false unless File.extname(file).empty? && File.exist?(file)

      first_line = File.open(file, &:readline)
      /#!.*(#{ruby_interpreters(file).join('|')})/.match?(first_line)
    rescue EOFError, ArgumentError => e
      warn("Unprocessable file #{file}: #{e.class}, #{e.message}") if debug?

      false
    end

    def ruby_interpreters(file)
      @config_store.for(file).for_all_cops['RubyInterpreters']
    end

    def stdin?
      @options.key?(:stdin)
    end

    def ruby_file?(file)
      stdin? || ruby_extension?(file) || ruby_filename?(file) ||
        ruby_executable?(file)
    end

    def configured_include?(file)
      @config_store.for_pwd.file_to_include?(file)
    end

    def included_file?(file)
      ruby_file?(file) || configured_include?(file)
    end

    def process_explicit_path(path, mode)
      files = path.include?('*') ? Dir[path] : [path]

      if mode == :only_recognized_file_types || force_exclusion?
        files.select! { |file| included_file?(file) }
      end

      return files unless force_exclusion?

      files.reject do |file|
        config = @config_store.for(file)
        config.file_to_exclude?(file)
      end
    end

    private

    def order
      if fail_fast?
        # Most recently modified file first.
        ->(path) { -Integer(File.mtime(path)) }
      else
        :itself
      end
    end
  end
end
