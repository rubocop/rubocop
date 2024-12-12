# frozen_string_literal: true

require 'fileutils'

module FileHelper
  def create_file(file_path, content, retain_line_terminators: false)
    file_path = File.expand_path(file_path)

    # On Windows, when a file is opened in 'w' mode, LF line terminators (`\n`)
    # are automatically converted to CRLF (`\r\n`).
    # If this is not desired, `force_lf: true` will cause the file to be opened
    # in 'wb' mode instead, which keeps existing line terminators.
    file_mode = retain_line_terminators ? 'wb' : 'w'

    ensure_descendant(file_path)

    dir_path = File.dirname(file_path)
    FileUtils.mkdir_p dir_path

    File.open(file_path, file_mode) do |file|
      case content
      when String
        file.puts content
      when Array
        file.puts content.join("\n")
      end
    end

    file_path
  end

  # rubocop:disable InternalAffairs/CreateEmptyFile
  def create_empty_file(file_path)
    create_file(file_path, '')
  end
  # rubocop:enable InternalAffairs/CreateEmptyFile

  def create_link(link_path, target_path)
    link_path = File.expand_path(link_path)

    ensure_descendant(link_path)

    dir_path = File.dirname(link_path)
    FileUtils.mkdir_p dir_path

    FileUtils.symlink(target_path, link_path)
  end

  def ensure_descendant(path, base = RuboCop::FileFinder.root_level)
    return unless base
    return if path.start_with?(base) && path != base

    raise "Test file #{path} is outside of isolated_environment root #{base}"
  end
end
