# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::ResultCache, :isolated_environment do
  include FileHelper

  subject(:cache) do
    described_class.new(file, options, config_store, cache_root)
  end
  let(:file) { 'example.rb' }
  let(:options) { {} }
  let(:config_store) { double('config_store') }
  let(:cache_root) { "#{Dir.pwd}/rubocop_cache" }
  let(:offenses) do
    [RuboCop::Cop::Offense.new(:warning, location, 'unused var',
                               'Lint/UselessAssignment')]
  end
  let(:location) do
    source_buffer = Parser::Source::Buffer.new(file)
    source_buffer.read
    Parser::Source::Range.new(source_buffer, 0, 2)
  end

  def abs(path)
    File.expand_path(path)
  end

  before do
    create_file('example.rb', ['# Hello',
                               'x = 1'])
    allow(config_store).to receive(:for).with('example.rb').and_return({})
  end

  describe 'cached result that was saved with no command line option' do
    shared_examples 'valid' do
      it 'is valid and can be loaded' do
        cache.save(offenses)
        cache2 = described_class.new(file, options2, config_store, cache_root)
        expect(cache2.valid?).to eq(true)
        saved_offenses = cache2.load
        expect(saved_offenses).to eq(offenses)
      end
    end

    context 'when no option is given' do
      let(:options2) { {} }
      include_examples 'valid'

      context 'when file contents have changed' do
        it 'is invalid' do
          cache.save(offenses)
          create_file('example.rb', ['x = 2'])
          cache2 = described_class.new(file, options, config_store, cache_root)
          expect(cache2.valid?).to eq(false)
        end
      end

      context 'when a symlink attack is made' do
        before(:each) do
          # Avoid getting "symlink() function is unimplemented on this
          # machine" on Windows.
          if RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
            skip 'Symlinks not implemented on Windows'
          end

          cache.save(offenses)
          Find.find(cache_root) do |path|
            next unless File.basename(path) == '_'
            FileUtils.rm_rf(path)
            FileUtils.ln_s('/bin', path)
          end
          $stderr = StringIO.new
        end
        after(:each) { $stderr = STDERR }

        it 'is stopped' do
          cache2 = described_class.new(file, options, config_store, cache_root)
          cache2.save(offenses)
          # The cache file has not been created because there was a symlink in
          # its path.
          expect(cache2.valid?).to eq(false)
          expect($stderr.string)
            .to match(/Warning: .* is a symlink, which is not allowed.\n/)
        end
      end
    end

    context 'when --format is given' do
      let(:options2) { { format: 'simple' } }
      include_examples 'valid'
    end

    context 'when --only is given' do
      it 'is invalid' do
        cache.save(offenses)
        cache2 = described_class.new(file, { only: ['Metrics/LineLength'] },
                                     config_store, cache_root)
        expect(cache2.valid?).to eq(false)
      end
    end

    context 'when --display-cop-names is given' do
      it 'is invalid' do
        cache.save(offenses)
        cache2 = described_class.new(file, { display_cop_names: true },
                                     config_store, cache_root)
        expect(cache2.valid?).to eq(false)
      end
    end
  end

  describe '#save' do
    context 'when the default internal encoding is UTF-8' do
      let(:offenses) do
        [RuboCop::Cop::Offense.new(:warning, location, "unused var \xF0",
                                   'Lint/UselessAssignment')]
      end
      before(:each) { Encoding.default_internal = Encoding::UTF_8 }
      after(:each) { Encoding.default_internal = nil }

      it 'writes non UTF-8 encodable data to file with no exception' do
        cache.save(offenses)
      end
    end
  end

  describe '.cleanup' do
    before do
      cfg = { 'AllCops' => { 'MaxFilesInCache' => 1 } }
      allow(config_store).to receive(:for).with('.').and_return(cfg)
      allow(config_store).to receive(:for).with('other.rb').and_return(cfg)
      create_file('other.rb', ['x = 1'])
      $stdout = StringIO.new
    end

    after do
      $stdout = STDOUT
    end

    it 'removes the oldest files in the cache if needed' do
      cache.save(offenses)
      cache2 = described_class.new('other.rb', options, config_store,
                                   cache_root)
      expect(Dir["#{cache_root}/*/*/_/*"].size).to eq(1)
      cache.class.cleanup(config_store, :verbose, cache_root)
      expect($stdout.string).to eq('')

      cache2.save(offenses)
      underscore_dir = Dir["#{cache_root}/*/*/_"].first
      expect(Dir["#{underscore_dir}/*"].size).to eq(2)
      cache.class.cleanup(config_store, :verbose, cache_root)
      expect(File.exist?(underscore_dir)).to be_falsey
      expect($stdout.string)
        .to eq("Removing the 2 oldest files from #{cache_root}\n")
    end
  end
end

describe RuboCop::ResultCache, :isolated_environment do
  let(:config_store) { double('config_store') }
  let(:tmpdir) { File.realpath(Dir.tmpdir) }
  let(:puid) { Process.uid.to_s }

  describe 'the cache path when using a temp directory' do
    before do
      allow(config_store).to receive(:for).with('.').and_return(
        'AllCops' => { 'CacheRootDirectory' => '/tmp' }
      )
    end
    it 'contains the process uid' do
      cacheroot = RuboCop::ResultCache.cache_root(config_store)
      expect(cacheroot).to eq(File.join(tmpdir, puid, 'rubocop_cache'))
    end
  end
end
