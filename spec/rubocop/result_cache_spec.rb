# frozen_string_literal: true

RSpec.describe RuboCop::ResultCache, :isolated_environment do
  include FileHelper

  subject(:cache) do
    described_class.new(file, team, options, config_store, cache_root)
  end

  let(:cops) { RuboCop::Cop::Cop.all }
  let(:registry) { RuboCop::Cop::Cop.registry }
  let(:team) do
    RuboCop::Cop::Team.mobilize(
      registry,
      RuboCop::ConfigLoader.default_configuration,
      options
    )
  end

  let(:file) { 'example.rb' }
  let(:options) { {} }
  let(:config_store) do
    instance_double(RuboCop::ConfigStore, for_pwd: RuboCop::Config.new)
  end
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
    create_file('example.rb', <<~RUBY)
      # Hello
      x = 1
    RUBY
    allow(config_store).to receive(:for_file).with('example.rb')
                                             .and_return(RuboCop::Config.new)
    allow(team).to receive(:external_dependency_checksum).and_return('foo')
  end

  describe 'cached result that was saved with no command line option' do
    shared_examples 'valid' do
      it 'is valid and can be loaded' do
        cache.save(offenses)
        cache2 = described_class.new(
          file, team, options2, config_store, cache_root
        )
        expect(cache2.valid?).to eq(true)
        saved_offenses = cache2.load
        expect(saved_offenses).to eq(offenses)
      end
    end

    # Fixes https://github.com/rubocop-hq/rubocop/issues/6274
    context 'when offenses are saved by autocorrect run' do
      let(:corrected_offense) do
        RuboCop::Cop::Offense.new(
          :warning, location, 'unused var', 'Lint/UselessAssignment', :corrected
        )
      end
      let(:uncorrected_offense) do
        RuboCop::Cop::Offense.new(
          corrected_offense.severity.name,
          corrected_offense.location,
          corrected_offense.message,
          corrected_offense.cop_name,
          :uncorrected
        )
      end

      it 'serializes them with :uncorrected status' do
        cache.save([corrected_offense])
        expect(cache.load).to match_array([uncorrected_offense])
      end
    end

    context 'when no option is given' do
      let(:options2) { {} }

      include_examples 'valid'

      context 'when file contents have changed' do
        it 'is invalid' do
          cache.save(offenses)
          create_file('example.rb', ['x = 2'])
          cache2 = described_class.new(
            file, team, options, config_store, cache_root
          )
          expect(cache2.valid?).to eq(false)
        end
      end

      context 'when file permission have changed' do
        unless RuboCop::Platform.windows?
          it 'is invalid' do
            cache.save(offenses)
            FileUtils.chmod('+x', file)
            cache2 = described_class.new(file, team, options,
                                         config_store, cache_root)
            expect(cache2.valid?).to eq(false)
          end
        end
      end

      context 'when end of line characters have changed' do
        it 'is invalid' do
          cache.save(offenses)
          contents = File.binread(file)
          File.open(file, 'wb') do |f|
            if contents.include?("\r")
              f.write(contents.delete("\r"))
            else
              f.write(contents.gsub(/\n/, "\r\n"))
            end
          end
          cache2 = described_class.new(file, team, options,
                                       config_store, cache_root)
          expect(cache2.valid?).to eq(false)
        end
      end

      context 'when team external_dependency_checksum changes' do
        it 'is invalid' do
          cache.save(offenses)
          expect(team).to(
            receive(:external_dependency_checksum).and_return('bar')
          )
          cache2 = described_class.new(
            file, team, options, config_store, cache_root
          )
          expect(cache2.valid?).to eq(false)
        end
      end

      context 'when team external_dependency_checksum is the same' do
        it 'is valid' do
          cache.save(offenses)
          expect(team).to(
            receive(:external_dependency_checksum).and_return('foo')
          )
          cache2 = described_class.new(
            file, team, options, config_store, cache_root
          )
          expect(cache2.valid?).to eq(true)
        end
      end

      context 'when a symlink is present in the cache location' do
        let(:cache2) do
          described_class.new(file, team, options, config_store, cache_root)
        end

        let(:attack_target_dir) { Dir.mktmpdir }

        before do
          # Avoid getting "symlink() function is unimplemented on this
          # machine" on Windows.
          skip 'Symlinks not implemented on Windows' if RuboCop::Platform.windows?

          cache.save(offenses)
          result = Dir["#{cache_root}/*/*"]
          path = result.first
          FileUtils.rm_rf(path)
          FileUtils.ln_s(attack_target_dir, path)
          $stderr = StringIO.new
        end

        after do
          FileUtils.rm_rf(attack_target_dir)
          $stderr = STDERR
        end

        context 'and symlink attack protection is enabled' do
          it 'prevents caching and prints a warning' do
            cache2.save(offenses)
            # The cache file has not been created because there was a symlink in
            # its path.
            expect(cache2.valid?).to eq(false)
            expect($stderr.string)
              .to match(/Warning: .* is a symlink, which is not allowed.\n/)
          end
        end

        context 'and symlink attack protection is disabled' do
          before do
            allow(config_store).to receive(:for_pwd).and_return(
              RuboCop::Config.new(
                'AllCops' => {
                  'AllowSymlinksInCacheRootDirectory' => true
                }
              )
            )
          end

          it 'permits caching and prints no warning' do
            cache2.save(offenses)

            expect(cache2.valid?).to eq(true)
            expect($stderr.string)
              .not_to match(/Warning: .* is a symlink, which is not allowed.\n/)
          end
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
        cache2 = described_class.new(file, team,
                                     { only: ['Layout/LineLength'] },
                                     config_store, cache_root)
        expect(cache2.valid?).to eq(false)
      end
    end

    context 'when --display-cop-names is given' do
      it 'is invalid' do
        cache.save(offenses)
        cache2 = described_class.new(file, team, { display_cop_names: true },
                                     config_store, cache_root)
        expect(cache2.valid?).to eq(false)
      end
    end

    context 'when a cache source is read' do
      it 'has utf8 encoding' do
        cache.save(offenses)
        result = cache.load
        loaded_encoding = result[0].location.source.encoding

        expect(loaded_encoding).to eql(Encoding::UTF_8)
      end
    end
  end

  describe '#save' do
    context 'when the default internal encoding is UTF-8' do
      let(:offenses) do
        [
          "unused var \xF0",
          (+'unused var あ').force_encoding(::Encoding::ASCII_8BIT)
        ].map do |message|
          RuboCop::Cop::Offense.new(:warning, location, message,
                                    'Lint/UselessAssignment')
        end
      end

      before { Encoding.default_internal = Encoding::UTF_8 }

      after { Encoding.default_internal = nil }

      it 'writes non UTF-8 encodable data to file with no exception' do
        cache.save(offenses)
      end
    end

    shared_examples 'invalid cache location' do |error, message|
      before do
        $stderr = StringIO.new
      end

      it 'doesn\'t raise an exception' do
        expect(FileUtils).to receive(:mkdir_p).with(start_with(cache_root))
                                              .and_raise(error)
        expect { cache.save([]) }.not_to raise_error
        expect($stderr.string).to eq(<<~WARN)
          Couldn't create cache directory. Continuing without cache.
            #{message}
        WARN
      end

      after do
        $stderr = STDERR
      end
    end

    context 'when the @path is not writable' do
      let(:cache_root) { '/permission_denied_dir' }

      it_behaves_like 'invalid cache location',
                      Errno::EACCES, 'Permission denied'
      it_behaves_like 'invalid cache location',
                      Errno::EROFS, 'Read-only file system'
    end
  end

  describe '.cleanup' do
    before do
      cfg = RuboCop::Config.new('AllCops' => { 'MaxFilesInCache' => 1 })
      allow(config_store).to receive(:for_pwd).and_return(cfg)
      allow(config_store).to receive(:for_file).with('other.rb').and_return(cfg)
      create_file('other.rb', ['x = 1'])
      $stdout = StringIO.new
    end

    after do
      $stdout = STDOUT
    end

    it 'removes the oldest files in the cache if needed' do
      cache.save(offenses)
      cache2 = described_class.new('other.rb', team, options, config_store,
                                   cache_root)
      expect(Dir["#{cache_root}/*/*/*"].size).to eq(1)
      cache.class.cleanup(config_store, :verbose, cache_root)
      expect($stdout.string).to eq('')

      cache2.save(offenses)
      underscore_dir = Dir["#{cache_root}/*/*"].first
      expect(Dir["#{underscore_dir}/*"].size).to eq(2)
      cache.class.cleanup(config_store, :verbose, cache_root)
      expect(File.exist?(underscore_dir)).to be_falsey
      expect($stdout.string)
        .to eq("Removing the 2 oldest files from #{cache_root}\n")
    end
  end

  describe 'the cache path' do
    let(:config_store) do
      instance_double(RuboCop::ConfigStore)
    end
    let(:puid) { Process.uid.to_s }

    before do
      all_cops = {
        'AllCops' => { 'CacheRootDirectory' => cache_root_directory }
      }
      config = RuboCop::Config.new(all_cops)
      allow(config_store).to receive(:for_pwd).and_return(config)
    end

    context 'when CacheRootDirectory not set' do
      let(:cache_root_directory) { nil }

      context 'and XDG_CACHE_HOME is not set' do
        before { ENV['XDG_CACHE_HOME'] = nil }

        it 'contains $HOME/.cache' do
          cacheroot = described_class.cache_root(config_store)
          expect(cacheroot)
            .to eq(File.join(Dir.home, '.cache', 'rubocop_cache'))
        end
      end

      context 'and XDG_CACHE_HOME is set' do
        around do |example|
          ENV['XDG_CACHE_HOME'] = '/etc/rccache'
          begin
            example.run
          ensure
            ENV.delete('XDG_CACHE_HOME')
          end
        end

        it 'contains the given path and UID' do
          cacheroot = described_class.cache_root(config_store)
          expect(cacheroot)
            .to eq(File.join(ENV['XDG_CACHE_HOME'], puid, 'rubocop_cache'))
        end
      end
    end

    context 'when CacheRootDirectory is set' do
      let(:cache_root_directory) { '/opt' }

      it 'contains the given root' do
        cacheroot = described_class.cache_root(config_store)
        expect(cacheroot).to eq(File.join('/opt', 'rubocop_cache'))
      end
    end
  end
end
