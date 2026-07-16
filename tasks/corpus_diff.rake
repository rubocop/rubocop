# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open3'
require 'tmpdir'

# Differential testing for cop changes: runs the working tree and a base
# revision over a corpus of real-world Ruby files and reports every
# difference in offenses and autocorrected output, plus any corrected file
# that no longer parses.
#
# Unit specs prove a change didn't break the known past; this catches the
# silent present - offenses that quietly appear or disappear, and
# corrections that change, on code nobody thought to write a spec for.
#
#   bundle exec rake 'corpus_diff[Style/RedundantParentheses]'
#   bundle exec rake 'corpus_diff[Style/A;Style/B,v1.81.0,/path/to/corpus]'
#
# Multiple cops are separated with `;`. The corpus defaults to the Ruby
# files of the installed gems (capped at CORPUS_LIMIT, default 500); pass a
# directory, or set CORPUS_LIMIT to change the cap.
class CorpusDiff
  LIMIT = Integer(ENV.fetch('CORPUS_LIMIT', 500))

  # Bundler-free invocation with a scrubbed environment: the outer `bundle
  # exec rake` exports RUBYOPT/BUNDLE_* which would load the working tree's
  # rubocop alongside the baseline's, silently mixing the two versions.
  CLEAN_ENV = { 'RUBYOPT' => nil, 'BUNDLE_GEMFILE' => nil, 'BUNDLE_BIN_PATH' => nil,
                'RUBYLIB' => nil }.freeze

  def initialize(cops, base_rev, corpus)
    @cops = cops
    @base_rev = base_rev
    @repo_root = File.expand_path('..', __dir__)
    @corpus_files = corpus_files(corpus)
  end

  def run
    puts "Corpus: #{@corpus_files.size} files; comparing #{@base_rev} -> working tree " \
         "for #{@cops ? @cops.join(', ') : 'the default configuration'}"

    Dir.mktmpdir('corpus_diff') do |tmp|
      stage_corpus(tmp)
      base = in_baseline_worktree(tmp) { |lib| inspect_and_correct(tmp, 'base', lib) }
      head = inspect_and_correct(tmp, 'head', File.join(@repo_root, 'lib'))

      report(base, head, tmp)
    end
  end

  private

  def corpus_files(corpus)
    root = corpus || Gem.dir
    files = Dir.glob(File.join(root, '**', '*.rb')).reject { |f| f.include?('/spec/fixtures/') }
    raise "no Ruby files found under #{root}" if files.empty?

    files.first(LIMIT)
  end

  def stage_corpus(tmp)
    @manifest = {}
    corpus_dir = File.join(tmp, 'corpus')
    FileUtils.mkdir_p(corpus_dir)
    @corpus_files.each_with_index do |file, index|
      staged = format('f%05d.rb', index)
      @manifest[staged] = file
      FileUtils.cp(file, File.join(corpus_dir, staged))
    end
  end

  def in_baseline_worktree(tmp)
    worktree = File.join(tmp, 'baseline')
    system('git', 'worktree', 'add', '--quiet', '--detach', worktree, @base_rev,
           chdir: @repo_root, exception: true)
    yield File.join(worktree, 'lib')
  ensure
    system('git', 'worktree', 'remove', '--force', worktree, chdir: @repo_root, exception: false)
  end

  # Returns { offenses: Set[String], corrected: { staged_name => content },
  # invalid: [staged_name] } for a run with the given rubocop `lib` dir.
  def inspect_and_correct(tmp, label, lib)
    run_dir = File.join(tmp, label)
    FileUtils.cp_r(File.join(tmp, 'corpus'), run_dir)

    offenses = collect_offenses(lib, run_dir)
    rubocop(lib, run_dir, '--autocorrect-all', '--format', 'quiet')

    corrected = Dir.glob(File.join(run_dir, '*.rb')).to_h { |f| [File.basename(f), File.read(f)] }

    { offenses: offenses, corrected: corrected,
      invalid: corrected.reject { |_, content| syntax_ok?(content) }.keys }
  end

  def collect_offenses(lib, run_dir)
    json_path = File.join(run_dir, 'offenses.json')
    rubocop(lib, run_dir, '--format', 'json', '--out', json_path)
    offense_set(File.read(json_path))
  ensure
    FileUtils.rm_f(json_path)
  end

  def rubocop(lib, dir, *args)
    exe = File.expand_path('../exe/rubocop', lib)
    cop_args = @cops ? ['--only', @cops.join(',')] : []
    Open3.capture3(
      CLEAN_ENV, RbConfig.ruby, "-I#{lib}", exe,
      '--force-default-config', '--cache', 'false', *cop_args, *args, dir,
      chdir: @repo_root
    )
  end

  def offense_set(json_output)
    data = JSON.parse(json_output)
    data.fetch('files').flat_map do |file|
      staged = File.basename(file.fetch('path'))
      file.fetch('offenses').map do |offense|
        location = offense.fetch('location')
        "#{staged}:#{location['start_line']}:#{location['start_column']} " \
          "#{offense['cop_name']}: #{offense['message']}"
      end
    end.to_set
  end

  def syntax_ok?(content)
    _out, _err, status = Open3.capture3('ruby', '-c', stdin_data: content)
    status.success?
  end

  def report(base, head, _tmp)
    report_offense_diff(base, head)
    report_correction_diff(base, head)
    report_invalid(base, 'base')
    report_invalid(head, 'working tree')
  end

  def report_offense_diff(base, head)
    gained = (head[:offenses] - base[:offenses]).sort
    lost = (base[:offenses] - head[:offenses]).sort

    puts offense_summary(base[:offenses], head[:offenses], gained, lost)
    print_named_list('New offenses (working tree only)', gained)
    print_named_list('Lost offenses (base only)', lost)
  end

  def offense_summary(base, head, gained, lost)
    "\nOffenses: #{base.size} base, #{head.size} working tree (+#{gained.size} / -#{lost.size})"
  end

  def report_correction_diff(base, head)
    differing = head[:corrected].keys.reject do |staged|
      head[:corrected][staged] == base[:corrected][staged]
    end

    puts "\nAutocorrected output differs for #{differing.size} file(s)"
    print_named_list('Files corrected differently', differing)
  end

  def report_invalid(result, label)
    return if result[:invalid].empty?

    print_named_list("!!! Corrections producing INVALID Ruby (#{label})", result[:invalid])
  end

  def print_named_list(title, entries, cap: 25)
    return if entries.empty?

    puts "#{title}:"
    entries.first(cap).each { |entry| puts "  #{resolve(entry)}" }
    puts "  ... and #{entries.size - cap} more" if entries.size > cap
  end

  def resolve(entry)
    staged = entry[/\Af\d{5}\.rb/]
    staged ? entry.sub(staged, @manifest.fetch(staged, staged)) : entry
  end
end

desc 'Diff offenses and autocorrections vs a base revision over a corpus of real-world code'
task :corpus_diff, [:cops, :base_rev, :corpus] do |_task, args|
  cops = args[:cops]&.split(';')&.map(&:strip)
  base_rev = args[:base_rev] || 'origin/master'

  CorpusDiff.new(cops, base_rev, args[:corpus]).run
end
