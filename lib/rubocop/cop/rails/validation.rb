# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of old-style attribute validation macros.
      class Validation < Cop
        MSG = 'Prefer the new style validations `%s` over `%s`.'.freeze

        BLACKLIST = [:validates_acceptance_of,
                     :validates_confirmation_of,
                     :validates_exclusion_of,
                     :validates_format_of,
                     :validates_inclusion_of,
                     :validates_length_of,
                     :validates_numericality_of,
                     :validates_presence_of,
                     :validates_size_of,
                     :validates_uniqueness_of].freeze

        WHITELIST = [
          'validates :column, acceptance: value',
          'validates :column, confirmation: value',
          'validates :column, exclusion: value',
          'validates :column, format: value',
          'validates :column, inclusion: value',
          'validates :column, length: value',
          'validates :column, numericality: value',
          'validates :column, presence: value',
          'validates :column, size: value',
          'validates :column, uniqueness: value'
        ].freeze

        def on_send(node)
          receiver, method_name, *_args = *node
          return unless receiver.nil? && BLACKLIST.include?(method_name)

          add_offense(node,
                      :selector,
                      format(MSG,
                             preferred_method(method_name),
                             method_name))
        end

        private

        def preferred_method(method)
          WHITELIST[BLACKLIST.index(method.to_sym)]
        end
      end
    end
  end
end
