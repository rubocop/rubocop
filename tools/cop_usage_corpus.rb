#!/usr/bin/env ruby
# frozen_string_literal: true

# Corpus-based RuboCop cop-usage analysis.
#
# Unlike `cop_disable_stats.rb` (which counts inline directives across *all* of
# GitHub via code search, forks included), this tool works from a curated,
# fork-free sample of the most popular Ruby repositories and extracts EVERY way a
# cop can be turned off, from the same denominator:
#
#   * config disable  - `Cop: { Enabled: false }` in .rubocop.yml (global opt-out)
#   * config pending  - `Cop: { Enabled: pending }`
#   * config exclude  - `Cop: { Exclude: [...] }` (partial opt-out)
#   * dept disable    - `Department: { Enabled: false }` (expanded to its cops)
#   * todo backlog    - cop present in .rubocop_todo.yml (unfixed offenses)
#   * inline disable  - `# rubocop:disable Dept/Cop` in source
#   * inline todo     - `# rubocop:todo Dept/Cop` in source
#
# For each repo it downloads the HEAD tarball (cheaper than a clone - no history),
# parses the config files, greps the source, records the per-repo signals, and
# deletes the checkout. Results are cached per repo (resumable: re-running skips
# repos already processed). Auth/transport go through the `gh` CLI.
#
# Usage:
#   bundle exec ruby tools/cop_usage_corpus.rb --repos 200       # collect + report
#   bundle exec ruby tools/cop_usage_corpus.rb --report-only     # re-render report
#   bundle exec ruby tools/cop_usage_corpus.rb --repos 30        # smaller sample
#
# Outputs (tmp/):
#   tmp/cop-corpus-cache.json    per-repo raw signals (resumable cache)
#   tmp/cop-corpus-report.md     rich multi-signal report
#   tmp/cop-corpus-stats.csv     per-cop aggregates
#
# If tmp/cop-disable-stats.json (from cop_disable_stats.rb) exists, its global
# code-search inline counts are merged in as an extra column for scale context.

require 'json'
require 'yaml'
require 'open3'
require 'optparse'
require 'fileutils'

