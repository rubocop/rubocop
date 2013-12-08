# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for setter call to local variable as the final
      # expression of a function definition.
      #
      # @example
      #
      #  def something
      #    x = Something.new
      #    x.attr = 5
      #  end
      class UselessSetterCall < Cop
        include CheckMethods

        MSG = 'Useless setter call to local variable %s.'
        ASSIGNMENT_TYPES = [:lvasgn, :ivasgn, :cvasgn, :gvasgn].freeze

        private

        def check(_node, _method_name, args, body)
          return unless body

          if body.type == :begin
            expression = body.children
          else
            expression = body
          end

          last_expr = expression.is_a?(Array) ? expression.last : expression

          return unless setter_call_to_local_variable?(last_expr)

          tracker = MethodVariableTracker.new(args, body)
          receiver, = *last_expr
          var_name, = *receiver
          return if tracker.contain_object_passed_as_argument?(var_name)

          add_offence(receiver,
                      :name,
                      MSG.format(receiver.loc.name.source))
        end

        def setter_call_to_local_variable?(node)
          return unless node && node.type == :send
          receiver, method, _args = *node
          return unless receiver && receiver.type == :lvar
          method =~ /\w=$/
        end

        # This class tracks variable assignments in a method body
        # and if a variable contains object passed as argument at the end of
        # the method.
        class MethodVariableTracker
          def initialize(args_node, body_node)
            @args_node = args_node
            @body_node = body_node
          end

          def contain_object_passed_as_argument?(variable_name)
            return @table[variable_name] if @table

            @table = {}

            @args_node.children.each do |arg_node|
              arg_name, = *arg_node
              @table[arg_name] = true
            end

            scan(@body_node) do |node|
              case node.type
              when :masgn
                process_multiple_assignment(node)
              when :or_asgn, :and_asgn
                process_logical_operator_assignment(node)
              when :op_asgn
                process_binary_operator_assignment(node)
              when *ASSIGNMENT_TYPES
                _, rhs_node = *node
                process_assignment(node, rhs_node)
              end
            end

            @table[variable_name]
          end

          def scan(node, &block)
            catch(:skip_children) do
              yield node

              node.children.each do |child|
                next unless child.is_a?(Parser::AST::Node)
                scan(child, &block)
              end
            end
          end

          def process_multiple_assignment(masgn_node)
            mlhs_node, mrhs_node = *masgn_node

            mlhs_node.children.each_with_index do |lhs_node, index|
              next unless ASSIGNMENT_TYPES.include?(lhs_node.type)

              lhs_variable_name, = *lhs_node
              rhs_node = mrhs_node.children[index]

              if mrhs_node.type == :array && rhs_node
                process_assignment(lhs_variable_name, rhs_node)
              else
                @table[lhs_variable_name] = false
              end
            end

            throw :skip_children
          end

          def process_logical_operator_assignment(asgn_node)
            lhs_node, rhs_node = *asgn_node
            return unless ASSIGNMENT_TYPES.include?(lhs_node.type)
            process_assignment(lhs_node, rhs_node)

            throw :skip_children
          end

          def process_binary_operator_assignment(op_asgn_node)
            lhs_node, = *op_asgn_node
            return unless ASSIGNMENT_TYPES.include?(lhs_node.type)
            lhs_variable_name, = *lhs_node
            @table[lhs_variable_name] = false

            throw :skip_children
          end

          def process_assignment(asgn_node, rhs_node)
            lhs_variable_name, = *asgn_node

            if [:lvar, :ivar, :cvar, :gvar].include?(rhs_node.type)
              rhs_variable_name, = *rhs_node
              @table[lhs_variable_name] = @table[rhs_variable_name]
            else
              @table[lhs_variable_name] = false
            end
          end
        end
      end
    end
  end
end
