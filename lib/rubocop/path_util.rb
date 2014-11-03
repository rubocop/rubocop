# encoding: utf-8

module RuboCop
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

    def relative_path(path, base_dir = Dir.pwd)
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
          # files.
          return false if basename.start_with?('.')

          # Hidden directories (starting with a dot) will also produce an old
          # match, just like hidden files. A deprecation warning would be wrong
          # for these.
          if path.split(File::SEPARATOR).none? { |s| s.start_with?('.') }
            issue_deprecation_warning(basename, pattern, config_path)
          end
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
  end
end