module CopUsageCorpus
  DIRECTIVE = /rubocop:(disable|todo)\s+(.+)/.freeze
  SCAN_GLOBS = %w[*.rb *.rake *.gemspec Rakefile Gemfile].freeze
  YAML_OPTS = { permitted_classes: [Regexp, Symbol], aliases: true }.freeze

  # Well-known base-style configs that repos pull in via `inherit_gem`. We fetch
  # these so an adopting repo's *inherited* disables/params are counted too (and
  # so we can summarize what these community default-sets actually change). Maps
  # gem name -> raw GitHub path of its primary config file.
  SHARED_CONFIGS = {
    'rubocop-rails-omakase' => 'rails/rubocop-rails-omakase/HEAD/rubocop.yml',
    'standard' => 'standardrb/standard/HEAD/config/base.yml',
    'standard-performance' => 'standardrb/standard-performance/HEAD/config/base.yml',
    'standard-custom' => 'standardrb/standard-custom/HEAD/config/base.yml',
    'rubocop-github' => 'github/rubocop-github/HEAD/config/default.yml',
    'rubocop-discourse' => 'discourse/rubocop-discourse/HEAD/config/default.yml',
    'prawn-dev' => 'prawnpdf/prawn-dev/HEAD/rubocop.yml'
  }.freeze

  module_function

  def registry
    @registry ||= begin
      require 'rubocop'
      cops = RuboCop::Cop::Registry.global.cops
      names = cops.map(&:cop_name)
      depts = names.map { |n| n.split('/').first }.uniq
      dept_cops = names.group_by { |n| n.split('/').first }
      { names: names.to_set, depts: depts.to_set, dept_cops: dept_cops }
    end
  rescue LoadError
    abort 'Could not load rubocop. Run me with `bundle exec`.'
  end

  # Each repo's influence weight - dampened by log so a 50k-star project counts
  # more than a 100-star one, but not 500x more.
  def weight(stars)
    Math.log10((stars || 0) + 10)
  end

  # Fetch + parse the SHARED_CONFIGS once (cached). Returns
  # { gem => { 'cop_config' => {...}, 'dept_config' => {...} } } (nil if unfetchable).
  def shared_configs(cache_path = 'tmp/shared-configs-cache.json')
    @shared_configs ||= begin
      raw = File.exist?(cache_path) ? JSON.parse(File.read(cache_path)) : {}
      SHARED_CONFIGS.each do |gem, path|
        next if raw.key?(gem)

        raw[gem] = fetch_yaml("https://raw.githubusercontent.com/#{path}")
        File.write(cache_path, JSON.pretty_generate(raw))
      end
      raw.transform_values { |data| data && classify_config(data) }
    end
  end

  def fetch_yaml(url)
    body, _, st = Open3.capture3('curl', '-sf', url)
    return nil unless st.success?

    data = YAML.safe_load(body, **YAML_OPTS)
    data.is_a?(Hash) ? json_safe(data) : nil
  rescue Psych::Exception, StandardError
    nil
  end

  def json_safe(obj)
    case obj
    when Hash then obj.to_h { |k, v| [k.to_s, json_safe(v)] }
    when Array then obj.map { |e| json_safe(e) }
    when Float then obj.finite? ? obj : obj.to_s
    when Symbol then obj.to_s
    else obj
    end
  end

  def classify_config(data)
    reg = registry
    cop = {}
    dept = {}
    data.each do |key, val|
      next unless val.is_a?(Hash)

      cop[key] = slim(val) if reg[:names].include?(key)
      dept[key] = slim(val) if reg[:depts].include?(key)
    end
    { 'cop_config' => cop, 'dept_config' => dept }
  end

  # --- collection ---------------------------------------------------------

  def top_ruby_repos(count)
    out, err, st = Open3.capture3('gh', 'search', 'repos', '--language', 'ruby',
                                  '--sort', 'stars', '--limit', count.to_s,
                                  '--json', 'fullName,stargazersCount', '--', 'fork:false')
    abort "repo search failed: #{err}" unless st.success?
    JSON.parse(out)
  end

  def process_repo(full_name, work)
    base = File.join(work, full_name.tr('/', '_'))
    tgz = "#{base}.tgz"
    dir = base
    FileUtils.mkdir_p(dir)
    system("gh api repos/#{full_name}/tarball > #{tgz} 2>/dev/null")
    return empty_result.merge('error' => 'download') unless File.size?(tgz)

    system("tar xzf #{tgz} -C #{dir} 2>/dev/null")
    root = Dir.glob(File.join(dir, '*')).find { |p| File.directory?(p) } || dir

    result = empty_result
    extract_config(root, result)
    parse_todo_file(File.join(root, '.rubocop_todo.yml'), result)
    grep_inline(root, result)
    result
  ensure
    FileUtils.rm_rf([dir, tgz])
  end

  # Per repo we store the *raw* config (cop params, AllCops, inherits) plus inline
  # directives. All interpretation (disable vs override vs style choice) happens at
  # report time, so new analyses never require re-downloading.
  def empty_result
    {
      'has_config' => false, 'inherit_gems' => [], 'requires' => [],
      'allcops' => {}, 'cop_config' => {}, 'dept_config' => {}, 'todo_file' => [],
      'inline_disable' => [], 'inline_todo' => [], 'inline_dept' => []
    }
  end

  def extract_config(root, result)
    main = File.join(root, '.rubocop.yml')
    return unless File.file?(main)

    result['has_config'] = true
    merged = {}
    load_into(main, File.expand_path(root), merged, [])
    reg = registry

    result['inherit_gems'] = merged['inherit_gem'].keys if merged['inherit_gem'].is_a?(Hash)
    result['requires'] = Array(merged['require']).grep(String)
    result['allcops'] = slim(merged['AllCops']) if merged['AllCops'].is_a?(Hash)

    merged.each do |key, val|
      next unless val.is_a?(Hash)

      if reg[:names].include?(key)
        result['cop_config'][key] = slim(val)
      elsif reg[:depts].include?(key)
        result['dept_config'][key] = slim(val)
      end
    end
  rescue Psych::Exception, StandardError
    nil
  end

  # Recursively merge a config and the local files it `inherit_from`s. Earlier
  # (inherited) files are applied first so the current file overrides them - the
  # same precedence RuboCop itself uses. `.rubocop_todo.yml` inherits are skipped
  # here (handled as the todo-backlog signal, not as deliberate config).
  def load_into(path, root, merged, seen)
    return if seen.include?(path) || !File.file?(path)

    seen << path
    data = YAML.load_file(path, **YAML_OPTS)
    return unless data.is_a?(Hash)

    Array(data['inherit_from']).each do |inh|
      next unless inh.is_a?(String)
      next if inh.match?(%r{\A(https?:|/)}) || File.basename(inh).match?(/todo/i)

      child = File.expand_path(File.join(File.dirname(path), inh))
      load_into(child, root, merged, seen) if child.start_with?(root)
    end

    data.each do |k, v|
      merged[k] = merged[k].is_a?(Hash) && v.is_a?(Hash) ? merged[k].merge(v) : v
    end
  rescue Psych::Exception, StandardError
    nil
  end

  # Keep config compact and JSON-safe: trim long arrays and turn non-finite floats
  # (e.g. `Max: .inf`) into strings so they survive serialization.
  def slim(hash)
    hash.transform_values { |v| slim_value(v) }
  end

  def slim_value(val)
    case val
    when Array then val.size <= 20 ? val.map { |e| slim_value(e) } : "[#{val.size} items]"
    when Hash then val.transform_values { |e| slim_value(e) }
    when Float then val.finite? ? val : val.to_s
    else val
    end
  end

  def parse_todo_file(path, result)
    return unless File.file?(path)

    data = YAML.load_file(path, **YAML_OPTS)
    return unless data.is_a?(Hash)

    reg = registry
    result['todo_file'] = data.keys.select { |k| reg[:names].include?(k) }
  rescue Psych::Exception, StandardError
    nil
  end

  def grep_inline(root, result)
    reg = registry
    disable = Set.new
    todo = Set.new
    dept = Set.new

    files(root).each do |file|
      File.foreach(file) do |line|
        next unless line.include?('rubocop:')
        next unless (m = line.match(DIRECTIVE))

        kind = m[1]
        tokens = m[2].split(/[,\s]+/).reject(&:empty?)
        tokens.each do |tok|
          if reg[:names].include?(tok)
            (kind == 'disable' ? disable : todo) << tok
          elsif reg[:depts].include?(tok)
            dept << tok
          end
        end
      end
    rescue ArgumentError, Errno::EISDIR, Errno::ENOENT, IOError
      next # binary / bad-encoding / non-regular file
    end

    result['inline_disable'] = disable.to_a
    result['inline_todo'] = todo.to_a
    result['inline_dept'] = dept.to_a
  end

  def files(root)
    SCAN_GLOBS.flat_map do |glob|
      Dir.glob(File.join(root, '**', glob), File::FNM_CASEFOLD)
    end.select { |p| File.file?(p) }.first(20_000)
  end

  def collect(repos, cache_path)
    cache = File.exist?(cache_path) ? JSON.parse(File.read(cache_path)) : {}
    todo = repos.reject { |r| cache.key?(r['fullName']) }
    warn "Processing #{todo.size} repos (#{cache.size} cached)..."

    Dir.mktmpdir('cop-corpus') do |work|
      todo.each_with_index do |repo, i|
        name = repo['fullName']
        res = begin
          process_repo(name, work)
        rescue StandardError => e
          empty_result.merge('error' => "#{e.class}: #{e.message[0, 80]}")
        end
        res['stars'] = repo['stargazersCount']
        cache[name] = res
        File.write(cache_path, JSON.pretty_generate(cache))
        warn format('[%3d/%-3d] %-45s cfg=%-3s inline=%d%s', i + 1, todo.size, name,
                    res['has_config'], res['inline_disable'].size,
                    res['error'] ? " ERR(#{res['error'][0, 30]})" : '')
      end
    end
    cache
  end

  # --- aggregation + report ----------------------------------------------

  SIGNALS = %w[config_disable config_pending config_exclude todo_file
               inline_disable inline_todo].freeze
  # Params that aren't behavioral config (metadata, or tracked as their own signal).
  META_PARAMS = %w[Enabled Exclude Include Description StyleGuide Reference References
                   VersionAdded VersionChanged VersionRemoved Details inherit_mode
                   Safe SafeAutoCorrect AutoCorrect Severity].to_set.freeze

  def defaults
    @defaults ||= begin
      require 'rubocop'
      RuboCop::ConfigLoader.default_configuration
    end
  end

  def default_param(cop, param)
    cfg = defaults[cop]
    cfg && cfg[param]
  end

  def scalar?(val)
    val.is_a?(Numeric) || val.is_a?(String) || val == true || val == false
  end

  def nested(default) = Hash.new { |h, k| h[k] = Hash.new(default) }

  def aggregate(cache)
    reg = registry
    shared = shared_configs
    repos = cache.values.reject { |r| r['error'] }
    agg = {
      repos: repos.size, with_config: repos.count { |r| r['has_config'] },
      wtotal_config: 0.0, shared: shared,
      tally: nested(0), wtally: nested(0.0),
      param_override: Hash.new(0), param_setters: Hash.new(0),
      param_dist: nested(0), param_wdist: nested(0.0),
      gems: Hash.new(0), requires: Hash.new(0),
      target_ruby: Hash.new(0), newcops: Hash.new(0), disabled_by_default: 0
    }

    repos.each { |r| fold_repo(r, agg, reg, shared) }
    agg
  end

  # Per-repo effective config = inherited shared-gem configs (applied first) with
  # the repo's own local config layered on top.
  def effective_config(r, shared)
    cop = {}
    dept = {}
    (r['inherit_gems'] || []).each do |gem|
      next unless (sc = shared[gem])

      (sc['cop_config'] || {}).each { |k, v| cop[k] = (cop[k] || {}).merge(v) }
      (sc['dept_config'] || {}).each { |k, v| dept[k] = (dept[k] || {}).merge(v) }
    end
    (r['cop_config'] || {}).each { |k, v| cop[k] = (cop[k] || {}).merge(v) }
    (r['dept_config'] || {}).each { |k, v| dept[k] = (dept[k] || {}).merge(v) }
    [cop, dept]
  end

  def bump(agg, cop, sig, w)
    agg[:tally][cop][sig] += 1
    agg[:wtally][cop][sig] += w
  end

  def fold_repo(r, agg, reg, shared)
    w = weight(r['stars'])
    agg[:wtotal_config] += w if r['has_config']
    eff_cop, eff_dept = effective_config(r, shared)

    eff_cop.each do |cop, params|
      en = params['Enabled']
      bump(agg, cop, 'config_disable', w) if en == false
      bump(agg, cop, 'config_pending', w) if en == 'pending'
      bump(agg, cop, 'config_exclude', w) if params.key?('Exclude')
      params.each { |pk, pv| fold_param(cop, pk, pv, agg, w) }
    end
    eff_dept.each do |dept, params|
      sig = dept_disable_signal(params)
      (reg[:dept_cops][dept] || []).each { |c| bump(agg, c, sig, w) } if sig
    end
    %w[todo_file inline_disable inline_todo].each do |sig|
      (r[sig] || []).each { |c| bump(agg, c, sig, w) }
    end
    (r['inline_dept'] || []).each do |dept|
      (reg[:dept_cops][dept] || []).each { |c| bump(agg, c, 'inline_disable', w) }
    end
    fold_meta(r, agg)
  end

  def dept_disable_signal(params)
    return 'config_disable' if params['Enabled'] == false
    return 'config_pending' if params['Enabled'] == 'pending'
  end

  def fold_param(cop, pk, pv, agg, w)
    return if META_PARAMS.include?(pk)

    key = "#{cop}|#{pk}"
    agg[:param_setters][key] += 1
    if scalar?(pv)
      agg[:param_dist][key][pv.to_s] += 1
      agg[:param_wdist][key][pv.to_s] += w
    end
    default = default_param(cop, pk)
    agg[:param_override][key] += 1 unless default.nil? ? false : pv == default
  end

  def fold_meta(r, agg)
    (r['inherit_gems'] || []).each { |g| agg[:gems][g] += 1 }
    (r['requires'] || []).each { |q| agg[:requires][q] += 1 }
    ac = r['allcops'] || {}
    agg[:target_ruby][ac['TargetRubyVersion'].to_s] += 1 if ac['TargetRubyVersion']
    agg[:newcops][ac['NewCops'].to_s] += 1 if ac['NewCops']
    agg[:disabled_by_default] += 1 if ac['DisabledByDefault'] == true
  end

  def search_inline_counts
    path = 'tmp/cop-disable-stats.json'
    return {} unless File.exist?(path)

    JSON.parse(File.read(path)).each_with_object({}) do |(k, v), h|
      cop, pat = k.split('|')
      h[cop] = v if pat == 'disable'
    end
  end

  def rows(agg)
    search = search_inline_counts
    agg[:tally].map do |cop, sigs|
      counts = SIGNALS.to_h { |s| [s.to_sym, sigs[s] || 0] }
      { cop: cop, dept: cop.split('/').first, **counts, gh_inline: search[cop],
        off_score: counts[:config_disable] + counts[:inline_disable] }
    end.sort_by { |r| -r[:off_score] }
  end

  def report(agg)
    ranked = rows(agg)
    n = agg[:repos]
    cfg = agg[:with_config]
    out = +"# What the Ruby community actually does with RuboCop\n\n"
    out << "Fork-free corpus of the **#{n} most-starred Ruby repos** on GitHub "
    out << "(**#{cfg}** ship a `.rubocop.yml`; percentages below are over those #{cfg} "
    out << "unless noted). Defaults are compared against this RuboCop checkout's "
    out << "`config/default.yml`; inherited shared configs are resolved and counted; "
    out << "repo votes are also shown **star-weighted**. Generated by "
    out << "`tools/cop_usage_corpus.rb`.\n\n"
    out << how_to_read
    out << recommendations_section(agg)
    out << adoption_section(agg)
    out << shared_config_section(agg)
    out << allcops_section(agg)
    out << leaderboard('Most globally disabled (`Enabled: false`)', ranked, :config_disable, cfg, 'of configs', agg)
    out << leaderboard('Most inline-suppressed (`# rubocop:disable`)', ranked, :inline_disable, n, 'of repos')
    out << leaderboard('Most excluded (`Exclude:`)', ranked, :config_exclude, cfg, 'of configs')
    out << leaderboard('Biggest `.rubocop_todo.yml` backlogs', ranked, :todo_file, cfg, 'of configs')
    out << pending_section(ranked, cfg)
    out << overridden_params_section(agg, cfg)
    out << thresholds_section(agg)
    out << styles_section(agg)
    out << full_table(ranked)
    out
  end

  def how_to_read
    <<~MD
      ## How to read this (important)

      A parameter is counted only when a repo **explicitly sets it**, and setting a
      value almost always means *disagreeing with the default* - repos that are happy
      with a default simply stay silent. So these distributions show the **direction
      and strength of divergence among opinionated projects**, not a majority vote of
      all projects. Two consequences:

      - **Thresholds (`Max`)** are the strongest signal: overrides are nearly always in
        one direction (people *raise* limits, never lower them), so when the median
        override sits well above the default, the default is stricter than real-world
        tolerance.
      - **Styles** show *which* alternative opinionated teams prefer, but a default can
        still be the silent-majority choice even when most *setters* diverge. The
        "setters (% of cfgs)" column is exactly this: how much of the population
        bothered to express a preference at all.

      Repos that `inherit_gem` a shared base config (e.g. `rubocop-rails-omakase`,
      `standard`) have that gem's config fetched and merged in, so their **effective**
      (inherited + local) settings are counted - see "What the popular shared base
      configs do". A handful of rarely-used inherited gems can't be fetched and stay
      local-only. Votes are also reported **star-weighted** (`wt`), so a 50k-star
      project counts more than a 100-star one.

    MD
  end

  # Auto-derived "defaults worth revisiting" from the corpus.
  def recommendations_section(agg)
    out = +"## Candidate default changes (auto-derived)\n\n"
    out << threshold_candidates(agg)
    out << style_candidates(agg)
  end

  def threshold_candidates(agg)
    cands = agg[:param_dist].filter_map do |key, dist|
      next unless key.end_with?('|Max')

      cop = key.split('|').first
      d = default_param(cop, 'Max')
      s = numeric_summary(dist)
      next unless s && s[:n] >= 8 && d.is_a?(Numeric) && s[:median] > d

      [cop, d, s[:median], s[:plurality], numeric_plurality(agg[:param_wdist][key]), s[:n]]
    end.sort_by { |r| -r[5] }

    return "**Thresholds:** _no `Max` with n>=8 sits above its default._\n\n" if cands.empty?

    out = +"**Thresholds likely too strict** (community median > default, n>=8):\n\n"
    out << "| Cop | Default | Median override | Plurality | Star-wtd plurality | n |\n"
    out << "|---|--:|--:|--:|--:|--:|\n"
    cands.each do |cop, d, med, plur, wplur, n|
      out << "| `#{cop}` | #{d} | **#{med}** | #{plur} | #{wplur || '-'} | #{n} |\n"
    end
    out << "\n"
  end

  def style_candidates(agg)
    denom = agg[:with_config]
    cands = agg[:param_dist].filter_map do |key, dist|
      cop, param = key.split('|')
      next unless param.start_with?('Enforced')

      n = dist.values.sum
      next if n < 8

      d = default_param(cop, param).to_s
      top, tc = dist.max_by { |_, c| c }
      next if top == d || tc.to_f / n < 0.6

      wtop = agg[:param_wdist][key].max_by { |_, c| c }&.first
      [cop, param, d, top, (100.0 * tc / n).round, n,
       denom.positive? ? (100.0 * n / denom).round : 0, wtop]
    end.sort_by { |r| -r[5] }

    return "**Styles:** _no EnforcedStyle has a >=60% non-default consensus at n>=8._\n\n" if cands.empty?

    out = +"**Styles with a strong non-default consensus** (>=60% of setters agree, n>=8):\n\n"
    out << "| Cop / param | Default | Community pick | Share of setters | Setters (% of cfgs) | Star-wtd pick |\n"
    out << "|---|---|---|--:|--:|---|\n"
    cands.each do |cop, param, d, top, pct, n, setters_pct, wtop|
      wmark = wtop == top ? '' : " ⚠️`#{wtop}`"
      out << "| `#{cop}` `#{param}` | `#{d}` | **`#{top}`** | #{pct}% (n=#{n}) | #{setters_pct}% | `#{top}`#{wmark} |\n"
    end
    out << "\n_\"Setters (% of cfgs)\" = share of all configs that set this param at all; "
    out << "a small number means most projects silently keep the default. Star-wtd pick "
    out << "flags (⚠️) when weighting by repo popularity changes the winner._\n\n"
  end

  def shared_config_section(agg)
    shared = (agg[:shared] || {}).reject { |_, v| v.nil? }
    return '' if shared.empty?

    out = +"## What the popular shared base configs do\n\n"
    out << "Community-curated default-sets that repos adopt wholesale via `inherit_gem` - "
    out << "effectively votes for *alternative defaults*. (Now folded into the counts above.)\n\n"
    out << "| Base config | Cops disabled | Notable settings |\n|---|--:|---|\n"
    shared.sort_by { |g, _| g }.each do |gem, cfg|
      cc = cfg['cop_config'] || {}
      off = cc.count { |_, p| p['Enabled'] == false }
      dept_off = (cfg['dept_config'] || {}).count { |_, p| p['Enabled'] == false }
      label = dept_off.positive? ? "#{off} (+#{dept_off} depts)" : off.to_s
      out << "| `#{gem}` | #{label} | #{notable_settings(cc)} |\n"
    end
    out << "\n"
  end

  def notable_settings(cop_config)
    [['Style/StringLiterals', 'EnforcedStyle', 'strings'],
     ['Layout/LineLength', 'Max', 'line'],
     ['Metrics/MethodLength', 'Max', 'method-len'],
     ['Style/FrozenStringLiteralComment', 'EnforcedStyle', 'frozen']].filter_map do |cop, param, label|
      v = cop_config.dig(cop, param)
      "#{label}: #{v}" if v
    end.join('; ')
  end

  def adoption_section(agg)
    out = +"## Shared configs & extensions adopted\n\n"
    out << "Whose defaults teams buy into. `inherit_gem` pulls in a base style "
    out << "config; `require` loads an extension cop set (local paths filtered out).\n\n"

    out << "**Inherited base configs (`inherit_gem`):**\n\n| Gem | Repos |\n|---|--:|\n"
    agg[:gems].sort_by { |_, c| -c }.first(12).each { |g, c| out << "| `#{g}` | #{c} |\n" }

    plugins = agg[:requires].reject { |q, _| q.include?('/') || q.start_with?('.') || q.end_with?('.rb') }
    out << "\n**Extension cop plugins (`require`):**\n\n| Plugin | Repos |\n|---|--:|\n"
    plugins.sort_by { |_, c| -c }.first(12).each { |g, c| out << "| `#{g}` | #{c} |\n" }
    out << "\n"
  end

  def allcops_section(agg)
    out = +"## `AllCops` trends\n\n"
    out << "**`TargetRubyVersion`:** "
    out << agg[:target_ruby].sort_by { |k, _| k }.map { |v, c| "`#{v}`: #{c}" }.join(', ')
    out << "\n\n**`NewCops`:** "
    out << (agg[:newcops].empty? ? '_unset everywhere_' : agg[:newcops].sort_by { |_, c| -c }.map { |v, c| "`#{v}`: #{c}" }.join(', '))
    out << "\n\n**`DisabledByDefault: true`:** #{agg[:disabled_by_default]} repos\n\n"
  end

  def leaderboard(title, ranked, key, denom, denom_label, agg = nil)
    top = ranked.select { |r| r[key].positive? }.sort_by { |r| -r[key] }.first(15)
    return +"## #{title}\n\n_None found in this corpus._\n\n" if top.empty?

    wcol = agg && agg[:wtotal_config].positive?
    out = +"## #{title}\n\n| # | Cop | Repos | % #{denom_label}#{wcol ? ' | star-wtd %' : ''} |\n"
    out << "|--:|---|--:|--:#{wcol ? '|--:' : ''}|\n"
    top.each_with_index do |r, i|
      pct = denom.positive? ? (100.0 * r[key] / denom).round(1) : 0
      wcell = wcol ? " | #{(100.0 * agg[:wtally][r[:cop]][key.to_s] / agg[:wtotal_config]).round(1)}%" : ''
      out << "| #{i + 1} | `#{r[:cop]}` | #{r[key]} | #{pct}%#{wcell} |\n"
    end
    out << "\n"
  end

  def pending_section(ranked, denom)
    pend = ranked.select { |r| r[:config_pending].positive? }
                 .sort_by { |r| -r[:config_pending] }.first(12)
    return +"## Cops most often left `pending`\n\n_None found._\n\n" if pend.empty?

    out = +"## Cops most often left `pending`\n\n| Cop | Repos | % of configs |\n|---|--:|--:|\n"
    pend.each do |r|
      pct = denom.positive? ? (100.0 * r[:config_pending] / denom).round(1) : 0
      out << "| `#{r[:cop]}` | #{r[:config_pending]} | #{pct}% |\n"
    end
    out << "\n"
  end

  # The headline section for "should we change a default": parameters the most
  # repos set to something *other than* the shipped default.
  def overridden_params_section(agg, denom)
    top = agg[:param_override].reject { |_, c| c.zero? }.sort_by { |_, c| -c }.first(25)
    out = +"## Most-overridden parameters (set to a non-default value)\n\n"
    out << "| Cop / param | Repos | % of configs | Default |\n|---|--:|--:|---|\n"
    top.each do |key, c|
      cop, param = key.split('|')
      pct = denom.positive? ? (100.0 * c / denom).round(1) : 0
      out << "| `#{cop}` `#{param}` | #{c} | #{pct}% | `#{default_param(cop, param).inspect}` |\n"
    end
    out << "\n"
  end

  # Numeric threshold cops (Metrics + LineLength): show the distribution of chosen
  # `Max` values vs the default, with median/plurality, so defaults can be retuned.
  def thresholds_section(agg)
    out = +"## Threshold (`Max`) distributions vs default\n\n"
    out << "Where the community median/plurality diverges from the default, that's a "
    out << "candidate to retune. `n` = repos that set a numeric `Max`.\n\n"
    out << "| Cop | Default | Median | Plurality | n | Distribution |\n|---|--:|--:|--:|--:|---|\n"
    agg[:param_dist].select { |k, _| k.end_with?('|Max') }.sort_by { |_, d| -d.values.sum }.each do |key, dist|
      cop = key.split('|').first
      summ = numeric_summary(dist)
      next unless summ

      out << "| `#{cop}` | #{default_param(cop, 'Max').inspect} | #{summ[:median]} | "
      out << "#{summ[:plurality]} | #{summ[:n]} | #{dist_line(dist, default_param(cop, 'Max'))} |\n"
    end
    out << "\n"
  end

  # EnforcedStyle (and any Enforced* param) choices vs the default.
  def styles_section(agg)
    keys = agg[:param_dist].keys.select { |k| k.split('|').last.start_with?('Enforced') }
    return +"## EnforcedStyle choices\n\n_None set in this corpus._\n\n" if keys.empty?

    out = +"## `EnforcedStyle` choices vs default\n\n"
    out << "Rows where the community plurality is **not** the default are the headline "
    out << "candidates for changing the shipped style.\n\n"
    denom = agg[:with_config]
    out << "| Cop / param | Default | Plurality | n | setters %cfg | Distribution |\n"
    out << "|---|---|---|--:|--:|---|\n"
    keys.sort_by { |k| -agg[:param_dist][k].values.sum }.first(25).each do |key|
      cop, param = key.split('|')
      dist = agg[:param_dist][key]
      default = default_param(cop, param)
      plurality = dist.max_by { |_, c| c }&.first
      flag = plurality && plurality != default.to_s ? ' **!**' : ''
      setters_pct = denom.positive? ? (100.0 * dist.values.sum / denom).round : 0
      out << "| `#{cop}` `#{param}`#{flag} | `#{default}` | `#{plurality}` | "
      out << "#{dist.values.sum} | #{setters_pct}% | #{dist_line(dist, default)} |\n"
    end
    out << "\n_Rows flagged **!** = community plurality differs from the default. "
    out << "`setters %cfg` = share of all configs that set this param (low = most keep the default)._\n\n"
  end

  def numeric_plurality(dist)
    best = dist.filter_map { |v, c| Float(v, exception: false) && [v, c] }.max_by { |_, c| c }
    best && fmt_num(Float(best.first))
  end

  def numeric_summary(dist)
    pairs = dist.filter_map { |v, c| (n = Float(v, exception: false)) && [n, c] }
    return nil if pairs.empty?

    expanded = pairs.flat_map { |v, c| Array.new(c, v) }.sort
    { plurality: fmt_num(pairs.max_by { |_, c| c }.first),
      median: fmt_num(expanded[expanded.size / 2]), n: pairs.sum { |_, c| c } }
  end

  def fmt_num(float)
    float == float.to_i ? float.to_i : float
  end

  def dist_line(dist, default)
    dist.sort_by { |v, _| Float(v, exception: false) || Float::INFINITY }.map do |val, c|
      mark = val == default.to_s ? '*' : ''
      "#{val}#{mark}:#{c}"
    end.first(12).join(', ').then { |s| "#{s} _(* = default)_" }
  end

  def full_table(ranked)
    out = +"## Full ranking (config-disable + inline-disable)\n\n"
    out << "| Cop | cfg_off | pending | exclude | todo | inline | gh_inline |\n"
    out << "|---|--:|--:|--:|--:|--:|--:|\n"
    ranked.first(60).each do |r|
      out << "| `#{r[:cop]}` | #{r[:config_disable]} | #{r[:config_pending]} | "
      out << "#{r[:config_exclude]} | #{r[:todo_file]} | #{r[:inline_disable]} | #{r[:gh_inline] || '-'} |\n"
    end
    out << "\n_Full per-cop data: `tmp/cop-corpus-stats.csv`._\n"
  end

  def csv(agg)
    head = ['cop', 'department', *SIGNALS, 'gh_inline']
    lines = [head.join(',')]
    rows(agg).each do |r|
      lines << [r[:cop], r[:dept], *SIGNALS.map { |s| r[s.to_sym] }, r[:gh_inline]].join(',')
    end
    lines.join("\n") << "\n"
  end

  def run(argv)
    opts = { repos: 200, cache: 'tmp/cop-corpus-cache.json',
             report: 'tmp/cop-corpus-report.md', csv: 'tmp/cop-corpus-stats.csv',
             report_only: false }
    OptionParser.new do |o|
      o.on('--repos N', Integer) { |v| opts[:repos] = v }
      o.on('--cache FILE') { |v| opts[:cache] = v }
      o.on('--report FILE') { |v| opts[:report] = v }
      o.on('--csv FILE') { |v| opts[:csv] = v }
      o.on('--report-only') { opts[:report_only] = true }
    end.parse!(argv)

    require 'set'
    require 'tmpdir'
    registry # fail fast if rubocop can't load

    unless opts[:report_only]
      repos = top_ruby_repos(opts[:repos])
      collect(repos, opts[:cache])
    end

    cache = JSON.parse(File.read(opts[:cache]))
    agg = aggregate(cache)
    File.write(opts[:report], report(agg))
    File.write(opts[:csv], csv(agg))
    warn "Wrote #{opts[:report]} and #{opts[:csv]} (#{agg[:repos]} repos, #{agg[:with_config]} with config)."
  end
end

CopUsageCorpus.run(ARGV) if $PROGRAM_NAME == __FILE__
