# encoding: utf-8
# frozen_string_literal: true

require 'json'

module RuboCop
  # Converts RuboCop objects to and from the serialization format JSON.
  class CachedData
    def initialize(filename)
      @filename = filename
    end

    def from_json(text)
      deserialize_offenses(JSON.load(text))
    end

    def to_json(offenses)
      JSON.dump(offenses.map { |o| serialize_offense(o) })
    end

    private

    def serialize_offense(offense)
      # JSON.dump will fail if the offense message contains text which is not
      # valid UTF-8
      message = offense.message
      message = if message.respond_to?(:scrub)
                  message.scrub
                else
                  message.chars.select(&:valid_encoding?).join
                end

      {
        # Calling #to_s here ensures that the serialization works when using
        # other json serializers such as Oj. Some of these gems do not call
        # #to_s implicitly.
        severity: offense.severity.to_s,
        location: {
          begin_pos: offense.location.begin_pos,
          end_pos: offense.location.end_pos
        },
        message:  message,
        cop_name: offense.cop_name,
        status:   offense.status
      }
    end

    # Restore an offense object loaded from a JSON file.
    def deserialize_offenses(offenses)
      source_buffer = Parser::Source::Buffer.new(@filename)
      source_buffer.read
      offenses.map! do |o|
        location = Parser::Source::Range.new(source_buffer,
                                             o['location']['begin_pos'],
                                             o['location']['end_pos'])
        Cop::Offense.new(o['severity'], location,
                         # We know that we wrote a UTF-8 encoded string to the
                         # cache file, so it's safe to force-encode it back to
                         # UTF-8 if it happens to be ASCII-8BIT.
                         o['message'].force_encoding('UTF-8'),
                         o['cop_name'], o['status'].to_sym)
      end
    end
  end
end
