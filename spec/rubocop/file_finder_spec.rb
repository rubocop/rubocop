# frozen_string_literal: true

RSpec.describe RuboCop::FileFinder, :isolated_environment do
  include FileHelper

  subject(:finder) { Class.new.include(described_class).new }

  before do
    create_empty_file('file')
    create_empty_file(File.join('dir', 'file'))
  end

  describe '#find_file_upwards' do
    it 'returns a file to be found upwards' do
      expect(finder.find_file_upwards('file', 'dir')).to eq(File.expand_path('file', 'dir'))
      expect(finder.find_file_upwards('file', Dir.pwd)).to eq(File.expand_path('file'))
    end

    it 'returns nil when file is not found' do
      expect(finder.find_file_upwards('file2', 'dir')).to be_nil
    end

    context 'when searching for a file inside a directory' do
      it 'returns a file to be found upwards' do
        expect(finder.find_file_upwards('dir/file', Dir.pwd)).to eq(File.expand_path('file', 'dir'))
      end

      it 'returns nil when file is not found' do
        expect(finder.find_file_upwards('dir2/file', Dir.pwd)).to be_nil
      end
    end
  end

  describe '#find_last_file_upwards' do
    it 'returns the last file found upwards' do
      expect(finder.find_last_file_upwards('file', 'dir')).to eq(File.expand_path('file'))
    end

    it 'returns nil when file is not found' do
      expect(finder.find_last_file_upwards('xyz', 'dir')).to be_nil
    end
  end

  describe '#traverse_directories_upwards' do
    subject(:match_paths) do
      matches = []
      finder.traverse_directories_upwards(start_dir, stop_dir) do |dir|
        matches << dir.expand_path.to_s
      end
      matches
    end

    let(:start_dir) { 'dir' }

    context 'when not specifying the stop dir' do
      let(:stop_dir) { nil }

      it 'returns directories' do
        expect(match_paths).to eq(
          [File.expand_path(start_dir), File.expand_path('.'), File.expand_path('..')]
        )
      end
    end

    context 'when specifying the stop dir' do
      let(:stop_dir) { "#{Dir.pwd}/dir" }

      it 'respects the stop dir parameter' do
        expect(match_paths).to eq([File.expand_path(start_dir)])
      end
    end
  end
end
