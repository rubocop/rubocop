# encoding: utf-8

require 'tmpdir'
require 'fileutils'

shared_context 'isolated environment', :isolated_environment do
  around do |example|
    Dir.mktmpdir do |tmpdir|
      original_home = ENV['HOME']

      # Make sure to expand all symlinks in the path first. Otherwise we may
      # get mismatched pathnames when loading config files later on.
      tmpdir = File.realpath(tmpdir)

      # Make upwards search for .rubocop.yml files stop at this directory.
      Rubocop::ConfigLoader.root_level = tmpdir

      begin
        virtual_home = File.expand_path(File.join(tmpdir, 'home'))
        Dir.mkdir(virtual_home)
        ENV['HOME'] = virtual_home

        working_dir = File.join(tmpdir, 'work')
        Dir.mkdir(working_dir)

        Dir.chdir(working_dir) do
          example.run
        end
      ensure
        ENV['HOME'] = original_home
      end
    end
  end
end
