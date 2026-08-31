# frozen_string_literal: true

require 'open3'

module RuboCop
  # Lists the files that differ from a git revision, for `--changed`.
  #
  # Shelling out to `git` keeps RuboCop free of a version control dependency,
  # and means the answer is exactly what git would give on the command line.
  #
  # @api private
  class ChangedFiles
    DEFAULT_REVISION = 'HEAD'
    FILESYSTEM_ENCODING = Encoding.find('filesystem')

    def initialize(revision = nil)
      @revision = revision || DEFAULT_REVISION
    end

    # Files that were added or modified since the revision, as absolute paths.
    # Deleted files are left out - there is nothing left to inspect - and
    # untracked files are included, since a file that is new to the working
    # tree has changed as surely as one git already knows about.
    #
    # @return [Set<String>]
    def paths
      root = repository_root

      (modified_paths + untracked_paths).to_set { |path| File.expand_path(path, root) }
    end

    private

    def repository_root
      filesystem_path(git('rev-parse', '--show-toplevel').b.chomp)
    end

    def modified_paths
      # `diff.relative` would make git report paths relative to the current
      # directory rather than to the repository root.
      split_paths(
        git('-c', 'diff.relative=false', 'diff', '--name-only', '--diff-filter=d', '-z', @revision)
      )
    rescue Error
      raise unless unborn_head?

      # A repository without commits has nothing to diff against, and
      # everything in it is untracked - which is what the caller wants to hear
      # rather than an error about `HEAD` not resolving.
      []
    end

    def unborn_head?
      return false unless @revision == DEFAULT_REVISION

      _stdout, _stderr, status = Open3.capture3('git', 'rev-parse', '--verify', '--quiet', 'HEAD')
      !status.success?
    end

    def untracked_paths
      # `--full-name` anchors the paths to the repository root, the way the
      # paths from `git diff` already are.
      split_paths(git('ls-files', '--others', '--exclude-standard', '--full-name', '-z'))
    end

    # The `-z` above is what makes these usable: without it git wraps any path
    # that is not plain ASCII in quotes and octal escapes, and those files drop
    # out of the comparison without a word.
    def split_paths(output)
      output.b.split("\0").reject(&:empty?).map { |path| filesystem_path(path) }
    end

    # git hands back bytes, which Ruby tags with the encoding the process
    # happens to have been started in - splitting those bytes as US-ASCII raises
    # on any path that is not. They have to end up in the encoding `Dir.glob`
    # uses, or a path with a non-ASCII character in it never matches the file
    # list it is compared against.
    #
    # On POSIX those bytes are already the filesystem's own, so the encoding is
    # simply corrected. Windows is the exception: git converts paths to UTF-8 on
    # the way out, while Ruby reports file names in the local code page, so the
    # two have to be reconciled.
    def filesystem_path(path)
      path = path.dup

      return path.force_encoding(FILESYSTEM_ENCODING) unless Platform.windows?

      path.force_encoding(Encoding::UTF_8).encode(FILESYSTEM_ENCODING)
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      # A name the local code page cannot represent. Nothing good is left to do
      # with it, and dropping it would be worse than reporting it as-is.
      path.force_encoding(FILESYSTEM_ENCODING)
    end

    def git(*args)
      stdout, stderr, status = Open3.capture3('git', *args)

      raise Error, git_error_message(stderr) unless status.success?

      stdout
    rescue Errno::ENOENT
      raise Error, '--changed requires git to be installed and on your PATH.'
    end

    def git_error_message(stderr)
      message = stderr.strip
      message = 'git failed with no output on standard error.' if message.empty?

      "--changed could not ask git which files changed: #{message}"
    end
  end
end
