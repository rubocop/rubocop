# frozen_string_literal: true

require_relative 'lib/rubocop/version'

Gem::Specification.new do |s|
  s.name = 'rubocop'
  s.version = RuboCop::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.6.0'
  s.authors = ['Bozhidar Batsov', 'Jonas Arvidsson', 'Yuji Nakayama']
  s.description = <<-DESCRIPTION
    RuboCop is a Ruby code style checking and code formatting tool.
    It aims to enforce the community-driven Ruby Style Guide.
  DESCRIPTION

  s.email = 'rubocop@googlegroups.com'
  s.files = Dir.glob('{assets,config,lib}/**/*', File::FNM_DOTMATCH)
  s.bindir = 'exe'
  s.executables = ['rubocop']
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.homepage = 'https://github.com/rubocop/rubocop'
  s.licenses = ['MIT']
  s.summary = 'Automatic Ruby code style checking tool.'

  s.metadata = {
    'homepage_uri' => 'https://rubocop.org/',
    'changelog_uri' => 'https://github.com/rubocop/rubocop/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/rubocop/rubocop/',
    'documentation_uri' => "https://docs.rubocop.org/rubocop/#{RuboCop::Version.document_version}/",
    'bug_tracker_uri' => 'https://github.com/rubocop/rubocop/issues',
    'rubygems_mfa_required' => 'true'
  }

  s.add_runtime_dependency('json', '~> 2.3')
  s.add_runtime_dependency('parallel', '~> 1.10')
  s.add_runtime_dependency('parser', '>= 3.1.2.1')
  s.add_runtime_dependency('rainbow', '>= 2.2.2', '< 4.0')
  s.add_runtime_dependency('regexp_parser', '>= 1.8', '< 3.0')
  s.add_runtime_dependency('rexml', '>= 3.2.5', '< 4.0')
  s.add_runtime_dependency('rubocop-ast', '>= 1.23.0', '< 2.0')
  s.add_runtime_dependency('ruby-progressbar', '~> 1.7')
  s.add_runtime_dependency('unicode-display_width', '>= 1.4.0', '< 3.0')

  s.add_development_dependency('bundler', '>= 1.15.0', '< 3.0')
end
