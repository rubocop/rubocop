# frozen_string_literal: true

module RuboCop
  # This module contains a collection of useful utility methods.
  module Util
    def self.silence_warnings
      # Replaces Kernel::silence_warnings since it hides any warnings,
      # including the RuboCop ones
      old_verbose = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = old_verbose
    end

    # Replaces the contents of `path` without a window in which the file is truncated
    # but not yet rewritten, so that an interrupted run or a full disk cannot lose
    # the original: the new contents are written next to the file and renamed over it,
    # like `ResultCache#save`. `File.write` is used for the temporary file so text-mode
    # semantics (the CRLF conversion on Windows) stay identical to a direct write.
    # Where the temporary file cannot be created or renamed for lack of permission,
    # a direct write is used as before.
    def self.replace_file_contents(path, contents)
      # Write through symlinks so that the rename replaces the real file and
      # the symlink survives.
      path = File.realpath(path)

      # Opening a read-only file fails without truncating it, keeping the behavior
      # a direct write always had.
      return File.write(path, contents) unless File.writable?(path)

      temp_path = "#{path}.#{Process.pid}.#{rand(1_000_000_000)}.rubocop.tmp"
      begin
        replace_via_temporary_file(path, temp_path, contents)
      ensure
        FileUtils.rm_f(temp_path)
      end
    rescue Errno::ENOENT
      # The file vanished mid-run or is a dangling symlink: recreate it the way
      # a direct write always has.
      File.write(path, contents)
    end

    def self.replace_via_temporary_file(path, temp_path, contents)
      # The directory refuses new files even though the file itself is writable,
      # so a direct write is the only option left.
      return File.write(path, contents) unless write_temporary_file(temp_path, contents)

      begin
        # A fresh file would get umask-default permissions on rename;
        # keep the original's.
        File.chmod(File.stat(path).mode, temp_path)
        File.rename(temp_path, path)
      rescue SystemCallError
        # The replacement was refused, e.g. the file is open in another process on Windows.
        # The contents already fit on disk, so a direct write is safe once the temporary copy
        # no longer takes up that space.
        FileUtils.rm_f(temp_path)
        File.write(path, contents)
      end
    end
    private_class_method :replace_via_temporary_file

    # Space errors such as `ENOSPC` must propagate: a direct write would then
    # truncate the file and fail, which is exactly the loss being avoided.
    def self.write_temporary_file(temp_path, contents)
      File.write(temp_path, contents)
      true
    rescue Errno::EACCES, Errno::EPERM
      false
    end
    private_class_method :write_temporary_file
  end
end
