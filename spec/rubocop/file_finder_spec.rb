# frozen_string_literal: true

RSpec.describe RuboCop::FileFinder, :isolated_environment do
  include FileHelper

  subject(:finder) { Class.new.include(described_class).new }

  before do
    create_empty_file('file')
    create_empty_file(File.join('dir', 'file'))
    create_empty_file(File.join('dir', 'sub', 'file'))
    create_empty_file(File.join('dir', 'red', 'herring'))
  end

  after { described_class.root_level = nil }

  let(:sub_dir) { File.join('dir', 'sub') }
  let(:red_dir) { File.join('dir', 'red') }

  let(:root_file) { File.expand_path('file') }
  let(:dir_file) { File.expand_path('file', 'dir') }
  let(:sub_file) { File.expand_path('file', sub_dir) }

  describe '#find_file_upwards' do
    it 'returns a file to be found upwards' do
      expect(finder.find_file_upwards('file', 'dir')).to eq(dir_file)
      expect(finder.find_file_upwards('file', Dir.pwd)).to eq(root_file)
    end

    it 'returns a file to be found upwards multiple levels until the first match is found' do
      expect(finder.find_file_upwards('file', red_dir)).to eq(dir_file)
    end

    it 'returns nil when file is not found' do
      expect(finder.find_file_upwards('file2', 'dir').nil?).to be(true)
    end

    it 'returns nil when stop_dir prevents finding a match' do
      expect(finder.find_file_upwards('file', red_dir, red_dir).nil?).to be(true)
    end

    it 'returns the same file if given a matching file as start_dir' do
      expect(finder.find_file_upwards('file', File.join('dir', 'file'))).to eq(dir_file)
    end

    it 'ignores stop_dir if it is not a parent of start dir' do
      expect(finder.find_file_upwards('file', 'dir', sub_dir)).to eq(dir_file)
    end

    it 'returns a file found upwards limited by stop_dir' do
      expect(finder.find_file_upwards('file', sub_dir, 'dir')).to eq(sub_file)
    end

    it 'ignores root_level if it is not a parent of start dir' do
      described_class.root_level = '/usr/local'
      expect(finder.find_file_upwards('file', 'dir')).to eq(dir_file)
    end

    it 'returns a file found upwards limited by root_level' do
      described_class.root_level = File.expand_path('dir')
      expect(finder.find_file_upwards('file', red_dir)).to eq(dir_file)
    end

    it 'returns a file found upwards limited by given stop_dir and root_level' do
      described_class.root_level = File.expand_path('dir')
      expect(finder.find_file_upwards('file', sub_dir, sub_dir)).to eq(sub_file)
    end
  end

  describe '#find_last_file_upwards' do
    it 'returns the last file found upwards' do
      expect(finder.find_last_file_upwards('file', 'dir')).to eq(root_file)
    end

    it 'returns nil when file is not found' do
      expect(finder.find_last_file_upwards('xyz', 'dir').nil?).to be(true)
    end

    it 'returns nil when stop_dir prevents finding a match' do
      expect(finder.find_last_file_upwards('file', red_dir, red_dir).nil?).to be(true)
    end

    it 'ignores stop_dir if it is not a parent of start dir' do
      expect(finder.find_last_file_upwards('file', 'dir', '/usr/bin')).to eq(root_file)
    end

    it 'returns a file found upwards limited by stop_dir' do
      expect(finder.find_last_file_upwards('file', File.join('dir', 'sub'), 'dir')).to eq(dir_file)
    end

    it 'ignores root_level if it is not a parent of start dir' do
      described_class.root_level = '/usr/local'
      expect(finder.find_last_file_upwards('file', 'dir')).to eq(root_file)
    end

    it 'returns a file found upwards limited by root_level' do
      described_class.root_level = File.expand_path('dir')
      expect(finder.find_last_file_upwards('file', sub_dir)).to eq(dir_file)
    end

    it 'returns a file found upwards limited by given stop_dir or root_level, whichever is first' do
      described_class.root_level = File.expand_path(sub_dir)
      found = finder.find_last_file_upwards('file', sub_dir, 'dir')
      expect(found).to eq(sub_file)
    end
  end

  describe '#files_upwards' do
    it 'returns an enumerator when no block is given' do
      expect(finder.files_upwards('file', 'dir')).to be_an(Enumerator)
    end

    it 'returns the files found upwards' do
      expect(finder.files_upwards('file', 'dir').to_a).to eq([dir_file, root_file])
    end

    it 'returns an empty array when no file is found' do
      expect(finder.files_upwards('xyz', 'dir').to_a).to eq([])
    end

    it 'returns an empty array when stop_dir prevents finding a match' do
      expect(finder.files_upwards('file', red_dir, red_dir).to_a).to eq([])
    end

    it 'ignores stop_dir if it is not a parent of start dir' do
      expect(finder.files_upwards('file', 'dir', '/usr/bin').to_a).to eq([dir_file, root_file])
    end

    it 'returns files found upwards limited by stop_dir' do
      expect(finder.files_upwards('file', sub_dir, 'dir').to_a).to eq([sub_file, dir_file])
    end

    it 'ignores root_level if it is not a parent of start dir' do
      described_class.root_level = '/usr/local'
      expect(finder.files_upwards('file', 'dir').to_a).to eq([dir_file, root_file])
    end

    it 'returns files found upwards limited by root_level' do
      described_class.root_level = File.expand_path('dir')
      expect(finder.files_upwards('file', sub_dir).to_a).to eq([sub_file, dir_file])
    end

    it 'returns files found upwards limited by given stop_dir or root_level, whichever is first' do
      described_class.root_level = File.expand_path(sub_dir)
      found = finder.files_upwards('file', sub_dir, 'dir').to_a
      expect(found).to eq([sub_file])
    end
  end
end
