# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

    def relative_path(path, base_dir = Dir.pwd)
      # Optimization for the common case where path begins with the base
      # dir. Just cut off the first part.
      return path[(base_dir.length + 1)..-1] if path.start_with?(base_dir)

      path_name = Pathname.new(File.expand_path(path))
      path_name.relative_path_from(Pathname.new(base_dir)).to_s
    end

    # TODO: The old way of matching patterns is flawed, so a new one has been
    # introduced. We keep supporting the old way for a while and issue
    # deprecation warnings when a pattern is used that produced a match with
    # the old way but doesn't match with the new.
    def match_path?(pattern, path, config_path)
      case pattern
      when String
        basename = File.basename(path)
        old_match = basename == pattern || File.fnmatch?(pattern, path)
        new_match = File.fnmatch?(pattern, path, File::FNM_PATHNAME)
        if old_match && !new_match
          # Patterns like dir/**/* will produce an old match for files
          # beginning with dot, but not a new match. That's a special case,
          # though. Not what we want to handle here. And this is a match that
          # we overrule. Only patterns like dir/**/.* can be used to match dot
          # files. Hidden directories (starting with a dot) will also produce
          # an old match, just like hidden files.
          return false if path.split(File::SEPARATOR).any? { |s| hidden?(s) }

          issue_deprecation_warning(basename, pattern, config_path)
        end
        old_match || new_match
      when Regexp
        path =~ pattern
      end
    end

    def issue_deprecation_warning(basename, pattern, config_path)
      instruction = if basename == pattern
                      ". Change to '**/#{pattern}'."
                    elsif pattern.end_with?('**')
                      ". Change to '#{pattern}/*'."
                    end
      warn("Warning: Deprecated pattern style '#{pattern}' in " \
           "#{config_path}#{instruction}")
    end

    def hidden?(path_component)
      path_component =~ /^\.[^.]/
    end

    # Returns true for an absolute Unix or Windows path.
    def absolute?(path)
      path =~ %r{\A([A-Z]:)?/}
    end
  end
end
