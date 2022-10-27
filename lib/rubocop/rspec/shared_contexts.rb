# frozen_string_literal: true

require 'tmpdir'

RSpec.shared_context 'isolated environment' do # rubocop:disable Metrics/BlockLength
  around do |example|
    Dir.mktmpdir do |tmpdir|
      original_home = Dir.home
      original_xdg_config_home = ENV.fetch('XDG_CONFIG_HOME', nil)

      # Make sure to expand all symlinks in the path first. Otherwise we may
      # get mismatched pathnames when loading config files later on.
      tmpdir = File.realpath(tmpdir)

      virtual_home = File.expand_path(File.join(tmpdir, 'home'))
      Dir.mkdir(virtual_home)
      ENV['HOME'] = virtual_home
      ENV.delete('XDG_CONFIG_HOME')

      base_dir = example.metadata[:project_inside_home] ? virtual_home : tmpdir
      root = example.metadata[:root]
      working_dir = root ? File.join(base_dir, 'work', root) : File.join(base_dir, 'work')

      # Make upwards search for .rubocop.yml files stop at this directory.
      RuboCop::FileFinder.root_level = working_dir

      begin
        FileUtils.mkdir_p(working_dir)

        Dir.chdir(working_dir) { example.run }
      ensure
        ENV['HOME'] = original_home
        ENV['XDG_CONFIG_HOME'] = original_xdg_config_home

        RuboCop::FileFinder.root_level = nil
      end
    end
  end

  if RuboCop.const_defined?(:Server)
    around do |example|
      RuboCop::Server::Cache.cache_root_path = nil
      RuboCop::Server::Cache.instance_variable_set(:@project_dir_cache_key, nil)
      begin
        example.run
      ensure
        RuboCop::Server::Cache.cache_root_path = nil
        RuboCop::Server::Cache.instance_variable_set(:@project_dir_cache_key, nil)
      end
    end
  end
end

RSpec.shared_context 'maintain registry' do
  around(:each) { |example| RuboCop::Cop::Registry.with_temporary_global { example.run } }

  def stub_cop_class(name, inherit: RuboCop::Cop::Base, &block)
    klass = Class.new(inherit, &block)
    stub_const(name, klass)
    klass
  end
end

# This context assumes nothing and defines `cop`, among others.
RSpec.shared_context 'config' do # rubocop:disable Metrics/BlockLength
  ### Meant to be overridden at will

  let(:cop_class) do
    unless described_class.is_a?(Class) && described_class < RuboCop::Cop::Base
      raise 'Specify which cop class to use (e.g `let(:cop_class) { RuboCop::Cop::Base }`, ' \
            'or RuboCop::Cop::Cop for legacy)'
    end
    described_class
  end

  let(:cop_config) { {} }

  let(:other_cops) { {} }

  let(:cop_options) { {} }

  ### Utilities

  def source_range(range, buffer: source_buffer)
    Parser::Source::Range.new(buffer, range.begin,
                              range.exclude_end? ? range.end : range.end + 1)
  end

  ### Useful intermediary steps (less likely to be overridden)

  let(:processed_source) { parse_source(source, 'test') }

  let(:source_buffer) { processed_source.buffer }

  let(:all_cops_config) do
    rails = { 'TargetRubyVersion' => ruby_version }
    rails['TargetRailsVersion'] = rails_version if rails_version
    rails
  end

  let(:cur_cop_config) do
    RuboCop::ConfigLoader
      .default_configuration.for_cop(cop_class)
      .merge({
               'Enabled' => true, # in case it is 'pending'
               'AutoCorrect' => true # in case defaults set it to false
             })
      .merge(cop_config)
  end

  let(:config) do
    hash = { 'AllCops' => all_cops_config, cop_class.cop_name => cur_cop_config }.merge!(other_cops)

    RuboCop::Config.new(hash, "#{Dir.pwd}/.rubocop.yml")
  end

  let(:cop) { cop_class.new(config, cop_options) }
end

RSpec.shared_context 'mock console output' do
  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end
end

RSpec.shared_context 'ruby 2.0' do
  let(:ruby_version) { 2.0 }
end

RSpec.shared_context 'ruby 2.1' do
  let(:ruby_version) { 2.1 }
end

RSpec.shared_context 'ruby 2.2' do
  let(:ruby_version) { 2.2 }
end

RSpec.shared_context 'ruby 2.3' do
  let(:ruby_version) { 2.3 }
end

RSpec.shared_context 'ruby 2.4' do
  let(:ruby_version) { 2.4 }
end

RSpec.shared_context 'ruby 2.5' do
  let(:ruby_version) { 2.5 }
end

RSpec.shared_context 'ruby 2.6' do
  let(:ruby_version) { 2.6 }
end

RSpec.shared_context 'ruby 2.7' do
  let(:ruby_version) { 2.7 }
end

RSpec.shared_context 'ruby 3.0' do
  let(:ruby_version) { 3.0 }
end

RSpec.shared_context 'ruby 3.1' do
  let(:ruby_version) { 3.1 }
end

RSpec.shared_context 'ruby 3.2' do
  let(:ruby_version) { 3.2 }
end
