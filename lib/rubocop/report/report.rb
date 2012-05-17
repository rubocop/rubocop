module Rubocop
  module Report
    # Creates a Report object, based on the current settings
    #
    # @param [String] the filename for the report
    # @return [Report] a report object
    def create(file)
      PlainText.new(file)
    end

    module_function :create
  end
end
