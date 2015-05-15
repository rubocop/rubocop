# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for duplicate methods in classes and modules.
      #
      # @example Duplicate methods in class
      #
      #   class SomeClass
      #     def some_method
      #     end
      #
      #     def some_method
      #     end
      #   end
      #
      # @example Duplicate methods in module
      #
      #   module SomeClass
      #     def some_method
      #     end
      #
      #     def some_method
      #     end
      #   end
      #
      # @example Duplicate class methods in class
      #
      #   class SomeClass
      #     def self.some_method
      #     end
      #
      #     def self.some_method
      #     end
      #   end
      #
      # @example Duplicate private and public methods in class
      #
      #   class SomeClass
      #     def some_method
      #     end
      #
      #     private def some_method
      #     end
      #   end
      class DuplicateMethods < Cop
        MSG = 'Duplicate methods `%s` at lines `%s` detected.'

        def on_class(node)
          _klass_name, _parent, body = *node
          return unless body
          names = method_names(body)
          check_duplicate_methods(names)
        end

        def on_module(node)
          _klass_name, body = *node
          return unless body
          names = method_names(body)
          check_duplicate_methods(names)
        end

        private

        def method_names(body)
          body.child_nodes.map do |node|
            _receiver, node, body  = *node if node.send_type?

            if node.is_a? Symbol
              next if body.nil?
              node = body
            end

            if node.def_type?
              method, _args, _body = *node
            elsif node.defs_type?
              _receiver, method = *node
              method = "self.#{method}"
            end

            method ? [method, node] : nil
          end.compact
        end

        def check_duplicate_methods(names)
          dups = names.each_with_object({}) do |item, accum|
            accum[item[0]] ||= []
            accum[item[0]] << item[1]
          end

          dups.each do |method, nodes|
            next if nodes.size < 2
            lines = nodes.map { |node| node.loc.line }

            add_offense(nodes.last,
                        :keyword,
                        format(MSG, method, lines.join(', ')))
          end
        end
      end
    end
  end
end
