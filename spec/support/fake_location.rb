# frozen_string_literal: true

# Tests may use this to fake out a location structure in an Offense.
FakeLocation = Struct.new(:line, :column, keyword_init: true)
