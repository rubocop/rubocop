# frozen_string_literal: true

require 'set'

module RuboCop
  RUBY_EXTENSIONS = %w[.rb
                       .axlsx
                       .builder
                       .fcgi
                       .gemfile
                       .gemspec
                       .god
                       .jb
                       .jbuilder
                       .mspec
                       .opal
                       .pluginspec
                       .podspec
                       .rabl
                       .rake
                       .rbuild
                       .rbw
                       .rbx
                       .ru
                       .ruby
                       .spec
                       .thor
                       .watchr].freeze

  RUBY_INTERPRETERS = %w[ruby
                         macruby
                         rake
                         jruby
                         rbx].freeze

  RUBY_FILENAMES = %w[.irbrc
                      .pryrc
                      Appraisals
                      Berksfile
                      Brewfile
                      Buildfile
                      Capfile
                      Cheffile
                      Dangerfile
                      Deliverfile
                      Fastfile
                      Gemfile
                      Guardfile
                      Jarfile
                      Mavenfile
                      Podfile
                      Puppetfile
                      Rakefile
                      Snapfile
                      Thorfile
                      Vagabondfile
                      Vagrantfile
                      buildfile].freeze

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
        base_dir = base_dir.gsub(File::ALT_SEPARATOR, File::SEPARATOR)
      end
      all_files = find_files(base_dir, File::FNM_DOTMATCH)
      hidden_files = Set.new(all_files - find_files(base_dir, 0))
      base_dir_config = @config_store.for(base_dir)

      target_files = all_files.select do |file|
        to_inspect?(file, hidden_files, base_dir_config)
      end

      # Most recently modified file first.
      target_files.sort_by! { |path| Integer(-File.mtime(path)) } if fail_fast?

      target_files
    end

    def to_inspect?(file, hidden_files, base_dir_config)
      return false if base_dir_config.file_to_exclude?(file)
      return true if !hidden_files.include?(file) && ruby_file?(file)
      base_dir_config.file_to_include?(file)
    end

    # Search for files recursively starting at the given base directory using
    # the given flags that determine how the match is made. Excluded files will
    # be removed later by the caller, but as an optimization find_files removes
    # the top level directories that are excluded in configuration in the
    # normal way (dir/**/*).
    def find_files(base_dir, flags)
      wanted_toplevel_dirs = toplevel_dirs(base_dir, flags) -
                             excluded_dirs(base_dir)
      wanted_toplevel_dirs.map! { |dir| dir << '/**/*' }

      pattern = if wanted_toplevel_dirs.empty?
                  # We need this special case to avoid creating the pattern
                  # /**/* which searches the entire file system.
                  ["#{base_dir}/**/*"]
                else
                  # Search the non-excluded top directories, but also add files
                  # on the top level, which would otherwise not be found.
                  wanted_toplevel_dirs.unshift("#{base_dir}/*")
                end
      Dir.glob(pattern, flags).select { |path| FileTest.file?(path) }
    end

    def toplevel_dirs(base_dir, flags)
      Dir.glob(File.join(base_dir, '*'), flags).select do |dir|
        File.directory?(dir) && !dir.end_with?('/.', '/..')
      end
    end

    def excluded_dirs(base_dir)
      all_cops_config = @config_store.for(base_dir).for_all_cops
      dir_tree_excludes = all_cops_config['Exclude'].select do |pattern|
        pattern.is_a?(String) && pattern.end_with?('/**/*')
      end
      dir_tree_excludes.map { |pattern| pattern.sub(%r{/\*\*/\*$}, '') }
    end

    def ruby_extension?(file)
      RUBY_EXTENSIONS.include?(File.extname(file))
    end

    def ruby_filename?(file)
      RUBY_FILENAMES.include?(File.basename(file))
    end

    def ruby_executable?(file)
      return false unless File.extname(file).empty? && File.exist?(file)
      first_line = File.open(file, &:readline)
      !(first_line =~ /#!.*(#{RUBY_INTERPRETERS.join('|')})/).nil?
    rescue EOFError, ArgumentError => e
      warn "Unprocessable file #{file}: #{e.class}, #{e.message}" if debug?
      false
    end

    def ruby_file?(file)
      ruby_extension?(file) || ruby_filename?(file) || ruby_executable?(file)
    end

    def process_explicit_path(path)
      files = path.include?('*') ? Dir[path] : [path]

      files.select! { |file| ruby_file?(file) }

      return files unless force_exclusion?

      files.reject do |file|
        config = @config_store.for(file)
        config.file_to_exclude?(file)
      end
    end
  end
end
