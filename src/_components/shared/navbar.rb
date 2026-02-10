# frozen_string_literal: true

module Shared
  # Top navigation bar component with responsive mobile menu
  class Navbar < Bridgetown::Component
    def initialize(metadata:, resource:)
      @metadata = metadata
      @resource = resource
    end
  end
end
