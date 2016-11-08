# frozen_string_literal: true

require 'spec_helper'
require 'pry'

describe RuboCop::LineupFinder, :isolated_environment do

  subject(:lineup_finder) do
    subj = described_class.new
    allow(subj).to receive(:git_diff_name_only) {
      <<-END
.gitignore
lib/rubocop/cop/cop.rb
lib/rubocop/lineup_finder.rb
      END
    }
    allow(subj).to receive(:git_diff_zero_unified).with('.gitignore').and_return (
      <<-END
diff --git a/.gitignore b/.gitignore
index 2f63bfd..7a9a461 100644
--- a/.gitignore
+++ b/.gitignore
@@ -36 +36 @@ TAGS
-#.DS_Store
+.DS_Store
      END
    )
    allow(subj).to receive(:git_diff_zero_unified).with('lib/rubocop/cop/cop.rb').and_return (
      <<-END
diff --git a/lib/rubocop/cop/cop.rb b/lib/rubocop/cop/cop.rb
index 16ed2d3..0b0b8a8 100644
--- a/lib/rubocop/cop/cop.rb
+++ b/lib/rubocop/cop/cop.rb
@@ -169 +168,0 @@ module RuboCop
-
@@ -171,0 +171,3 @@ module RuboCop
+        intersection = RuboCop::LineupFinder.new.changed_files_and_lines[location.source_buffer.name] & Array(location.first_line..location.last_line)
+        return if intersection && intersection.empty?
+
      END
    )
    allow(subj).to receive(:git_diff_zero_unified).with('lib/rubocop/lineup_finder.rb').and_return (
      <<-END
diff --git a/lib/rubocop/lineup_finder.rb b/lib/rubocop/lineup_finder.rb
index f53131e..58eb6f1 100644
--- a/lib/rubocop/lineup_finder.rb
+++ b/lib/rubocop/lineup_finder.rb
@@ -7 +6,0 @@ module RuboCop
-  class LineupFinder
@@ -17,0 +17,11 @@ module RuboCop
+    def changed_line_ranges(file)
+      git_diff_zero_unified(file)
+      .each_line
+      .grep(/@@ -(\d+)(?:,)?(\d+)? \+(\d+)(?:,)?(\d+)? @@/) {
+        [
+          Regexp.last_match[3].to_i,
+          (Regexp.last_match[4] || 1).to_i
+        ]
+      }
+    end
+
@@ -21 +31 @@ module RuboCop
-          [file, line_change_info(file)]
+          [file, changed_line_ranges(file)]
@@ -26,2 +36,2 @@ module RuboCop
-        diff_info.collect do |filename, line_change_info|
-          mask = line_change_info.collect do |changed_line_number, number_of_changed_lines|
+        diff_info.collect do |filename, changed_line_ranges|
+          mask = changed_line_ranges.collect do |changed_line_number, number_of_changed_lines|
@@ -40,0 +51,4 @@ module RuboCop
+
+    def git_diff_zero_unified(file)
+      `git diff -U0 HEAD file`
+    end
      END
    )
    subj
  end

  let(:changed_files) { lineup_finder.changed_files }
  it "returns absolute paths" do
    expect(changed_files).not_to be_empty
    changed_files.each do |file|
      expect(file.sub(/^[A-Z]:/, '')).to start_with('/')
    end
  end

  it "should parse changes, additions, and deletions" do
    allow(lineup_finder).to receive(:changed_files).and_return ([
      '.gitignore',
      'lib/rubocop/cop/cop.rb',
      'lib/rubocop/lineup_finder.rb',
    ])
    expect(lineup_finder.changed_line_ranges('lib/rubocop/lineup_finder.rb')).to eq(
      [
        [6, 0],
        [17, 11],
        [31, 1],
        [36, 2],
        [51, 4],
      ]
    )
    changed_lines = (17..27).to_a + [31, 36, 37, 51, 52, 53, 54]
    expect(lineup_finder.changed_files_and_lines['lib/rubocop/lineup_finder.rb'].sort).to eq(changed_lines.sort)
  end
end
