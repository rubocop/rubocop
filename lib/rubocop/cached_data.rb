# encoding: utf-8

module RuboCop
  # Converts RuboCop objects to and from the serialization format JSON.
  class CachedData
    def initialize(filename)
      @filename = filename
    end

    def from_json(text)
      offenses, disabled_line_ranges, comments = JSON.load(text)
      deserialize_offenses(offenses)
      deserialize_disabled_line_ranges(disabled_line_ranges)
      deserialize_comments(comments)
      [offenses, disabled_line_ranges, comments]
    end

    def to_json(offenses, disabled_line_ranges, comments)
      comments ||= []
      JSON.dump([offenses.map { |o| serialize_offense(o) },
                 disabled_line_ranges,
                 comments.map { |c| serialize_comment(c) }])
    end

    private

    # Return a representation of a comment suitable for storing in JSON format.
    def serialize_comment(comment)
      expr = comment.loc.expression
      expr.begin_pos...expr.end_pos
    end

    def serialize_offense(offense)
      {
        severity: offense.severity,
        location: {
          begin_pos: offense.location.begin_pos,
          end_pos: offense.location.end_pos
        },
        message:  offense.message,
        cop_name: offense.cop_name,
        status:   offense.status
      }
    end

    # Restore an offense object loaded from a JSON file.
    def deserialize_offenses(offenses)
      offenses.map! do |o|
        source_buffer = Parser::Source::Buffer.new(@filename)
        source_buffer.read
        location = Parser::Source::Range.new(source_buffer,
                                             o['location']['begin_pos'],
                                             o['location']['end_pos'])
        Cop::Offense.new(o['severity'], location, o['message'], o['cop_name'],
                         o['status'].to_sym)
      end
    end

    def deserialize_disabled_line_ranges(disabled_line_ranges)
      disabled_line_ranges.each do |cop_name, line_ranges|
        disabled_line_ranges[cop_name] = line_ranges.map do |line_range|
          case line_range
          when /(\d+)\.\.(\d+)/
            Regexp.last_match(1).to_i..Regexp.last_match(2).to_i
          when /(\d+)\.\.Infinity/
            Regexp.last_match(1).to_i..Float::INFINITY
          else
            fail "Unknown range: #{line_range}"
          end
        end
      end
    end

    def deserialize_comments(comments)
      comments.map! do |c|
        source_buffer = Parser::Source::Buffer.new(@filename)
        source_buffer.read
        c =~ /(\d+)\.\.\.(\d+)/
        range = Parser::Source::Range.new(source_buffer,
                                          Regexp.last_match(1).to_i,
                                          Regexp.last_match(2).to_i)
        Parser::Source::Comment.new(range)
      end
    end
  end
end
