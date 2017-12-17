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
      #    # ...
      #  end
      #
      #  # bad
      #  class Rails4Model < ActiveRecord::Base
      #    # ...
      #  end
      class ApplicationRecord < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 5.0

        MSG = 'Models should subclass `ApplicationRecord`.'.freeze
        SUPERCLASS = 'ApplicationRecord'.freeze
        BASE_PATTERN = '(const (const nil? :ActiveRecord) :Base)'.freeze

        # rubocop:disable Layout/ClassStructure
        include RuboCop::Cop::EnforceSuperclass
        # rubocop:enable Layout/ClassStructure

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, self.class::SUPERCLASS)
          end
        end
      end
    end
  end
end
