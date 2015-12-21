# encoding: utf-8

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
  let(:disabled_lines) { { 'Metrics/LineLength' => [4..5] } }
  let(:encoding_comment) { '' }
  let(:comment_text) { '# Hello' }
  let(:comments) do
    source_buffer = Parser::Source::Buffer.new(file)
    source_buffer.source = encoding_comment + comment_text
    range = Parser::Source::Range.new(source_buffer,
                                      0,
                                      source_buffer.source.length)
    [
      Parser::Source::Comment.new(range)
    ]
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
        cache.save(offenses, disabled_lines, comments)
        cache2 = described_class.new(file, options2, config_store, cache_root)
        expect(cache2.valid?).to eq(true)
        saved_offenses, saved_disabled_lines, saved_comments = cache2.load
        expect(saved_offenses).to eq(offenses)
        expect(saved_disabled_lines).to eq(disabled_lines)
        # The new Comment objects that have been created from cached data are
        # equivalent to the saved ones, but comparing them with the == operator
        # still gives false. That's because they refer to locations in
        # different source buffers. So we compare them attribute by attribute.
        expect(saved_comments.size).to eq(comments.size)
        comments.each_index do |ix|
          c1 = comments[ix]
          c2 = saved_comments[ix]
          expect(c2.text).to eq(c1.text)
          expect(c2.loc.expression.begin_pos).to eq(c1.loc.expression.begin_pos)
          expect(c2.loc.expression.end_pos).to eq(c1.loc.expression.end_pos)
        end
      end
    end

    context 'when no option is given' do
      let(:options2) { {} }
      include_examples 'valid'

      context 'when file contents have changed' do
        it 'is invalid' do
          cache.save(offenses, disabled_lines, comments)
          create_file('example.rb', ['x = 2'])
          cache2 = described_class.new(file, options, config_store, cache_root)
          expect(cache2.valid?).to eq(false)
        end
      end

      context 'when a symlink attack is made' do
        before(:each) do
          cache.save(offenses, disabled_lines, comments)
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
          cache2.save(offenses, disabled_lines, comments)
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
        cache.save(offenses, disabled_lines, comments)
        cache2 = described_class.new(file, { only: ['Metrics/LineLength'] },
                                     config_store, cache_root)
        expect(cache2.valid?).to eq(false)
      end
    end

    context 'when --display-cop-names is given' do
      it 'is invalid' do
        cache.save(offenses, disabled_lines, comments)
        cache2 = described_class.new(file, { display_cop_names: true },
                                     config_store, cache_root)
        expect(cache2.valid?).to eq(false)
      end
    end
  end

  describe '#save' do
    context 'when the default internal encoding is UTF-8' do
      let(:encoding_comment) { "# encoding: iso-8859-1\n" }
      let(:comment_text) { "# Hello \xF0" }
      before(:each) { Encoding.default_internal = Encoding::UTF_8 }
      after(:each) { Encoding.default_internal = nil }

      it 'writes non UTF-8 encodable data to file with no exception' do
        cache.save(offenses, disabled_lines, comments)
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
      cache.save(offenses, disabled_lines, comments)
      cache2 = described_class.new('other.rb', options, config_store,
                                   cache_root)
      expect(Dir["#{cache_root}/*/*/_/*"].size).to eq(1)
      cache.class.cleanup(config_store, :verbose, cache_root)
      expect($stdout.string).to eq('')

      cache2.save(offenses, disabled_lines, comments)
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
