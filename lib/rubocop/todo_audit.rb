# frozen_string_literal: true

module RuboCop
  # Audits `.rubocop_todo.yml` for `Exclude` entries that are no longer
  # needed: files a cop would not flag anymore, or files that no longer
  # exist. Used by the `--report-unused-todo-entries` option.
  # @api private
  class TodoAudit
    Entry = Struct.new(:cop_name, :path)

    def initialize(config_store, options)
      @config_store = config_store
      @options = options
    end

    # @return [Array<Entry>, nil] the unused entries, or `nil` when there is
    #   no todo file to audit
    def unused_entries
      return nil unless todo_path

      entries = todo_exclude_entries
      return [] if entries.empty?

      @todo_entries = entries
      entries.reject { |entry| needed?(entry) }
    end

    def todo_file
      CLI::Command::AutoGenerateConfig::AUTO_GENERATED_FILE
    end

    private

    def todo_path
      return @todo_path if defined?(@todo_path)

      path = File.expand_path(todo_file)
      @todo_path = File.exist?(path) ? path : nil
    end

    def todo_exclude_entries
      yaml = YAML.safe_load_file(todo_path, permitted_classes: [Regexp, Symbol], aliases: true)
      return [] unless yaml.is_a?(Hash)

      yaml.flat_map do |cop_name, cop_config|
        next [] unless auditable_cop?(cop_name, cop_config)

        cop_config['Exclude'].grep(String).map { |path| Entry.new(cop_name, path) }
      end
    end

    # Only registered cops with an `Exclude` list can be audited - for an
    # unknown cop (e.g. from an extension that is not loaded in this run)
    # the absence of offenses proves nothing.
    def auditable_cop?(cop_name, cop_config)
      cop_name.include?('/') &&
        cop_config.is_a?(Hash) &&
        cop_config['Exclude'].is_a?(Array) &&
        Cop::Registry.global.contains_cop_matching?([cop_name])
    end

    # An entry is needed when any expanded path still reports an offense for
    # its cop. Stop at the first hit so live glob entries skip most matches.
    def needed?(entry)
      expand_path(entry.path).any? { |file| offending_cops(file).include?(entry.cop_name) }
    end

    def offending_cops(file)
      @offending_cops ||= {}
      @offending_cops[file] ||= inspect_file(file).to_set(&:cop_name)
    end

    def expand_path(path)
      absolute_path = absolute(path)
      files = File.file?(absolute_path) ? [absolute_path] : []
      return files unless PathUtil.glob?(path)

      files | target_files(absolute_path).select do |file|
        PathUtil.match_path?(absolute_path, file)
      end
    end

    def target_files(path)
      directory = File.dirname(path)
      # Only the basename can be a glob segment; climbing on parent-path
      # metacharacters would scan unrelated roots (e.g. `/Users/me`).
      directory = File.dirname(directory) while PathUtil.glob?(File.basename(directory))
      @target_files ||= {}
      @target_files[directory] ||= TargetFinder.new(@config_store, @options)
                                               .target_files_in_dir(directory)
    end

    def inspect_file(file)
      config = audit_config(@config_store.for_file(file))
      team = Cop::Team.mobilize(todo_cops, config, @options.merge(autocorrect: false))

      processed_source = ProcessedSource.from_file(
        file, config.target_ruby_version, parser_engine: config.parser_engine
      )
      processed_source.config = config
      processed_source.registry = todo_cops

      team.investigate(processed_source).offenses.reject(&:disabled?)
    end

    # Registry limited to cops named in the todo, so each file only pays for
    # the audits that can keep an entry.
    def todo_cops
      @todo_cops ||= begin
        names = @todo_entries.map(&:cop_name).uniq
        Cop::Registry.global.filter_by_badge { |badge| badge.match_name?(names) }
      end
    end

    # A copy of the configuration with the todo exclusions removed for the
    # audited cops, so their offenses in the listed files become visible.
    # Memoized per underlying `Config` so cop lookups stay warm across files.
    def audit_config(config)
      @audit_configs ||= {}.compare_by_identity
      @audit_configs[config] ||= build_audit_config(config)
    end

    def build_audit_config(config)
      hash = config.to_hash.dup

      @todo_entries.group_by(&:cop_name).each do |cop_name, cop_entries|
        cop_config = hash[cop_name]
        next unless cop_config.is_a?(Hash) && cop_config['Exclude'].is_a?(Array)

        hash[cop_name] = subtract_excludes(cop_config, cop_entries)
      end

      Config.create(hash, config.loaded_path, check: false)
    end

    def subtract_excludes(cop_config, cop_entries)
      removals = cop_entries.map { |entry| absolute(entry.path) }
      cop_config.merge('Exclude' => cop_config['Exclude'] - removals)
    end

    def absolute(path)
      File.expand_path(path, File.dirname(todo_path))
    end
  end
end
