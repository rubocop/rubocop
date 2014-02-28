source 'http://rubygems.org'

gemspec

group :test do
  gem 'coveralls', require: false
end

local_gemfile = 'Gemfile.local'

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Eval
end
