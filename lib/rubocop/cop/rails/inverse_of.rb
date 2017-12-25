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
      #   # good
      #   class Blog < ApplicationRecord
      #     has_many :posts
      #   end
      #
      #   class Post < ApplicationRecord
      #     belongs_to :blog
      #   end
      #
      # @example
      #   # bad
      #   class Blog < ApplicationRecord
      #     has_many :posts, -> { order(published_at: :desc) }
      #   end
      #
      #   class Post < ApplicationRecord
      #     belongs_to :blog
      #   end
      #
      #   # good
      #   class Blog < ApplicationRecord
      #     has_many(:posts,
      #       -> { order(published_at: :desc) },
      #       inverse_of: :blog
      #     )
      #   end
      #
      #   class Post < ApplicationRecord
      #     belongs_to :blog
      #   end
      #
      #   # good
      #   class Blog < ApplicationRecord
      #     with_options inverse_of: :blog do
      #       has_many :posts, -> { order(published_at: :desc) }
      #     end
      #   end
      #
      #   class Post < ApplicationRecord
      #     belongs_to :blog
      #   end
      #
      # @example
      #   # bad
      #   class Picture < ApplicationRecord
      #     belongs_to :imageable, polymorphic: true
      #   end
      #
      #   class Employee < ApplicationRecord
      #     has_many :pictures, as: :imageable
      #   end
      #
      #   class Product < ApplicationRecord
      #     has_many :pictures, as: :imageable
      #   end
      #
      #   # good
      #   class Picture < ApplicationRecord
      #     belongs_to :imageable, polymorphic: true
      #   end
      #
      #   class Employee < ApplicationRecord
      #     has_many :pictures, as: :imageable, inverse_of: :imageable
      #   end
      #
      #   class Product < ApplicationRecord
      #     has_many :pictures, as: :imageable, inverse_of: :imageable
      #   end
      #
      # @example
      #   # bad
      #   # However, RuboCop can not detect this pattern...
      #   class Physician < ApplicationRecord
      #     has_many :appointments
      #     has_many :patients, through: :appointments
      #   end
      #
      #   class Appointment < ApplicationRecord
      #     belongs_to :physician
      #     belongs_to :patient
      #   end
      #
      #   class Patient < ApplicationRecord
      #     has_many :appointments
      #     has_many :physicians, through: :appointments
      #   end
      #
      #   # good
      #   class Physician < ApplicationRecord
      #     has_many :appointments
      #     has_many :patients, through: :appointments
      #   end
      #
      #   class Appointment < ApplicationRecord
      #     belongs_to :physician, inverse_of: :appointments
      #     belongs_to :patient, inverse_of: :appointments
      #   end
      #
      #   class Patient < ApplicationRecord
      #     has_many :appointments
      #     has_many :physicians, through: :appointments
      #   end
      #
      # @see http://guides.rubyonrails.org/association_basics.html#bi-directional-associations
      # @see http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#module-ActiveRecord::Associations::ClassMethods-label-Setting+Inverses
      class InverseOf < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 4.1

        MSG = 'Specify an `:inverse_of` option.'.freeze

        def_node_matcher :association_recv_arguments, <<-PATTERN
          (send $_ {:has_many :has_one :belongs_to} _ $...)
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

        def_node_matcher :as_option?, <<-PATTERN
          (pair (sym :as) !nil)
        PATTERN

        def_node_matcher :class_name_option?, <<-PATTERN
          (pair (sym :class_name) !nil)
        PATTERN

        def_node_matcher :foreign_key_option?, <<-PATTERN
          (pair (sym :foreign_key) !nil)
        PATTERN

        def_node_matcher :inverse_of_option?, <<-PATTERN
          (pair (sym :inverse_of) !nil)
        PATTERN

        def on_send(node)
          recv, arguments = association_recv_arguments(node)
          return unless arguments
          with_options = with_options_arguments(recv, node)

          options = arguments.concat(with_options).flat_map do |arg|
            options_from_argument(arg)
          end
          return if options_ignoring_inverse_of?(options)

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
              class_name_option?(opt) ||
              foreign_key_option?(opt)
          end

          return required if target_rails_version >= 5.2
          required || options.any? { |opt| as_option?(opt) }
        end

        def options_ignoring_inverse_of?(options)
          options.any? do |opt|
            through_option?(opt) || polymorphic_option?(opt)
          end
        end

        def options_contain_inverse_of?(options)
          options.any? { |opt| inverse_of_option?(opt) }
        end

        def with_options_arguments(recv, node)
          blocks = node.each_ancestor(:block).select do |block|
            block.send_node.command?(:with_options) &&
              same_context_in_with_options?(block.arguments.first, recv)
          end
          blocks.flat_map { |n| n.send_node.arguments }
        end

        def same_context_in_with_options?(arg, recv)
          return true if arg.nil? && recv.nil?
          arg && recv && arg.children[0] == recv.children[0]
        end
      end
    end
  end
end
