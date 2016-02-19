# encoding: utf-8
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rubocop/version'
require 'English'

Gem::Specification.new do |s|
  s.name = 'rubocop'
  s.version = RuboCop::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.3'
  s.authors = ['Bozhidar Batsov', 'Jonas Arvidsson', 'Yuji Nakayama']
  s.description = <<-EOF
    Automatic Ruby code style checking tool.
    Aims to enforce the community-driven Ruby Style Guide.
  EOF

  s.email = 'rubocop@googlegroups.com'
  s.files = `git ls-files assets bin config lib LICENSE.txt README.md \
             spec/support/cop_helper.rb`
            .split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.homepage = 'http://github.com/bbatsov/rubocop'
  s.licenses = ['MIT']
  s.summary = 'Automatic Ruby code style checking tool.'

  s.add_runtime_dependency('rainbow', '>= 1.99.1', '< 3.0')
  s.add_runtime_dependency('parser', '>= 2.3.0.6', '< 3.0')
  s.add_runtime_dependency('powerpack', '~> 0.1')
  s.add_runtime_dependency('ruby-progressbar', '~> 1.7')
  s.add_runtime_dependency('unicode-display_width', '~> 0.3')

  s.add_development_dependency('bundler', '~> 1.3')
end
