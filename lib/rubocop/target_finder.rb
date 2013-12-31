# encoding: utf-8

module Rubocop
  # This class finds target files to inspect by scanning the directory tree
  # and picking ruby files.
  class TargetFinder
    def initialize(config_store, debug = false)
      @config_store = config_store
      @debug = debug
    end

    # Generate a list of target files by expanding globbing patterns
    # (if any). If args is empty, recursively find all Ruby source
    # files under the current directory
    # @return [Array] array of file paths
    def find(args)
      return target_files_in_dir if args.empty?

      files = []

      args.uniq.each do |arg|
        if File.directory?(arg)
          files += target_files_in_dir(arg.chomp(File::SEPARATOR))
        elsif arg.include?('*')
          files += Dir[arg]
        else
          files << arg
        end
      end

      files.map { |f| File.expand_path(f) }.uniq
    end

    # Finds all Ruby source files under the current or other supplied
    # directory.  A Ruby source file is defined as a file with the `.rb`
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
      files = Dir["#{base_dir}/**/*"].select { |path| FileTest.file?(path) }
      base_dir_config = @config_store.for("#{base_dir}/foobar.rb")

      target_files = files.select do |file|
        next false if base_dir_config.file_to_exclude?(file)
        next true if File.extname(file) == '.rb'
        next true if ruby_executable?(file)
        @config_store.for(file).file_to_include?(file)
      end

      target_files.uniq
    end

    def ruby_executable?(file)
      return false unless File.extname(file).empty?
      first_line = File.open(file) { |f| f.readline }
      first_line =~ /#!.*ruby/
    rescue EOFError, ArgumentError => e
      warn "Unprocessable file #{file}: #{e.class}, #{e.message}" if @debug
      false
    end
  end
end
