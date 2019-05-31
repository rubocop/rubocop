# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

RSpec.shared_context 'isolated environment', :isolated_environment do
  around do |example|
    Dir.mktmpdir do |tmpdir|
      original_home = ENV['HOME']
      original_xdg_config_home = ENV['XDG_CONFIG_HOME']

      # Make sure to expand all symlinks in the path first. Otherwise we may
      # get mismatched pathnames when loading config files later on.
      tmpdir = File.realpath(tmpdir)

      # Make upwards search for .rubocop.yml files stop at this directory.
      RuboCop::FileFinder.root_level = tmpdir

      begin
        virtual_home = File.expand_path(File.join(tmpdir, 'home'))
        Dir.mkdir(virtual_home)
        ENV['HOME'] = virtual_home
        ENV.delete('XDG_CONFIG_HOME')

        working_dir = File.join(tmpdir, 'work')
        Dir.mkdir(working_dir)

        RuboCop::PathUtil.chdir(working_dir) do
          example.run
        end
      ensure
        ENV['HOME'] = original_home
        ENV['XDG_CONFIG_HOME'] = original_xdg_config_home

        RuboCop::FileFinder.root_level = nil
      end
    end
  end
end

# `cop_config` must be declared with #let.
RSpec.shared_context 'config', :config do
  let(:config) do
    # Module#<
    unless described_class < RuboCop::Cop::Cop
      raise '`config` must be used in `describe SomeCopClass do .. end`'
    end

    hash = { 'AllCops' => { 'TargetRubyVersion' => ruby_version } }
    hash['AllCops']['TargetRailsVersion'] = rails_version if rails_version
    if respond_to?(:cop_config)
      cop_name = described_class.cop_name
      hash[cop_name] = RuboCop::ConfigLoader
                       .default_configuration[cop_name]
                       .merge(cop_config)
    end

    hash = other_cops.merge hash if respond_to?(:other_cops)

    RuboCop::Config.new(hash, "#{Dir.pwd}/.rubocop.yml")
  end
end

RSpec.shared_context 'ruby 2.3', :ruby23 do
  let(:ruby_version) { 2.3 }
end

RSpec.shared_context 'ruby 2.4', :ruby24 do
  let(:ruby_version) { 2.4 }
end

RSpec.shared_context 'ruby 2.5', :ruby25 do
  let(:ruby_version) { 2.5 }
end

RSpec.shared_context 'ruby 2.6', :ruby26 do
  let(:ruby_version) { 2.6 }
end
