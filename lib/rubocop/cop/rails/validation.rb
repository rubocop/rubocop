# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of old-style attribute validation macros.
      #
      # @example
      #   # bad
      #   validates_acceptance_of :foo
      #   validates_confirmation_of :foo
      #   validates_exclusion_of :foo
      #   validates_format_of :foo
      #   validates_inclusion_of :foo
      #   validates_length_of :foo
      #   validates_numericality_of :foo
      #   validates_presence_of :foo
      #   validates_size_of :foo
      #   validates_uniqueness_of :foo
      #
      #   # good
      #   validates :foo, acceptance: true
      #   validates :foo, confirmation: true
      #   validates :foo, exclusion: true
      #   validates :foo, format: true
      #   validates :foo, inclusion: true
      #   validates :foo, length: true
      #   validates :foo, numericality: true
      #   validates :foo, presence: true
      #   validates :foo, size: true
      #   validates :foo, uniqueness: true
      #
      class Validation < Cop
        MSG = 'Prefer the new style validations `%<prefer>s` over ' \
              '`%<current>s`.'.freeze

        TYPES = %w[
          acceptance
          confirmation
          exclusion
          format
          inclusion
          length
          numericality
          presence
          size
          uniqueness
        ].freeze

        DENYLIST = TYPES.map { |p| "validates_#{p}_of".to_sym }.freeze
        ALLOWLIST = TYPES.map { |p| "validates :column, #{p}: value" }.freeze

        def on_send(node)
          return unless !node.receiver && DENYLIST.include?(node.method_name)

          add_offense(node, location: :selector)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector, 'validates')
            correct_validate_type(corrector, node)
          end
        end

        private

        def message(node)
          format(MSG, prefer: preferred_method(node.method_name),
                      current: node.method_name)
        end

        def preferred_method(method)
          ALLOWLIST[DENYLIST.index(method.to_sym)]
        end

        def correct_validate_type(corrector, node)
          options = node.arguments.find { |arg| !arg.sym_type? }
          validate_type = node.method_name.to_s.split('_')[1]

          if options
            corrector.replace(options.loc.expression,
                              "#{validate_type}: { #{options.source} }")
          else
            corrector.insert_after(node.loc.expression,
                                   ", #{validate_type}: true")
          end
        end
      end
    end
  end
end
