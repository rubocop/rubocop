# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rubocop/version'
require 'English'

Gem::Specification.new do |s|
  s.name = 'rubocop'
  s.version = RuboCop::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.2'
  s.authors = ['Bozhidar Batsov', 'Jonas Arvidsson', 'Yuji Nakayama']
  s.description = <<-DESCRIPTION
    Automatic Ruby code style checking tool.
    Aims to enforce the community-driven Ruby Style Guide.
  DESCRIPTION

  s.email = 'rubocop@googlegroups.com'
  s.files = `git ls-files assets bin config lib LICENSE.txt README.md`
            .split($RS)
  s.bindir = 'exe'
  s.executables = ['rubocop']
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.homepage = 'https://github.com/rubocop-hq/rubocop'
  s.licenses = ['MIT']
  s.summary = 'Automatic Ruby code style checking tool.'

  s.metadata = {
    'homepage_uri' => 'https://www.rubocop.org/',
    'changelog_uri' => 'https://github.com/rubocop-hq/rubocop/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/rubocop-hq/rubocop/',
    'documentation_uri' => 'https://docs.rubocop.org/',
    'bug_tracker_uri' => 'https://github.com/rubocop-hq/rubocop/issues'
  }

  s.add_runtime_dependency('jaro_winkler', '~> 1.5.1')
  s.add_runtime_dependency('parallel', '~> 1.10')
  s.add_runtime_dependency('parser', '>= 2.5', '!= 2.5.1.1')
  s.add_runtime_dependency('psych', '>= 3.1.0')
  s.add_runtime_dependency('rainbow', '>= 2.2.2', '< 4.0')
  s.add_runtime_dependency('ruby-progressbar', '~> 1.7')
  s.add_runtime_dependency('unicode-display_width', '>= 1.4.0', '< 1.6')

  s.add_development_dependency('bundler', '>= 1.3.0', '< 3.0')
  s.add_development_dependency('rack', '>= 2.0')

  s.post_install_message = File.read('manual/migrate_performance_cops.md')
end
