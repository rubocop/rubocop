# encoding: utf-8

require 'digest/md5'
require 'find'
require 'tmpdir'
require 'etc'

module RuboCop
  # Provides functionality for caching rubocop runs.
  class ResultCache
    NON_CHANGING = [:color, :format, :formatters, :out, :debug, :fail_level,
                    :cache, :fail_fast, :stdin]

    # Remove old files so that the cache doesn't grow too big. When the
    # threshold MaxFilesInCache has been exceeded, the oldest 50% of all the
    # files in the cache are removed. The reason for removing so much is that
    # cleaning should be done relatively seldom, since there is a slight risk
    # that some other RuboCop process was just about to read the file, when
    # there's parallel execution and the cache is shared.
    def self.cleanup(config_store, verbose, cache_root = nil)
      return if inhibit_cleanup # OPTIMIZE: For faster testing
      cache_root ||= cache_root(config_store)
      return unless File.exist?(cache_root)

      files, dirs = Find.find(cache_root).partition { |path| File.file?(path) }
      if files.length > config_store.for('.')['AllCops']['MaxFilesInCache'] &&
         files.length > 1
        # Add 1 to half the number of files, so that we remove the file if
        # there's only 1 left.
        remove_count = 1 + files.length / 2
        if verbose
          puts "Removing the #{remove_count} oldest files from #{cache_root}"
        end
        sorted = files.sort_by { |path| File.mtime(path) }
        begin
          File.delete(*sorted[0, remove_count])
          dirs.each { |dir| Dir.rmdir(dir) if Dir["#{dir}/*"].empty? }
        rescue Errno::ENOENT
          # This can happen if parallel RuboCop invocations try to remove the
          # same files. No problem.
          puts $ERROR_INFO if verbose
        end
      end
    end

    def self.cache_root(config_store)
      root = config_store.for('.')['AllCops']['CacheRootDirectory']
      if root == '/tmp'
        tmpdir = File.realpath(Dir.tmpdir)
        # Include user ID in the path to make sure the user has write access.
        root = File.join(tmpdir, Process.uid.to_s)
      end
      File.join(root, 'rubocop_cache')
    end

    def initialize(file, options, config_store, cache_root = nil)
      cache_root ||= ResultCache.cache_root(config_store)
      @path = File.join(cache_root, rubocop_checksum, RUBY_VERSION,
                        relevant_options(options),
                        file_checksum(file, config_store))
      @cached_data = CachedData.new(file)
    end

    def valid?
      File.exist?(@path)
    end

    def load
      @cached_data.from_json(IO.binread(@path))
    end

    def save(offenses)
      dir = File.dirname(@path)
      FileUtils.mkdir_p(dir)
      preliminary_path = "#{@path}_#{rand(1_000_000_000)}"
      # RuboCop must be in control of where its cached data is stored. A
      # symbolic link anywhere in the cache directory tree is an indication
      # that a symlink attack is being waged.
      return if any_symlink?(dir)

      File.open(preliminary_path, 'wb') do |f|
        f.write(@cached_data.to_json(offenses))
      end
      # The preliminary path is used so that if there are multiple RuboCop
      # processes trying to save data for the same inspected file
      # simultaneously, the only problem we run in to is a competition who gets
      # to write to the final file. The contents are the same, so no corruption
      # of data should occur.
      FileUtils.mv(preliminary_path, @path)
    end

    private

    def any_symlink?(path)
      while path != File.dirname(path)
        if File.symlink?(path)
          warn "Warning: #{path} is a symlink, which is not allowed."
          return true
        end
        path = File.dirname(path)
      end
      false
    end

    def file_checksum(file, config_store)
      Digest::MD5.hexdigest(Dir.pwd + file + IO.read(file) +
                            config_store.for(file).to_s)
    rescue Errno::ENOENT
      # Spurious files that come and go should not cause a crash, at least not
      # here.
      '_'
    end

    class << self
      attr_accessor :source_checksum, :inhibit_cleanup
    end

    # The checksum of the rubocop program running the inspection.
    def rubocop_checksum
      ResultCache.source_checksum ||=
        begin
          lib_root = File.join(File.dirname(__FILE__), '..')
          bin_root = File.join(lib_root, '..', 'bin')
          source = Find.find(lib_root, bin_root).sort.map do |path|
            IO.read(path) if File.file?(path)
          end
          Digest::MD5.hexdigest(source.join)
        end
    end

    # Return the options given at invocation, minus the ones that have no
    # effect on which offenses and disabled line ranges are found, and thus
    # don't affect caching.
    def relevant_options(options)
      options = options.reject { |key, _| NON_CHANGING.include?(key) }
      options.to_s.gsub(/[^a-z]+/i, '_')
    end
  end
end
