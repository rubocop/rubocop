# frozen_string_literal: true

desc 'Run codespell if available'
task :codespell do |_task|
  next if Gem.win_platform?
  next if ENV['CI'] # CI has its own workflow for this

  sh 'which codespell', verbose: false, out: File::NULL, err: File::NULL do |ok, _res|
    if ok
      sh 'git ls-files --empty-directory | xargs codespell'
    else
      puts 'Skipping `codespell` since it is not installed'
    end
  end
end
