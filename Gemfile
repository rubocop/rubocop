# encoding: utf-8

source 'https://rubygems.org'

gemspec

group :test do
  gem 'coveralls', require: false
  gem 'fakefs',
    git: 'git@github.com:bquorning/fakefs.git',
    ref: 'glob-absolute-path'
end

local_gemfile = 'Gemfile.local'

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Lint/Eval
end
