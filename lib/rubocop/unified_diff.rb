# frozen_string_literal: true

module RuboCop
  # Renders a unified diff between two versions of a file's source.
  #
  # RuboCop has no diffing dependency and this output is meant to be read by
  # people (and occasionally piped into `git apply`), so the goal is a diff
  # that is correct and readable, not one that matches `diff -u` byte for byte.
  #
  # @api private
  class UnifiedDiff
    CONTEXT_LINES = 3
    NO_NEWLINE_MARKER = "\\ No newline at end of file\n"

    # Finding a minimal diff costs time and memory proportional to the square
    # of the number of edits. Past this many edits the file was rewritten
    # rather than corrected, so the changed region is reported as a single
    # replacement instead.
    MAX_EDIT_DISTANCE = 400

    def initialize(path, old_source, new_source)
      @path = path
      @old_lines = old_source.lines
      @new_lines = new_source.lines
    end

    # @return [String] the diff, or an empty string when the sources are identical
    def to_s
      return '' if @old_lines == @new_lines

      hunks = hunks_for(edit_script)
      return '' if hunks.empty?

      ["--- a/#{@path}\n", "+++ b/#{@path}\n", *hunks].join
    end

    private

    def edit_script
      prefix = common_prefix_length
      suffix = common_suffix_length(prefix)
      old_last = @old_lines.length - suffix
      new_last = @new_lines.length - suffix

      [
        *@old_lines[0...prefix].map { |line| [:equal, line] },
        *middle_script(@old_lines[prefix...old_last], @new_lines[prefix...new_last]),
        *@old_lines[old_last..].map { |line| [:equal, line] }
      ]
    end

    def common_prefix_length
      length = 0
      length += 1 while length < @old_lines.length && @old_lines[length] == @new_lines[length]
      length
    end

    def common_suffix_length(prefix)
      length = 0
      max = [@old_lines.length, @new_lines.length].min - prefix
      while length < max &&
            @old_lines[@old_lines.length - 1 - length] == @new_lines[@new_lines.length - 1 - length]
        length += 1
      end
      length
    end

    def middle_script(old_lines, new_lines)
      # The region that actually differs is diffed on its own, so the rest of
      # the algorithm works on these two slices rather than the whole file.
      @from_lines = old_lines
      @to_lines = new_lines

      myers_script ||
        [*old_lines.map { |line| [:delete, line] }, *new_lines.map { |line| [:insert, line] }]
    end

    # Myers' diff algorithm. Each round `d` extends the furthest reaching path
    # for every diagonal `k`; the first path to reach the end of both sources
    # is a shortest edit script, which is then reconstructed from the saved
    # rounds. Returns `nil` when the sources are too different to bother.
    def myers_script
      trace = []
      furthest = Hash.new(0)
      max_distance = [@from_lines.length + @to_lines.length, MAX_EDIT_DISTANCE].min

      0.upto(max_distance) do |distance|
        trace << furthest.dup

        (-distance).step(distance, 2) do |diagonal|
          furthest[diagonal] = advance(furthest, diagonal, distance)

          return backtrack(trace) if reached_end?(furthest[diagonal], diagonal)
        end
      end

      nil
    end

    def reached_end?(old_index, diagonal)
      old_index >= @from_lines.length && old_index - diagonal >= @to_lines.length
    end

    # Picks the better of the two paths reaching this diagonal, then follows
    # the diagonal as far as the lines match.
    def advance(furthest, diagonal, distance)
      old_index = start_of_path(furthest, diagonal, distance)

      follow_diagonal(old_index, old_index - diagonal)
    end

    # A path arrives at this diagonal either from the one above it (having
    # inserted a line) or the one below it (having deleted one); whichever
    # reached further wins.
    def previous_diagonal(furthest, diagonal, distance)
      if diagonal == -distance ||
         (diagonal != distance && furthest[diagonal - 1] < furthest[diagonal + 1])
        diagonal + 1
      else
        diagonal - 1
      end
    end

    def start_of_path(furthest, diagonal, distance)
      previous = previous_diagonal(furthest, diagonal, distance)

      previous > diagonal ? furthest[previous] : furthest[previous] + 1
    end

    # Matching lines cost nothing, so the path slides along them for free.
    def follow_diagonal(old_index, new_index)
      while old_index < @from_lines.length && new_index < @to_lines.length &&
            @from_lines[old_index] == @to_lines[new_index]
        old_index += 1
        new_index += 1
      end

      old_index
    end

    def backtrack(trace)
      script = []
      position = [@from_lines.length, @to_lines.length]

      trace.each_with_index.reverse_each do |furthest, distance|
        previous = previous_position(furthest, distance, *position)
        position = walk_diagonal(script, position, previous)
        next if distance.zero?

        position = record_edit(script, position, previous)
      end

      script
    end

    # Both sides step back together for as long as their lines match.
    def walk_diagonal(script, position, previous)
      old_index, new_index = position

      while old_index > previous[0] && new_index > previous[1]
        old_index -= 1
        new_index -= 1
        script.unshift([:equal, @from_lines[old_index]])
      end

      [old_index, new_index]
    end

    def record_edit(script, position, previous)
      old_index, new_index = position

      if old_index == previous[0]
        new_index -= 1
        script.unshift([:insert, @to_lines[new_index]])
      else
        old_index -= 1
        script.unshift([:delete, @from_lines[old_index]])
      end

      [old_index, new_index]
    end

    def previous_position(furthest, distance, old_index, new_index)
      previous = previous_diagonal(furthest, old_index - new_index, distance)
      previous_old = furthest[previous]

      [previous_old, previous_old - previous]
    end

    def hunks_for(script)
      changed = script.each_index.reject { |index| script[index].first == :equal }
      return [] if changed.empty?

      ranges_for(changed, script.length).map { |range| hunk(script, range) }
    end

    # Every change is shown with a few lines of context around it, and changes
    # whose context would overlap are shown as a single hunk.
    def ranges_for(changed, script_length)
      ranges = []

      changed.each do |index|
        first = [index - CONTEXT_LINES, 0].max
        last = [index + CONTEXT_LINES, script_length - 1].min

        if ranges.last && first <= ranges.last.last + 1
          ranges[-1] = (ranges.last.first..last)
        else
          ranges << (first..last)
        end
      end

      ranges
    end

    def hunk(script, range)
      old_start, new_start = start_positions(script, range.first)
      old_count = script[range].count { |kind, _| kind != :insert }
      new_count = script[range].count { |kind, _| kind != :delete }
      body = script[range].map { |kind, line| formatted_line(kind, line) }

      [
        "@@ -#{position(old_start, old_count)} +#{position(new_start, new_count)} @@\n",
        *body
      ].join
    end

    def start_positions(script, index)
      old_line = 1
      new_line = 1

      script[0...index].each do |entry|
        old_line += 1 unless entry.first == :insert
        new_line += 1 unless entry.first == :delete
      end

      [old_line, new_line]
    end

    # An empty side is anchored to the line it follows, which is how `diff`
    # reports a pure insertion or deletion, and a single line drops the count.
    def position(start, count)
      case count
      when 0 then "#{start - 1},0"
      when 1 then start.to_s
      else "#{start},#{count}"
      end
    end

    def formatted_line(kind, line)
      marker = { equal: ' ', delete: '-', insert: '+' }.fetch(kind)
      return "#{marker}#{line}" if line.end_with?("\n")

      "#{marker}#{line}\n#{NO_NEWLINE_MARKER}"
    end
  end
end
