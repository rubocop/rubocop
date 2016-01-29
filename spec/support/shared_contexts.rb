# encoding: utf-8
# frozen_string_literal: true

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
      RuboCop::ConfigLoader.root_level = tmpdir

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

# `cop_config` must be declared with #let.
shared_context 'config', :config do
  let(:config) do
    # Module#<
    unless described_class < RuboCop::Cop::Cop
      raise '`config` must be used in `describe SomeCopClass do .. end`'
    end

    hash = { 'AllCops' => { 'TargetRubyVersion' => ruby_version } }
    if respond_to?(:cop_config)
      cop_name = described_class.cop_name
      hash[cop_name] = RuboCop::ConfigLoader
                       .default_configuration[cop_name]
                       .merge(cop_config)
    end

    RuboCop::Config.new(hash, "#{Dir.pwd}/.rubocop.yml")
  end
end

shared_context 'ruby 1.9', :ruby19 do
  let(:ruby_version) { 1.9 }
end

shared_context 'ruby 2.0', :ruby20 do
  let(:ruby_version) { 2.0 }
end

shared_context 'ruby 2.1', :ruby21 do
  let(:ruby_version) { 2.1 }
end

shared_context 'ruby 2.2', :ruby22 do
  let(:ruby_version) { 2.2 }
end

shared_context 'ruby 2.3', :ruby23 do
  let(:ruby_version) { 2.3 }
end
