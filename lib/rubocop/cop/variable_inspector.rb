# encoding: utf-8

module Rubocop
  module Cop
    # This module provides a way to track local variables and scopes of Ruby.
    # This is intended to be used as mix-in, and the user class may override
    # some of hook methods.
    module VariableInspector
      VARIABLE_ASSIGNMENT_TYPES = [:lvasgn].freeze
      ARGUMENT_DECLARATION_TYPES = [
        :arg, :optarg, :restarg, :blockarg,
        :kwarg, :kwoptarg, :kwsplatarg,
        :shadowarg
      ].freeze
      VARIABLE_DECLARATION_TYPES =
        (VARIABLE_ASSIGNMENT_TYPES + ARGUMENT_DECLARATION_TYPES).freeze
      VARIABLE_USE_TYPES = [:lvar].freeze
      SCOPE_TYPES = [:module, :class, :sclass, :def, :defs, :block].freeze

      # A VariableEntry represents existance of a local variable.
      # This holds a variable declaration node,
      # and some states of the variable.
      class VariableEntry
        attr_reader :node
        attr_accessor :used
        alias_method :used?, :used

        def initialize(node)
          unless VARIABLE_DECLARATION_TYPES.include?(node.type)
            fail ArgumentError,
                 "Node type must be any of #{VARIABLE_DECLARATION_TYPES}, " +
                 "passed #{node.type}"
          end
          @node = node
          @used = false
        end

        def name
          @node.children.first
        end
      end

      # A Scope represents a context of local variable visibility.
      # This is a place where local variables belong to.
      # A scope instance holds a scope node and variable entries.
      class Scope
        attr_reader :node, :variable_entries

        def initialize(node)
          # Accept begin node for top level scope.
          unless SCOPE_TYPES.include?(node.type) || node.type == :begin
            fail ArgumentError,
                 "Node type must be any of #{SCOPE_TYPES}, " +
                 "passed #{node.type}"
          end
          @node = node
          @variable_entries = {}
        end
      end

      # A VariableTable manages the lifetime of all scopes and local variables
      # in a program.
      # This holds scopes as stack structure, and provides a way to add local
      # variables to current scope and find local variables by considering
      # variable visibility of the current scope.
      class VariableTable
        def initialize(hook_receiver = nil)
          @hook_receiver = hook_receiver
        end

        def invoke_hook(hook_name, *args)
          @hook_receiver.send(hook_name, *args) if @hook_receiver
        end

        def scope_stack
          @scope_stack ||= []
        end

        def push_scope(scope_node)
          scope = Scope.new(scope_node)
          invoke_hook(:before_entering_scope, scope)
          scope_stack.push(scope)
          invoke_hook(:after_entering_scope, scope)
          scope
        end

        def pop_scope
          scope = current_scope
          invoke_hook(:before_leaving_scope, scope)
          scope_stack.pop
          invoke_hook(:after_leaving_scope, scope)
          scope
        end

        def current_scope
          scope_stack.last
        end

        def current_scope_level
          scope_stack.count
        end

        def add_variable_entry(variable_declaration_node)
          entry = VariableEntry.new(variable_declaration_node)
          invoke_hook(:before_declaring_variable, entry)
          current_scope.variable_entries[entry.name] = entry
          invoke_hook(:after_declaring_variable, entry)
          entry
        end

        def find_variable_entry(variable_name)
          # Block allows referencing outer scope variables.
          if current_scope.node.type == :block
            scope_stack.reverse_each do |scope|
              entry = scope.variable_entries[variable_name]
              return entry if entry
            end
            nil
          else
            current_scope.variable_entries[variable_name]
          end
        end
      end

      # This provides a way to scan all nodes only in current scope.
      class NodeScanner
        def self.scan_nodes_in_scope(origin_node, &block)
          new.scan_nodes_in_scope(origin_node, &block)
        end

        def initialize
          @node_index = -1
        end

        def scan_nodes_in_scope(origin_node, &block)
          origin_node.children.each do |child|
            next unless child.is_a?(Parser::AST::Node)

            node = child
            @node_index += 1

            catch(:skip_children) do
              yield node, @node_index

              # Do not go into inner scope.
              unless SCOPE_TYPES.include?(node.type)
                scan_nodes_in_scope(node, &block)
              end
            end
          end
        end
      end

      def variable_table
        @variable_table ||= VariableTable.new(self)
      end

      # Starting point.
      def inspect_variables(root_node)
        return unless root_node

        # Wrap with begin node if it's standalone node.
        unless root_node.type == :begin
          root_node = Parser::AST::Node.new(:begin, [root_node])
        end

        inspect_variables_in_scope(root_node)
      end

      # This is called for each scope recursively.
      def inspect_variables_in_scope(scope_node)
        variable_table.push_scope(scope_node)

        NodeScanner.scan_nodes_in_scope(scope_node) do |node, index|
          if scope_node.type == :block && index == 0 && node.type == :send
            # Avoid processing method argument nodes of outer scope
            # in current block scope.
            # See #process_node.
            throw :skip_children
          elsif [:sclass, :defs].include?(scope_node.type) && index == 0
            throw :skip_children
          end

          process_node(node)
        end

        variable_table.pop_scope
      end

      def process_node(node)
        case node.type
        when *ARGUMENT_DECLARATION_TYPES
          variable_table.add_variable_entry(node)
        when *VARIABLE_ASSIGNMENT_TYPES
          variable_name = node.children.first
          variable_entry = variable_table.find_variable_entry(variable_name)
          if variable_entry
            variable_entry.used = true
          else
            variable_table.add_variable_entry(node)
          end
        when *VARIABLE_USE_TYPES
          variable_name = node.children.first
          variable_entry = variable_table.find_variable_entry(variable_name)
          unless variable_entry
            fail "Using undeclared local variable \"#{variable_name}\" " +
                 "at #{node.loc.expression}, #{node.inspect}"
          end
          variable_entry.used = true
        when :block
          # The variable foo belongs to the top level scope,
          # but in AST, it's under the block node.
          #
          # Ruby:
          #   some_method(foo = 1) do
          #   end
          #   puts foo
          #
          # AST:
          #   (begin
          #     (block
          #       (send nil :some_method
          #         (lvasgn :foo
          #           (int 1)))
          #       (args) nil)
          #     (send nil :puts
          #       (lvar :foo)))
          #
          # So the nodes of the method argument need to be processed
          # in current scope before dive into the block scope.
          NodeScanner.scan_nodes_in_scope(node.children.first) do |n|
            process_node(n)
          end
          # Now go into the block scope.
          inspect_variables_in_scope(node)
        when :sclass, :defs
          # Same thing.
          #
          # Ruby:
          #   instance = Object.new
          #   class << instance
          #     foo = 1
          #   end
          #
          # AST:
          #   (begin
          #     (lvasgn :instance
          #       (send
          #         (const nil :Object) :new))
          #     (sclass
          #       (lvar :instance)
          #       (begin
          #         (lvasgn :foo
          #           (int 1))
          process_node(node.children.first)
          inspect_variables_in_scope(node)
        when *SCOPE_TYPES
          inspect_variables_in_scope(node)
        end
      end

      # Hooks

      def before_entering_scope(scope)
      end

      def after_entering_scope(scope)
      end

      def before_leaving_scope(scope)
      end

      def after_leaving_scope(scope)
      end

      def before_declaring_variable(variable_entry)
      end

      def after_declaring_variable(variable_entry)
      end
    end
  end
end
