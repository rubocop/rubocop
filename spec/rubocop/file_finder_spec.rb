# frozen_string_literal: true

RSpec.describe RuboCop::FileFinder, :isolated_environment do
  include FileHelper

  subject(:finder) { Class.new.include(described_class).new }

  before do
    create_file('file', '')
    create_file(File.join('dir', 'file'), '')
  end

  describe '#find_file_upwards' do
    it 'returns a file to be found upwards' do
      expect(finder.find_file_upwards('file', 'dir'))
        .to eq(File.expand_path('file', 'dir'))
      expect(finder.find_file_upwards('file', Dir.pwd))
        .to eq(File.expand_path('file'))
    end

    it 'returns nil when file is not found' do
      expect(finder.find_file_upwards('file2', 'dir')).to be(nil)
    end

    context 'when given `home_dir` option' do
      before { create_file(File.join(Dir.home, 'file2'), '') }

      context 'and a file exists in home directory' do
        it 'returns the file' do
          expect(finder.find_file_upwards('file2', 'dir', home_dir: true))
            .to eq(File.expand_path('file2', Dir.home))
        end
      end

      context 'but no `HOME` in `ENV`' do
        before { ENV.delete('HOME') }

        it 'returns nil' do
          expect(finder.find_file_upwards('file2', 'dir', home_dir: true))
            .to be(nil)
        end
      end
    end
  end

  describe '#find_files_upwards' do
    it 'returns an array of files to be found upwards' do
      expect(finder.find_files_upwards('file', 'dir'))
        .to eq([File.expand_path('file', 'dir'),
                File.expand_path('file')])
    end

    it 'returns an empty array when file is not found' do
      expect(finder.find_files_upwards('xyz', 'dir')).to eq([])
    end

    context 'when given `home_dir` option' do
      before { create_file(File.join(Dir.home, 'file'), '') }

      context 'and a file exists in home directory' do
        it 'returns an array including the file' do
          expect(finder.find_files_upwards('file', 'dir', home_dir: true))
            .to eq([File.expand_path('file', 'dir'),
                    File.expand_path('file'),
                    File.expand_path('file', Dir.home)])
        end
      end

      context 'but no `HOME` in `ENV`' do
        before { ENV.delete('HOME') }

        it 'returns an array not including the file' do
          expect(finder.find_files_upwards('file', 'dir', home_dir: true))
            .to eq([File.expand_path('file', 'dir'),
                    File.expand_path('file')])
        end
      end
    end
  end
end
