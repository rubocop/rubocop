# encoding: utf-8

require 'digest/md5'
require 'find'
require 'tmpdir'

module RuboCop
  # Provides functionality for caching rubocop runs.
  class ResultCache
    # Include the user name in the path as a simple means of avoiding write
    # collisions.
    def initialize(file, options, config_store, cache_root = nil)
      cache_root ||= ResultCache.cache_root(config_store)
      @path = File.join(cache_root, rubocop_checksum, relevant_options(options),
                        file_checksum(file, config_store))
    end

    def valid?
      File.exist?(@path)
    end

    def load
      Marshal.load(IO.binread(@path))
    end

    def save(offenses, disabled_line_ranges, comments)
      FileUtils.mkdir_p(File.dirname(@path))
      preliminary_path = "#{@path}_#{rand(1_000_000_000)}"
      File.open(preliminary_path, 'wb') do |f|
        # The Hash[x.sort] call is a trick that converts a Hash with a default
        # block to a Hash without a default block. Thus making it possible to
        # dump.
        f.write(Marshal.dump([offenses, Hash[disabled_line_ranges.sort],
                              comments]))
      end
      # The preliminary path is used so that if there are multiple RuboCop
      # processes trying to save data for the same inspected file
      # simultaneously, the only problem we run in to is a competition who gets
      # to write to the final file. The contents are the same, so no corruption
      # of data should occur.
      FileUtils.mv(preliminary_path, @path)
    end

    # Remove old files so that the cache doesn't grow too big. When the
    # threshold MaxFilesInCache has been exceeded, the oldest 50% all the files
    # in the cache are removed. The reason for removing so much is that
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
          sorted[0, remove_count].each { |path| File.delete(path) }
          dirs.each { |dir| Dir.rmdir(dir) if Dir["#{dir}/*"].empty? }
        rescue Errno::ENOENT
          # This can happen if parallel RuboCop invocations try to remove the
          # same files. No problem.
          puts $ERROR_INFO if verbose
        end
      end
    end

    private

    def self.cache_root(config_store)
      root = config_store.for('.')['AllCops']['CacheRootDirectory']
      root = Dir.tmpdir if root == '/tmp'
      File.join(root, 'rubocop_cache')
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

    NON_CHANGING = [:color, :format, :formatters, :out, :debug, :fail_level,
                    :cache, :fail_fast, :stdin]

    # Return the options given at invocation, minus the ones that have no
    # effect on which offenses and disabled line ranges are found, and thus
    # don't affect caching.
    def relevant_options(options)
      options = options.reject { |key, _| NON_CHANGING.include?(key) }
      options.to_s.gsub(/[^a-z]+/i, '_')
    end
  end
end
