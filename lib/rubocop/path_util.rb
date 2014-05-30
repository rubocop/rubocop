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
          instruction = if basename == pattern
                          ". Change to '**/#{pattern}'."
                        elsif pattern.end_with?('**')
                          ". Change to '#{pattern}/*'."
                        end
          warn("Warning: Deprecated pattern style '#{pattern}' in " \
               "#{config_path}#{instruction}")
        end
        old_match || new_match
      when Regexp
        path =~ pattern
      end
    end
  end
end
