# frozen_string_literal: true

def commit_paths(commit_range)
  commit_range = "#{commit_range}~..HEAD" if commit_range.include?('..')
  `git diff-tree --no-commit-id --name-only -r #{commit_range}`.split("\n")
ensure
  exit($CHILD_STATUS.exitstatus) if $CHILD_STATUS.exitstatus != 0
end

desc 'Check files modified in commit (default: HEAD) with rspec and rubocop'
RuboCop::RakeTask.new(:check_commit, :commit) do |t, args|
  commit = args[:commit] || 'HEAD'
  paths = commit_paths(commit)
  paths.reject { |p| p.start_with?(/docs|Gemfile|README|CHANGELOG/) }
  specs = paths.select { |p| p.start_with?('spec') }

  if specs.empty?
    puts 'Caution: No spec was changed!'
  else
    puts "Checking: #{paths.join(' ')}"
    RuboCop::SpecRunner.new(specs, parallel: false).run_specs
  end

  t.patterns = paths
end
