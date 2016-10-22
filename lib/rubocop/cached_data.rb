# frozen_string_literal: true

require 'json'

module RuboCop
  # Converts RuboCop objects to and from the serialization format JSON.
  class CachedData
    def initialize(filename)
      @filename = filename
    end

    def from_json(text)
      deserialize_offenses(JSON.parse(text))
    end

    def to_json(offenses)
      JSON.dump(offenses.map { |o| serialize_offense(o) })
    end

    private

    def serialize_offense(offense)
      {
        # Calling #to_s here ensures that the serialization works when using
        # other json serializers such as Oj. Some of these gems do not call
        # #to_s implicitly.
        severity: offense.severity.to_s,
        location: {
          begin_pos: offense.location.begin_pos,
          end_pos: offense.location.end_pos
        },
        message:  message(offense),
        cop_name: offense.cop_name,
        status:   offense.status
      }
    end

    def message(offense)
      # JSON.dump will fail if the offense message contains text which is not
      # valid UTF-8
      message = offense.message
      if message.respond_to?(:scrub)
        message.scrub
      else
        message.chars.select(&:valid_encoding?).join
      end
    end

    # Restore an offense object loaded from a JSON file.
    def deserialize_offenses(offenses)
      source_buffer = Parser::Source::Buffer.new(@filename)
      source_buffer.source = File.read(@filename, encoding: Encoding::UTF_8)
      offenses.map! do |offense|
        location = Parser::Source::Range.new(source_buffer,
                                             offense['location']['begin_pos'],
                                             offense['location']['end_pos'])
        Cop::Offense.new(offense['severity'], location,
                         offense['message'],
                         offense['cop_name'], offense['status'].to_sym)
      end
    end
  end
end
