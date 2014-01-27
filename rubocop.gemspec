# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rubocop/version'
require 'English'

Gem::Specification.new do |s|
  s.name = 'rubocop'
  s.version = Rubocop::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
  s.authors = ['Bozhidar Batsov']
  s.description = <<-EOF
    Automatic Ruby code style checking tool.
    Aims to enforce the community-driven Ruby Style Guide.
  EOF

  s.email = 'bozhidar@batsov.com'
  s.files = `git ls-files`.split($RS)
  s.test_files = s.files.grep(/^spec\//)
  s.executables = s.files.grep(/^bin\//) { |f| File.basename(f) }
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.homepage = 'http://github.com/bbatsov/rubocop'
  s.licenses = ['MIT']
  s.require_paths = ['lib']
  s.rubygems_version = '1.8.23'
  s.summary = 'Automatic Ruby code style checking tool.'

  s.add_runtime_dependency('rainbow', '>= 1.99.1', '< 3.0')
  s.add_runtime_dependency('parser', '~> 2.1.3')
  s.add_runtime_dependency('powerpack', '~> 0.0.6')
  s.add_runtime_dependency('json', '>= 1.7.7', '< 2')
  s.add_development_dependency('rake', '~> 10.1')
  s.add_development_dependency('rspec', '~> 2.14')
  s.add_development_dependency('yard', '~> 0.8')
  s.add_development_dependency('bundler', '~> 1.3')
  s.add_development_dependency('simplecov', '~> 0.7')
end
