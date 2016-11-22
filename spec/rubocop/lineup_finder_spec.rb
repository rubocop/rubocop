# frozen_string_literal: true

require 'spec_helper'
require 'pry'

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
    subject(:changed_files_and_lines) { lineup_finder.changed_files_and_lines }

    let(:changed_files) do
      [
        'lib/rubocop/cop/cop.rb',
        'lib/rubocop/lineup_finder.rb'
      ]
    end

    before do
      allow(lineup_finder).to receive(:git_diff_zero_unified) { git_diff }
      allow(lineup_finder).to receive(:changed_files) { changed_files }
    end

    it 'should show added or changed lines for multiple files' do
      added_or_changed_lines = [145, 146, 147, 148, 149, 162, 163]

      changed_files.each do |filename|
        changes_for_file = changed_files_and_lines[filename]
        expect(changes_for_file).to match_array(added_or_changed_lines)
      end
    end
  end
end
