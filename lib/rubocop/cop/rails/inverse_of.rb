# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for has_(one|many) and belongs_to associations where
      # ActiveRecord can't automatically determine the inverse association
      # because of a scope or the options used. This can result in unnecessary
      # queries in some circumstances. `:inverse_of` must be manually specified
      # for associations to work in both ways, or set to `false` to opt-out.
      #
      # @example
      #   # bad
      #   class Blog < ApplicationRecord
      #     has_many :recent_posts, -> { order(published_at: :desc) }
      #   end
      #
      #   # good
      #   class Blog < ApplicationRecord
      #     has_many(:recent_posts,
      #       -> { order(published_at: :desc) },
      #       inverse_of: :blog
      #     )
      #   end
      #
      # @see http://guides.rubyonrails.org/association_basics.html#bi-directional-associations
      # @see http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#module-ActiveRecord::Associations::ClassMethods-label-Setting+Inverses
      class InverseOf < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 4.1

        MSG = 'Specify an `:inverse_of` option.'.freeze

        def_node_matcher :association_arguments, <<-PATTERN
          (send nil? {:has_many :has_one :belongs_to} _ $...)
        PATTERN

        def_node_matcher :options_from_argument, <<-PATTERN
          (hash $...)
        PATTERN

        def_node_matcher :conditions_option?, <<-PATTERN
          (pair (sym :conditions) !nil)
        PATTERN

        def_node_matcher :through_option?, <<-PATTERN
          (pair (sym :through) !nil)
        PATTERN

        def_node_matcher :polymorphic_option?, <<-PATTERN
          (pair (sym :polymorphic) !nil)
        PATTERN

        def_node_matcher :foreign_key_option?, <<-PATTERN
          (pair (sym :foreign_key) !nil)
        PATTERN

        def_node_matcher :inverse_of_option?, <<-PATTERN
          (pair (sym :inverse_of) !nil)
        PATTERN

        def on_send(node)
          arguments = association_arguments(node)
          return unless arguments

          options = arguments.flat_map { |arg| options_from_argument(arg) }
          return unless scope?(arguments) ||
                        options_requiring_inverse_of?(options)

          return if options_contain_inverse_of?(options)
          add_offense(node, location: :selector)
        end

        def scope?(arguments)
          arguments.any?(&:block_type?)
        end

        def options_requiring_inverse_of?(options)
          required = options.any? do |opt|
            conditions_option?(opt) ||
              through_option?(opt) ||
              foreign_key_option?(opt)
          end

          return required if target_rails_version >= 5.2
          required || options.any? { |opt| polymorphic_option?(opt) }
        end

        def options_contain_inverse_of?(options)
          options.any? { |opt| inverse_of_option?(opt) }
        end
      end
    end
  end
end
