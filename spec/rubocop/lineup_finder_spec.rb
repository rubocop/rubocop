# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::LineupFinder, :isolated_environment do
  let(:spec_root) do
    File.expand_path('../../..', __FILE__)
  end

  let(:git_diff_name_only) do
    File.read(File.join(spec_root, 'spec/fixtures/git/diff_name_only.txt'))
  end

  let(:git_diff) do
    File.read(File.join(spec_root, 'spec/fixtures/git/diff.txt'))
  end

  let(:lineup_finder) do
    described_class.new
  end

  let(:stubbed_filenames) do
    [
      'lib/rubocop/cop/cop.rb',
      'lib/rubocop/lineup_finder.rb'
    ]
  end

  describe '.changed_files' do
    subject(:changed_files) { lineup_finder.changed_files }

    before do
      allow(lineup_finder).to receive(:git_diff_name_only) do
        git_diff_name_only
      end
    end

    it 'returns absolute paths' do
      expect(changed_files).not_to be_empty
      changed_files.each do |file|
        expect(file.sub(/^[A-Z]:/, '')).to start_with('/')
      end
    end
  end

  describe '.changed_files_and_lines' do
    before do
      allow(lineup_finder).to receive(:git_diff_zero_unified) { git_diff }
      allow(lineup_finder).to receive(:changed_files) { stubbed_filenames }
    end

    it 'should show added or changed lines for multiple files' do
      added_or_changed_lines = [145, 146, 147, 148, 149, 162, 163]

      stubbed_filenames.each do |filename|
        changes_for_file = lineup_finder.changed_lines(filename)
        expect(changes_for_file).to match_array(added_or_changed_lines)
      end
    end
  end

  describe '.changes_at_location?' do
    let(:location) do
      source_buffer = Parser::Source::Buffer.new(stubbed_filenames.first, 145)
      source_buffer.source = "a\n"
      Parser::Source::Range.new(source_buffer, 0, 1)
    end

    before do
      allow(lineup_finder).to receive(:git_diff_zero_unified) { git_diff }
      allow(lineup_finder).to receive(:changed_files) { stubbed_filenames }
    end

    it 'should check if changes occurred on the location file/lines' do
      expect(lineup_finder.changes_at_location?(location)).to be true
    end
  end
end
