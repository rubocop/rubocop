# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that jobs subclass ApplicationJob with Rails 5.0.
      #
      # @example
      #
      #  # good
      #  class Rails5Job < ApplicationJob
      #    # ...
      #  end
      #
      #  # bad
      #  class Rails4Job < ActiveJob::Base
      #    # ...
      #  end
      class ApplicationJob < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 5.0

        MSG = 'Jobs should subclass `ApplicationJob`.'.freeze
        SUPERCLASS = 'ApplicationJob'.freeze
        BASE_PATTERN = '(const (const nil? :ActiveJob) :Base)'.freeze

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
