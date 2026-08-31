# frozen_string_literal: true

RSpec.describe RuboCop::ChangedFiles do
  subject(:changed_files) { described_class.new(revision) }

  let(:revision) { nil }

  def git(*args)
    _stdout, stderr, status = Open3.capture3('git', *args)

    raise "git #{args.join(' ')} failed: #{stderr}" unless status.success?
  end

  def commit_all(message)
    git('add', '-A')
    git('-c', 'user.email=test@example.com', '-c', 'user.name=Test', 'commit', '-m', message)
  end

  def write(path, contents = "# frozen_string_literal: true\n")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents)
  end

  def basenames
    changed_files.paths.map { |path| File.basename(path) }.sort
  end

  # Paths come back in the filesystem's encoding, which is the local code page
  # on Windows rather than UTF-8. Compare the characters, not the bytes.
  def basenames_as_utf8
    basenames.map { |name| name.encode(Encoding::UTF_8) }
  end

  around do |example|
    Dir.mktmpdir do |tmpdir|
      # Symlinked temporary directories (`/tmp` on macOS) make git and
      # `File.expand_path` disagree about the repository root.
      Dir.chdir(File.realpath(tmpdir)) do
        git('init')
        example.run
      end
    end
  end

  before do
    write('lib/untouched.rb')
    write('lib/modified.rb')
    write('lib/deleted.rb')
    commit_all('init')
  end

  it 'returns absolute paths that exist on disk' do
    write('lib/modified.rb', "# frozen_string_literal: true\n# changed\n")

    expect(changed_files.paths).to all(start_with(Dir.pwd))
    expect(changed_files.paths).to all(satisfy { |path| File.exist?(path) })
  end

  # Without `-z`, git reports these quoted and octal-escaped, and they quietly
  # fall out of the comparison.
  it 'reports paths that are not plain ASCII' do
    write('lib/café.rb')
    write('lib/naïve.rb', "# frozen_string_literal: true\n# changed\n")
    commit_all('accents')
    write('lib/café.rb', "# frozen_string_literal: true\n# changed\n")

    expect(basenames_as_utf8).to eq(['café.rb'])
    expect(changed_files.paths).to all(satisfy { |path| File.exist?(path) })
  end

  # git hands back bytes, which Ruby tags with the encoding the process was
  # started in. Under a US-ASCII locale that used to raise
  # `invalid byte sequence in US-ASCII` for every non-ASCII path.
  it 'does not depend on the encoding the process was started in' do
    allow(Open3).to receive(:capture3).and_wrap_original do |original, *args|
      stdout, stderr, status = original.call(*args)
      [stdout.dup.force_encoding(Encoding::US_ASCII), stderr, status]
    end

    write('lib/café.rb')
    commit_all('accents')
    write('lib/café.rb', "# frozen_string_literal: true\n# changed\n")
    write('lib/untracked_café.rb')

    expect(basenames_as_utf8).to eq(['café.rb', 'untracked_café.rb'])
  end

  # Unreachable on POSIX, where git's bytes are already the filesystem's.
  context 'when git reports UTF-8 but the filesystem uses another encoding' do
    before do
      allow(RuboCop::Platform).to receive(:windows?).and_return(true)
      stub_const("#{described_class}::FILESYSTEM_ENCODING", Encoding::WINDOWS_1252)
    end

    # Asserting the characters rather than the encoding of the returned string:
    # `File.expand_path` does not preserve the tag on every implementation, and
    # what matters is that the name survives the conversion intact.
    it 'converts the paths into the encoding the file list uses' do
      write('lib/café.rb')
      commit_all('accents')
      write('lib/café.rb', "# frozen_string_literal: true\n# changed\n")

      expect(basenames_as_utf8).to eq(['café.rb'])
    end

    it 'reports a name the code page cannot represent rather than dropping it' do
      write('lib/日本語.rb')
      commit_all('kanji')
      write('lib/日本語.rb', "# frozen_string_literal: true\n# changed\n")

      expect(basenames.size).to eq(1)
    end
  end

  it 'reports paths containing spaces' do
    write('lib/with space.rb')
    commit_all('spaces')
    write('lib/with space.rb', "# frozen_string_literal: true\n# changed\n")

    expect(basenames).to eq(['with space.rb'])
  end

  it 'reports files modified in the working tree' do
    write('lib/modified.rb', "# frozen_string_literal: true\n# changed\n")

    expect(basenames).to eq(['modified.rb'])
  end

  it 'reports staged files' do
    write('lib/modified.rb', "# frozen_string_literal: true\n# changed\n")
    git('add', 'lib/modified.rb')

    expect(basenames).to eq(['modified.rb'])
  end

  it 'reports untracked files' do
    write('lib/untracked.rb')

    expect(basenames).to eq(['untracked.rb'])
  end

  it 'ignores files excluded by gitignore' do
    write('.gitignore', "ignored.rb\n")
    write('lib/ignored.rb')

    expect(basenames).to eq(['.gitignore'])
  end

  it 'leaves out deleted files' do
    git('rm', 'lib/deleted.rb')

    expect(basenames).to be_empty
  end

  it 'reports nothing when the working tree is clean' do
    expect(changed_files.paths).to be_empty
  end

  it 'reports paths relative to the repository root when run from a subdirectory' do
    write('lib/modified.rb', "# frozen_string_literal: true\n# changed\n")

    Dir.chdir('lib') { expect(basenames).to eq(['modified.rb']) }
  end

  context 'in a repository without any commits' do
    around do |example|
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(File.realpath(tmpdir)) do
          git('init')
          example.run
        end
      end
    end

    it 'reports everything in the working tree' do
      write('lib/brand_new.rb')

      expect(basenames).to eq(['brand_new.rb'])
    end

    it 'still raises for a revision that was asked for by name' do
      changed_files = described_class.new('HEAD~1')

      expect { changed_files.paths }.to raise_error(RuboCop::Error)
    end
  end

  context 'with an explicit revision' do
    let(:revision) { 'HEAD~1' }

    it 'compares against that revision' do
      write('lib/modified.rb', "# frozen_string_literal: true\n# changed\n")
      commit_all('second')

      expect(basenames).to eq(['modified.rb'])
    end

    it 'raises a RuboCop error when the revision is unknown' do
      changed_files = described_class.new('no-such-revision')

      expect { changed_files.paths }
        .to raise_error(RuboCop::Error, /--changed could not ask git which files changed/)
    end
  end

  context 'when run outside a git repository' do
    it 'raises a RuboCop error' do
      Dir.mktmpdir do |outside|
        Dir.chdir(outside) do
          expect { changed_files.paths }.to raise_error(RuboCop::Error, /not a git repository/)
        end
      end
    end
  end
end
