# frozen_string_literal: true

require 'tmpdir'

RSpec.shared_context 'isolated environment', :isolated_environment do
  around do |example|
    Dir.mktmpdir do |tmpdir|
      original_home = ENV['HOME']
      original_xdg_config_home = ENV['XDG_CONFIG_HOME']

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
end

RSpec.shared_context 'maintain registry', :restore_registry do
  around(:each) { |example| RuboCop::Cop::Registry.with_temporary_global { example.run } }

  def stub_cop_class(name, inherit: RuboCop::Cop::Base, &block)
    klass = Class.new(inherit, &block)
    stub_const(name, klass)
    klass
  end
end

# This context assumes nothing and defines `cop`, among others.
RSpec.shared_context 'config', :config do # rubocop:disable Metrics/BlockLength
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

RSpec.shared_context 'ruby 2.5', :ruby25 do
  let(:ruby_version) { 2.5 }
end

RSpec.shared_context 'ruby 2.6', :ruby26 do
  let(:ruby_version) { 2.6 }
end

RSpec.shared_context 'ruby 2.7', :ruby27 do
  let(:ruby_version) { 2.7 }
end

RSpec.shared_context 'ruby 3.0', :ruby30 do
  let(:ruby_version) { 3.0 }
end

RSpec.shared_context 'ruby 3.1', :ruby31 do
  let(:ruby_version) { 3.1 }
end

RSpec.shared_context 'ruby 3.2', :ruby32 do
  let(:ruby_version) { 3.2 }
end
