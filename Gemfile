# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'asciidoctor'
gem 'bump', require: false
gem 'fiddle', platform: :windows if RUBY_VERSION >= '3.4'
gem 'irb'
# FIXME: mcp 1.8.0 makes Ruby 2.7 print a keyword argument deprecation warning for every
# stdio request, which fails the MCP server specs that expect a silent stderr.
# Remove the exclusion once 1.8.1 ships the fix.
# https://github.com/modelcontextprotocol/ruby-sdk/pull/621
gem 'mcp', '~> 1.0', '!= 1.8.0'
gem 'memory_profiler', '!= 1.0.2', platform: :mri
gem 'rake', '~> 13.0'
# FIXME: rdoc 8.0+ depends on rbs, whose released C extension fails to build on JRuby.
# rbs 4.1.0.pre.2 ships a `java` platform gem that works on JRuby, so pin to it there
# until a stable release that supports JRuby ships.
# https://github.com/ruby/rdoc/issues/1746
gem 'rbs', '4.1.0.pre.2' if RUBY_ENGINE == 'jruby'
# FIXME: regexp_parser 2.13.2 makes `Regexp::Syntax::Base.implements` private,
# which json_schemer 2.5.0 (a dependency of mcp) calls when it is loaded, so the MCP server
# fails to start. Remove the exclusion once a regexp_parser or json_schemer release fixes it.
# https://github.com/ammar/regexp_parser/issues/116
gem 'regexp_parser', '!= 2.13.2'
gem 'rspec', '~> 3.7'
gem 'rubocop-performance', '~> 1.27.0', require: false
gem 'rubocop-rake', '~> 0.7.0', require: false
gem 'rubocop-rspec', '~> 3.11.0', require: false
if ENV['PARSER_ENGINE'] == 'prism'
  # The `prism` parser engine needs Prism 2, which Ruby LSP does not support yet.
  gem 'prism', '>= 2.0'
elsif RUBY_VERSION >= '3.0'
  # Ruby LSP supports Ruby 3.0+.
  gem 'ruby-lsp', '>= 0.26.9', '< 1.0', platform: :mri
end
# Optional project-wide static-analysis index used by `AllCops/UseProjectIndex`.
# Not a runtime dependency of the rubocop gem itself; only listed here so that
# the development environment can exercise the integration. The gem only publishes
# native binaries for MRI on supported platforms, so we gate by `RUBY_ENGINE` to
# keep JRuby and other engines unaffected.
# FIXME: With rubydex 0.4.3, `Lint/DeprecatedReference` reports references to constants that
# are not deprecated in the internal investigation on CI. Remove the exclusion once that is fixed.
# https://github.com/rubocop/rubocop/actions/runs/40363639316/job/121716004034
gem 'rubydex', '!= 0.4.3', require: false if RUBY_VERSION >= '3.2' && RUBY_ENGINE == 'ruby'
# SimpleCov 1.0 requires Ruby 3.2+. Coverage measurement is opt-in (`COVERAGE=1`)
# and unnecessary on the older Rubies in the CI matrix.
gem 'simplecov', '~> 1.0' if RUBY_VERSION >= '3.2'
gem 'stackprof', platform: :mri
gem 'test-queue'
gem 'yard', '~> 0.9'

group :test do
  gem 'webmock', require: false
end

local_ast = File.expand_path('../rubocop-ast', __dir__)
gem 'rubocop-ast', path: local_ast if Dir.exist? local_ast

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
