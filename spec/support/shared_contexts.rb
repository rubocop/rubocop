# encoding: utf-8

require 'fakefs/safe'

shared_context 'isolated environment', :isolated_environment do
  around do |example|
    FakeFS do
      FakeFS::FileSystem.clone('config')
      original_home = ENV['HOME']

      begin
        virtual_home = File.expand_path('home')
        Dir.mkdir(virtual_home)
        ENV['HOME'] = virtual_home

        Dir.mkdir('work')
        Dir.chdir('work') do
          example.run
        end
      ensure
        ENV['HOME'] = original_home
        FakeFS::FileSystem.clear
      end
    end
  end
end

# `cop_config` must be declared with #let.
shared_context 'config', :config do
  let(:config) do
    # Module#<
    unless described_class < RuboCop::Cop::Cop
      fail '`config` must be used in `describe SomeCopClass do .. end`'
    end

    fail '`cop_config` must be declared with #let' unless cop_config.is_a?(Hash)

    cop_name = described_class.cop_name
    hash = {
      cop_name =>
      RuboCop::ConfigLoader.default_configuration[cop_name].merge(cop_config)
    }
    RuboCop::Config.new(hash, "#{Dir.pwd}/.rubocop.yml")
  end
end
