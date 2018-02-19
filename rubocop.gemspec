# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rubocop/version'
require 'English'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |s|
  s.name = 'rubocop'
  s.version = RuboCop::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.1.0'
  s.authors = ['Bozhidar Batsov', 'Jonas Arvidsson', 'Yuji Nakayama']
  s.description = <<-DESCRIPTION
    Automatic Ruby code style checking tool.
    Aims to enforce the community-driven Ruby Style Guide.
  DESCRIPTION

  s.email = 'rubocop@googlegroups.com'
  s.files = `git ls-files assets bin config lib LICENSE.txt README.md \
             spec/support/cop_helper.rb`
            .split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.homepage = 'https://github.com/bbatsov/rubocop'
  s.licenses = ['MIT']
  s.summary = 'Automatic Ruby code style checking tool.'

  if s.respond_to?(:metadata=)
    s.metadata = {
      'homepage_uri' => 'https://rubocop.readthedocs.io/',
      'changelog_uri' => 'https://github.com/bbatsov/rubocop/blob/master/CHANGELOG.md',
      'source_code_uri' => 'https://github.com/bbatsov/rubocop/',
      'documentation_uri' => 'https://rubocop.readthedocs.io/',
      'bug_tracker_uri' => 'https://github.com/bbatsov/rubocop/issues'
    }
  end

  s.add_runtime_dependency('parallel', '~> 1.10')
  s.add_runtime_dependency('parser', '>= 2.4.0.2', '< 2.5')
  s.add_runtime_dependency('powerpack', '~> 0.1')
  s.add_runtime_dependency('rainbow', '>= 2.2.2', '< 4.0')
  s.add_runtime_dependency('ruby-progressbar', '~> 1.7')
  s.add_runtime_dependency('unicode-display_width', '~> 1.0', '>= 1.0.1')

  s.add_development_dependency('bundler', '~> 1.3')
end
# rubocop:enable Metrics/BlockLength
