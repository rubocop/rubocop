# encoding: utf-8
# frozen_string_literal: true

require 'digest/md5'
require 'find'
require 'tmpdir'
require 'etc'

module RuboCop
  # Provides functionality for caching rubocop runs.
  class ResultCache
    NON_CHANGING = [:color, :format, :formatters, :out, :debug, :fail_level,
                    :cache, :fail_fast, :stdin].freeze

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
      return unless requires_file_removal?(files.length, config_store)

      remove_oldest_files(files, dirs, cache_root, verbose)
    end

    class << self
      private

      def requires_file_removal?(file_count, config_store)
        file_count > 1 &&
          file_count > config_store.for('.').for_all_cops['MaxFilesInCache']
      end

      def remove_oldest_files(files, dirs, cache_root, verbose)
        # Add 1 to half the number of files, so that we remove the file if
        # there's only 1 left.
        remove_count = 1 + files.length / 2
        if verbose
          puts "Removing the #{remove_count} oldest files from #{cache_root}"
        end
        sorted = files.sort_by { |path| File.mtime(path) }
        remove_files(sorted, dirs, remove_count, verbose)
      end

      def remove_files(files, dirs, remove_count, verbose)
        # Batch file deletions, deleting over 130,000+ files will crash
        # File.delete.
        files[0, remove_count].each_slice(10_000).each do |files_slice|
          File.delete(*files_slice)
        end
        dirs.each { |dir| Dir.rmdir(dir) if Dir["#{dir}/*"].empty? }
      rescue Errno::ENOENT
        # This can happen if parallel RuboCop invocations try to remove the
        # same files. No problem.
        puts $ERROR_INFO if verbose
      end
    end

    def self.cache_root(config_store)
      root = config_store.for('.').for_all_cops['CacheRootDirectory']
      if root == '/tmp'
        tmpdir = File.realpath(Dir.tmpdir)
        # Include user ID in the path to make sure the user has write access.
        root = File.join(tmpdir, Process.uid.to_s)
      end
      File.join(root, 'rubocop_cache')
    end

    def self.allow_symlinks_in_cache_location?(config_store)
      config_store.for('.').for_all_cops['AllowSymlinksInCacheRootDirectory']
    end

    def initialize(file, options, config_store, cache_root = nil)
      cache_root ||= ResultCache.cache_root(config_store)
      @allow_symlinks_in_cache_location =
        ResultCache.allow_symlinks_in_cache_location?(config_store)
      @path = File.join(cache_root, rubocop_checksum,
                        relevant_options_digest(options),
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
      # symbolic link anywhere in the cache directory tree can be an
      # indication that a symlink attack is being waged.
      return if symlink_protection_triggered?(dir)

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

    def symlink_protection_triggered?(path)
      !@allow_symlinks_in_cache_location && any_symlink?(path)
    end

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

          # These are all the files we have `require`d plus everything in the
          # bin directory. A change to any of them could affect the cop output
          # so we include them in the cache hash.
          source_files = $LOADED_FEATURES + Find.find(bin_root).to_a
          sources = source_files
                    .select { |path| File.file?(path) }
                    .sort
                    .map { |path| IO.read(path) }
          Digest::MD5.hexdigest(sources.join)
        end
    end

    # Return a hash of the options given at invocation, minus the ones that have
    # no effect on which offenses and disabled line ranges are found, and thus
    # don't affect caching.
    def relevant_options_digest(options)
      options = options.reject { |key, _| NON_CHANGING.include?(key) }
      options = options.to_s.gsub(/[^a-z]+/i, '_')
      # We must avoid making file names too long for some filesystems to handle
      # If they are short, we can leave them human-readable
      options.length <= 32 ? options : Digest::MD5.hexdigest(options)
    end
  end
end
