# frozen_string_literal: true

require 'spec_helper'
require 'pry'

describe RuboCop::LineupFinder, :isolated_environment do

  subject(:lineup_finder) do
    subj = described_class.new
    allow(subj).to receive(:git_diff_name_only) {
      <<-END
.gitignore
lib/rubocop.rb
lib/rubocop/options.rb
spec/rubocop/options_spec.rb
      END
    }
    subj
  end

  let(:changed_files) { lineup_finder.changed_files }
  it "returns absolute paths" do
    expect(changed_files).not_to be_empty
    changed_files.each do |file|
      expect(file.sub(/^[A-Z]:/, '')).to start_with('/')
    end
  end
end
