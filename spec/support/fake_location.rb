# frozen_string_literal: true

# Tests may use this to fake out a location structure in an Offense.
FakeLocation = Struct.new(:line, :column, :last_line, keyword_init: true) do
  alias_method :first_line, :line

  def initialize(line:, column:, last_line: nil)
    super(line: line, column: column, last_line: last_line || line)
  end
end
