# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that models subclass ApplicationRecord with Rails 5.0.
      #
      # @example
      #
      #  # good
      #  class Rails5Model < ApplicationRecord
      #    ...
      #  end
      #
      #  # bad
      #  class Rails4Model < ActiveRecord::Base
      #    ...
      #  end
      class ApplicationRecord < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 5.0

        MSG = 'Models should subclass `ApplicationRecord`.'.freeze
        SUPERCLASS = 'ApplicationRecord'.freeze
        BASE_PATTERN = '(const (const nil? :ActiveRecord) :Base)'.freeze

        include RuboCop::Cop::EnforceSuperclass
      end
    end
  end
end
