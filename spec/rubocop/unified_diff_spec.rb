# frozen_string_literal: true

RSpec.describe RuboCop::UnifiedDiff do
  def diff(old_source, new_source, path = 'example.rb')
    described_class.new(path, old_source, new_source).to_s
  end

  it 'returns an empty string for identical sources' do
    expect(diff("a\nb\n", "a\nb\n")).to eq('')
  end

  it 'names both sides of the diff after the path' do
    expect(diff("a\n", "b\n", 'lib/example.rb')).to start_with(<<~DIFF)
      --- a/lib/example.rb
      +++ b/lib/example.rb
    DIFF
  end

  it 'reports a changed line as a deletion followed by an insertion' do
    expect(diff("a\nb\nc\n", "a\nB\nc\n")).to eq(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -1,3 +1,3 @@
       a
      -b
      +B
       c
    DIFF
  end

  it 'reports inserted lines' do
    expect(diff("a\nb\n", "a\nx\ny\nb\n")).to eq(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -1,2 +1,4 @@
       a
      +x
      +y
       b
    DIFF
  end

  it 'reports deleted lines' do
    expect(diff("a\nb\nc\n", "a\nc\n")).to eq(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -1,3 +1,2 @@
       a
      -b
       c
    DIFF
  end

  it 'anchors an insertion into an empty file to line 0' do
    expect(diff('', "a\n")).to eq(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -0,0 +1 @@
      +a
    DIFF
  end

  it 'marks a missing newline at the end of the file' do
    expect(diff("a\nb", "a\nB")).to eq(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -1,2 +1,2 @@
       a
      -b
      \\ No newline at end of file
      +B
      \\ No newline at end of file
    DIFF
  end

  it 'surrounds each change with three lines of context' do
    old_source = (1..12).map { |number| "#{number}\n" }.join
    new_source = old_source.sub("2\n", "two\n")

    expect(diff(old_source, new_source)).to eq(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -1,5 +1,5 @@
       1
      -2
      +two
       3
       4
       5
    DIFF
  end

  it 'reports distant changes as separate hunks' do
    old_source = (1..20).map { |number| "#{number}\n" }.join
    new_source = old_source.sub("2\n", "two\n").sub("18\n", "eighteen\n")

    expect(diff(old_source, new_source)).to eq(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -1,5 +1,5 @@
       1
      -2
      +two
       3
       4
       5
      @@ -15,6 +15,6 @@
       15
       16
       17
      -18
      +eighteen
       19
       20
    DIFF
  end

  it 'merges changes whose context overlaps into one hunk' do
    old_source = (1..10).map { |number| "#{number}\n" }.join
    new_source = old_source.sub("3\n", "three\n").sub("6\n", "six\n")

    expect(diff(old_source, new_source).scan('@@ -').size).to eq(1)
  end

  it 'reports a wholly rewritten region as one replacement' do
    old_source = (1..600).map { |number| "old #{number}\n" }.join
    new_source = (1..600).map { |number| "new #{number}\n" }.join
    result = diff(old_source, new_source)

    expect(result.lines.count { |line| line.start_with?('-') && !line.start_with?('---') })
      .to eq(600)
    expect(result.lines.count { |line| line.start_with?('+') && !line.start_with?('+++') })
      .to eq(600)
  end

  it 'diffs a large file with few changes quickly' do
    old_source = (1..5000).map { |number| "line #{number}\n" }.join
    new_source = old_source.sub("line 4000\n", "LINE 4000\n")

    expect(diff(old_source, new_source)).to eq(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -3997,7 +3997,7 @@
       line 3997
       line 3998
       line 3999
      -line 4000
      +LINE 4000
       line 4001
       line 4002
       line 4003
    DIFF
  end
end
