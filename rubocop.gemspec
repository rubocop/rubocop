# frozen_string_literal: true

require_relative 'lib/rubocop/version'

Gem::Specification.new do |s|
  s.name = 'rubocop'
  s.version = RuboCop::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.7.0'
  s.authors = ['Bozhidar Batsov', 'Jonas Arvidsson', 'Yuji Nakayama']
  s.description = <<~DESCRIPTION
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
    'changelog_uri' => "https://github.com/rubocop/rubocop/releases/tag/v#{RuboCop::Version::STRING}",
    'source_code_uri' => 'https://github.com/rubocop/rubocop/',
    'documentation_uri' => "https://docs.rubocop.org/rubocop/#{RuboCop::Version.document_version}/",
    'bug_tracker_uri' => 'https://github.com/rubocop/rubocop/issues',
    'rubygems_mfa_required' => 'true'
  }

  s.add_dependency('json', '~> 2.3')
  # NOTE: language_server-protocol gem doesn't use semantic versioning. Its versions follow x.y.z.t,
  # where x.y.z indicates the Language Server Protocol Specification, t is an incrementing number.
  s.add_dependency('language_server-protocol', '~> 3.17.0.2')
  s.add_dependency('lint_roller', '~> 1.1.0')
  s.add_dependency('parallel', '~> 1.10')
  s.add_dependency('parser', '>= 3.3.0.2')
  s.add_dependency('rainbow', '>= 2.2.2', '< 4.0')
  s.add_dependency('regexp_parser', '>= 2.9.3', '< 3.0')
  s.add_dependency('rubocop-ast', '>= 1.46.0', '< 2.0')
  s.add_dependency('ruby-progressbar', '~> 1.7')
  s.add_dependency('unicode-display_width', '>= 2.4.0', '< 4.0')
end
