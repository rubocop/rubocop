# frozen_string_literal: true

RSpec.describe RuboCop::Util, :isolated_environment do
  include FileHelper

  describe '.replace_file_contents' do
    let(:path) { 'example.rb' }

    before { create_file(path, 'original') }

    it 'replaces the contents of the file' do
      described_class.replace_file_contents(path, 'replaced')

      expect(File.read(path)).to eq('replaced')
    end

    it 'leaves no temporary file behind' do
      described_class.replace_file_contents(path, 'replaced')

      expect(Dir.glob('*')).to eq([path])
    end

    it 'creates the file when it does not exist' do
      described_class.replace_file_contents('missing.rb', 'created')

      expect(File.read('missing.rb')).to eq('created')
    end

    it 'keeps the original contents and raises when the disk is full while writing the temporary file' do
      allow(File).to receive(:write).and_raise(Errno::ENOSPC)

      expect do
        described_class.replace_file_contents(path, 'replaced')
      end.to raise_error(Errno::ENOSPC)
      expect(File.read(path)).to eq("original\n")
      expect(Dir.glob('*')).to eq([path])
    end

    it 'falls back to a direct write when the temporary file cannot be created' do
      allow(File).to receive(:write).and_call_original
      allow(File).to receive(:write).with(
        a_string_ending_with('.rubocop.tmp'), anything
      ).and_raise(Errno::EACCES)

      described_class.replace_file_contents(path, 'replaced')

      expect(File.read(path)).to eq('replaced')
      expect(Dir.glob('*')).to eq([path])
    end

    it 'falls back to a direct write when the rename fails' do
      allow(File).to receive(:rename).and_raise(Errno::EACCES)

      described_class.replace_file_contents(path, 'replaced')

      expect(File.read(path)).to eq('replaced')
      expect(Dir.glob('*')).to eq([path])
    end

    if RUBY_ENGINE == 'ruby' && !RuboCop::Platform.windows?
      it 'preserves the file permissions' do
        File.chmod(0o600, path)

        described_class.replace_file_contents(path, 'replaced')

        expect(File.stat(path).mode & 0o777).to eq(0o600)
      end

      it 'rewrites the target of a symlink and keeps the symlink' do
        File.symlink(path, 'link.rb')

        described_class.replace_file_contents('link.rb', 'replaced')

        expect(File).to be_symlink('link.rb')
        expect(File.read(path)).to eq('replaced')
      end

      it 'raises without truncating when the file is read-only', unless: Process.uid.zero? do
        File.chmod(0o444, path)

        expect do
          described_class.replace_file_contents(path, 'replaced')
        end.to raise_error(Errno::EACCES)
        expect(File.read(path)).to eq("original\n")
      end
    end
  end
end
