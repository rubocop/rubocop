# encoding: utf-8

module Rubocop
  # This class finds target files to inspect by scanning directory tree
  # and picking ruby files.
  class TargetFinder
    def initialize(config_store, debug = false)
      @config_store = config_store
      @debug = debug
    end

    # Generate a list of target files by expanding globing patterns
    # (if any). If args is empty recursively finds all Ruby source
    # files under the current directory
    # @return [Array] array of filenames
    def target_files(args)
      return ruby_files if args.empty?

      files = []

      args.each do |target|
        if File.directory?(target)
          files += ruby_files(target.chomp(File::SEPARATOR))
        elsif target =~ /\*/
          files += Dir[target]
        else
          files << target
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
    # @param root Root directory under which to search for ruby source files
    # @return [Array] Array of filenames
    def ruby_files(root = Dir.pwd)
      files = Dir["#{root}/**/*"].select { |file| FileTest.file?(file) }

      rb = []

      rb += files.select { |file| File.extname(file) == '.rb' }
      rb += files.select do |file|
        if File.extname(file) == '' && !excluded_file?(file)
          begin
            File.open(file) { |f| f.readline } =~ /#!.*ruby/
          rescue EOFError, ArgumentError => e
            log_error(e, "Unprocessable file #{file.inspect}: ")
            false
          end
        end
      end

      rb += files.select do |file|
        config = @config_store.for(file)
        config.file_to_include?(file)
      end

      rb.reject { |file| excluded_file?(file) }.uniq
    end

    def log_error(e, msg = '')
      if @debug
        error_message = "#{e.class}, #{e.message}"
        warn "#{msg}\t#{error_message}"
      end
    end

    def excluded_file?(file)
      @config_store.for(file).file_to_exclude?(file)
    end
  end
end
