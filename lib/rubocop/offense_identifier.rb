# frozen_string_literal: true

module RuboCop
  OffenseIdentifier = Struct.new(:path, :line, :column, :cop_name) do
    def self.parse(identifier_string)
      path, line, column, cop_name = *identifier_string.split(':')
      new(path, line.to_i, column.to_i, cop_name)
    end
  end
end
