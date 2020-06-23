# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for trivial reader/writer methods, that could
      # have been created with the attr_* family of functions automatically.
      #
      # @example
      #   # bad
      #   def foo
      #     @foo
      #   end
      #
      #   def bar=(val)
      #     @bar = val
      #   end
      #
      #   def self.baz
      #     @baz
      #   end
      #
      #   # good
      #   attr_reader :foo
      #   attr_writer :bar
      #
      #   class << self
      #     attr_reader :baz
      #   end
      class TrivialAccessors < Cop
        include AllowedMethods

        MSG = 'Use `attr_%<kind>s` to define trivial %<kind>s methods.'

        def on_def(node)
          return if top_level_node?(node)
          return if in_module_or_instance_eval?(node)
          return if ignore_class_methods? && node.defs_type?

          on_method_def(node)
        end
        alias on_defs on_def

        def autocorrect(node)
          parent = node.parent
          return if parent&.send_type?

          if node.def_type?
            autocorrect_instance(node)
          elsif node.defs_type? && node.children.first.self_type?
            autocorrect_class(node)
          end
        end

        private

        def in_module_or_instance_eval?(node)
          node.each_ancestor(:block, :class, :sclass, :module).each do |pnode|
            case pnode.type
            when :class, :sclass
              return false
            when :module
              return true
            else
              return true if pnode.method?(:instance_eval)
            end
          end
          false
        end

        def on_method_def(node)
          kind = if trivial_reader?(node)
                   'reader'
                 elsif trivial_writer?(node)
                   'writer'
                 end
          return unless kind

          add_offense(node,
                      location: :keyword,
                      message: format(MSG, kind: kind))
        end

        def exact_name_match?
          cop_config['ExactNameMatch']
        end

        def allow_predicates?
          cop_config['AllowPredicates']
        end

        def allow_dsl_writers?
          cop_config['AllowDSLWriters']
        end

        def ignore_class_methods?
          cop_config['IgnoreClassMethods']
        end

        def allowed_method_names
          allowed_methods.map(&:to_sym) + [:initialize]
        end

        def dsl_writer?(method_name)
          !method_name.to_s.end_with?('=')
        end

        def trivial_reader?(node)
          looks_like_trivial_reader?(node) &&
            !allowed_method_name?(node) && !allowed_reader?(node)
        end

        def looks_like_trivial_reader?(node)
          !node.arguments? && node.body && node.body.ivar_type?
        end

        def trivial_writer?(node)
          looks_like_trivial_writer?(node) &&
            !allowed_method_name?(node) && !allowed_writer?(node.method_name)
        end

        def_node_matcher :looks_like_trivial_writer?, <<~PATTERN
          {(def    _ (args (arg ...)) (ivasgn _ (lvar _)))
           (defs _ _ (args (arg ...)) (ivasgn _ (lvar _)))}
        PATTERN

        def allowed_method_name?(node)
          allowed_method_names.include?(node.method_name) ||
            exact_name_match? && !names_match?(node)
        end

        def allowed_writer?(method_name)
          allow_dsl_writers? && dsl_writer?(method_name)
        end

        def allowed_reader?(node)
          allow_predicates? && node.predicate_method?
        end

        def names_match?(node)
          ivar_name, = *node.body

          node.method_name.to_s.sub(/[=?]$/, '') == ivar_name[1..-1]
        end

        def trivial_accessor_kind(node)
          if trivial_writer?(node) &&
             !dsl_writer?(node.method_name)
            'writer'
          elsif trivial_reader?(node)
            'reader'
          end
        end

        def accessor(kind, method_name)
          "attr_#{kind} :#{method_name.to_s.chomp('=')}"
        end

        def autocorrect_instance(node)
          kind = trivial_accessor_kind(node)

          return unless names_match?(node) && !node.predicate_method? && kind

          lambda do |corrector|
            corrector.replace(node,
                              accessor(kind, node.method_name))
          end
        end

        def autocorrect_class(node)
          kind = trivial_accessor_kind(node)

          return unless names_match?(node) && kind

          lambda do |corrector|
            indent = ' ' * node.loc.column
            corrector.replace(
              node.source_range,
              ['class << self',
               "#{indent}  #{accessor(kind, node.method_name)}",
               "#{indent}end"].join("\n")
            )
          end
        end

        def top_level_node?(node)
          node.parent.nil?
        end
      end
    end
  end
end
