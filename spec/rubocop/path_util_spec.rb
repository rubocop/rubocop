# frozen_string_literal: true

RSpec.describe RuboCop::PathUtil do
  describe '#relative_path' do
    it 'builds paths relative to PWD by default as a stop-gap' do
      relative = File.join(Dir.pwd, 'relative')
      expect(described_class.relative_path(relative)).to eq('relative')
    end

    it 'supports custom base paths' do
      expect(described_class.relative_path('/foo/bar', '/foo')).to eq('bar')
    end

    if RuboCop::Platform.windows?
      it 'works for different drives' do
        expect(described_class.relative_path('D:/foo/bar', 'C:/foo')).to eq('D:/foo/bar')
      end

      it 'works for the same drive' do
        expect(described_class.relative_path('D:/foo/bar', 'D:/foo')).to eq('bar')
      end
    end
  end

  describe '#absolute?' do
    it 'returns a truthy value for a path beginning with slash' do
      expect(described_class.absolute?('/Users/foo')).to be_truthy
    end

    it 'returns a falsey value for a path beginning with a directory name' do
      expect(described_class.absolute?('Users/foo')).to be_falsey
    end

    if RuboCop::Platform.windows?
      it 'returns a truthy value for a path beginning with an upper case drive letter' do
        expect(described_class.absolute?('C:/Users/foo')).to be_truthy
      end

      it 'returns a truthy value for a path beginning with a lower case drive letter' do
        expect(described_class.absolute?('d:/Users/foo')).to be_truthy
      end
    end
  end

  describe '#match_path?', :isolated_environment do
    include FileHelper

    before do
      create_empty_file('file')
      create_empty_file('dir/file')
      create_empty_file('dir/files')
      create_empty_file('dir/dir/file')
      create_empty_file('dir/sub/file')
      create_empty_file('dir/.hidden/file')
      create_empty_file('dir/.hidden_file')
    end

    it 'does not match dir/** for file in hidden dir' do
      expect(described_class.match_path?('dir/**', 'dir/.hidden/file')).to be(false)
    end

    it 'matches dir/** for hidden file' do
      expect(described_class.match_path?('dir/**', 'dir/.hidden_file')).to be(true)
    end

    it 'does not match file in a subdirectory' do
      expect(described_class.match_path?('file', 'dir/files')).to be(false)
      expect(described_class.match_path?('dir', 'dir/file')).to be(false)
    end

    it 'matches strings to the full path' do
      expect(described_class.match_path?("#{Dir.pwd}/dir/file", "#{Dir.pwd}/dir/file")).to be(true)
      expect(described_class.match_path?(
               "#{Dir.pwd}/dir/file",
               "#{Dir.pwd}/dir/dir/file"
             )).to be(false)
    end

    it 'matches glob expressions' do
      expect(described_class.match_path?('dir/*', 'dir/file')).to be(true)
      expect(described_class.match_path?('dir/**/*', 'dir/sub/file')).to be(true)
      expect(described_class.match_path?('dir/**/*', 'dir/file')).to be(true)
      expect(described_class.match_path?('**/*', 'dir/sub/file')).to be(true)
      expect(described_class.match_path?('**/file', 'file')).to be(true)

      expect(described_class.match_path?('sub/*', 'dir/sub/file')).to be(false)

      expect(described_class.match_path?('**/*', 'dir/.hidden/file')).to be(false)
      expect(described_class.match_path?('**/*', 'dir/.hidden_file')).to be(true)
      expect(described_class.match_path?('**/.*/*', 'dir/.hidden/file')).to be(true)
      expect(described_class.match_path?('**/.*', 'dir/.hidden_file')).to be(true)

      expect(described_class.match_path?('c{at,ub}s', 'cats')).to be(true)
      expect(described_class.match_path?('c{at,ub}s', 'cubs')).to be(true)
      expect(described_class.match_path?('c{at,ub}s', 'gorillas')).to be(false)
      expect(described_class.match_path?('**/*.{rb,txt}', 'dir/foo.txt')).to be(true)
    end

    it 'matches regexps' do
      expect(described_class.match_path?(/^d.*e$/, 'dir/file')).to be(true)
      expect(described_class.match_path?(/^d.*e$/, 'dir/filez')).to be(false)
    end

    it 'does not match invalid UTF-8 paths' do
      expect(described_class.match_path?(/^d.*$/, "dir/file\xBF")).to be(false)
    end
  end
end
