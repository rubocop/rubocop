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
      expect(described_class).to be_absolute('/Users/foo')
    end

    it 'returns a falsey value for a path beginning with a directory name' do
      expect(described_class).not_to be_absolute('Users/foo')
    end

    if RuboCop::Platform.windows?
      it 'returns a truthy value for a path beginning with an upper case drive letter' do
        expect(described_class).to be_absolute('C:/Users/foo')
      end

      it 'returns a truthy value for a path beginning with a lower case drive letter' do
        expect(described_class).to be_absolute('d:/Users/foo')
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
      expect(described_class).not_to be_match_path('dir/**', 'dir/.hidden/file')
    end

    it 'matches dir/** for hidden file' do
      expect(described_class).to be_match_path('dir/**', 'dir/.hidden_file')
    end

    it 'does not match file in a subdirectory' do
      expect(described_class).not_to be_match_path('file', 'dir/files')
      expect(described_class).not_to be_match_path('dir', 'dir/file')
    end

    it 'matches strings to the full path' do
      expect(described_class).to be_match_path("#{Dir.pwd}/dir/file", "#{Dir.pwd}/dir/file")
      expect(described_class).not_to be_match_path(
        "#{Dir.pwd}/dir/file",
        "#{Dir.pwd}/dir/dir/file"
      )
    end

    it 'matches glob expressions' do
      expect(described_class).to be_match_path('dir/*', 'dir/file')
      expect(described_class).to be_match_path('dir/**/*', 'dir/sub/file')
      expect(described_class).to be_match_path('dir/**/*', 'dir/file')
      expect(described_class).to be_match_path('**/*', 'dir/sub/file')
      expect(described_class).to be_match_path('**/file', 'file')

      expect(described_class).not_to be_match_path('sub/*', 'dir/sub/file')

      expect(described_class).not_to be_match_path('**/*', 'dir/.hidden/file')
      expect(described_class).to be_match_path('**/*', 'dir/.hidden_file')
      expect(described_class).to be_match_path('**/.*/*', 'dir/.hidden/file')
      expect(described_class).to be_match_path('**/.*', 'dir/.hidden_file')

      expect(described_class).to be_match_path('c{at,ub}s', 'cats')
      expect(described_class).to be_match_path('c{at,ub}s', 'cubs')
      expect(described_class).not_to be_match_path('c{at,ub}s', 'gorillas')
      expect(described_class).to be_match_path('**/*.{rb,txt}', 'dir/foo.txt')
    end

    it 'matches regexps' do
      expect(described_class).to be_match_path(/^d.*e$/, 'dir/file')
      expect(described_class).not_to be_match_path(/^d.*e$/, 'dir/filez')
    end

    it 'does not match invalid UTF-8 paths' do
      expect(described_class).not_to be_match_path(/^d.*$/, "dir/file\xBF")
    end
  end
end
