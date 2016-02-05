# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  class Node
    # Provides methods for traversing an AST.
    # Does not transform an AST; for that, use Parser::AST::Processor.
    # Override methods to perform custom processing. Remember to call `super`
    # if you want to recursively process descendant nodes.
    module Traversal
      def walk(node)
        return if node.nil?
        send(:"on_#{node.type}", node)
        nil
      end

      NO_CHILD_NODES    = [:true, :false, :nil, :int, :float, :complex,
                           :rational, :str, :sym, :regopt, :self, :lvar,
                           :ivar, :cvar, :gvar, :nth_ref, :back_ref, :cbase,
                           :arg, :restarg, :blockarg, :shadowarg,
                           :kwrestarg, :zsuper, :lambda, :redo, :retry].freeze
      ONE_CHILD_NODE    = [:splat, :kwsplat, :block_pass, :not, :break, :next,
                           :return, :preexe, :postexe, :match_current_line,
                           :defined?, :arg_expr].freeze
      MANY_CHILD_NODES  = [:dstr, :dsym, :xstr, :regexp, :array, :hash, :pair,
                           :irange, :erange, :mlhs, :masgn, :or_asgn, :and_asgn,
                           :undef, :alias, :args, :super, :yield, :or, :and,
                           :while_post, :until_post, :iflipflop, :eflipflop,
                           :match_with_lvasgn, :begin, :kwbegin].freeze
      SECOND_CHILD_ONLY = [:lvasgn, :ivasgn, :cvasgn, :gvasgn, :optarg, :kwarg,
                           :kwoptarg].freeze

      NO_CHILD_NODES.each do |type|
        module_eval("def on_#{type}(node); end")
      end

      ONE_CHILD_NODE.each do |type|
        module_eval(<<-END)
          def on_#{type}(node)
            if (child = node.children[0])
              send(:"on_\#{child.type}", child)
            end
          end
        END
      end

      MANY_CHILD_NODES.each do |type|
        module_eval(<<-END)
          def on_#{type}(node)
            node.children.each { |child| send(:"on_\#{child.type}", child) }
            nil
          end
        END
      end

      SECOND_CHILD_ONLY.each do |type|
        # Guard clause is for nodes nested within mlhs
        module_eval(<<-END)
          def on_#{type}(node)
            if (child = node.children[1])
              send(:"on_\#{child.type}", child)
            end
          end
        END
      end

      def on_const(node)
        return unless (child = node.children[0])
        send(:"on_#{child.type}", child)
      end

      def on_casgn(node)
        children = node.children
        if (child = children[0]) # always const???
          send(:"on_#{child.type}", child)
        end
        return unless (child = children[2])
        send(:"on_#{child.type}", child)
      end

      def on_class(node)
        children = node.children
        child = children[0] # always const???
        send(:"on_#{child.type}", child)
        if (child = children[1])
          send(:"on_#{child.type}", child)
        end
        return unless (child = children[2])
        send(:"on_#{child.type}", child)
      end

      def on_def(node)
        children = node.children
        on_args(children[1])
        return unless (child = children[2])
        send(:"on_#{child.type}", child)
      end

      def on_send(node)
        node.children.each_with_index do |child, i|
          next if i == 1
          send(:"on_#{child.type}", child) if child
        end
        nil
      end

      alias on_csend on_send

      def on_op_asgn(node)
        children = node.children
        child = children[0]
        send(:"on_#{child.type}", child)
        child = children[2]
        send(:"on_#{child.type}", child)
      end

      def on_defs(node)
        children = node.children
        child = children[0]
        send(:"on_#{child.type}", child)
        on_args(children[2])
        return unless (child = children[3])
        send(:"on_#{child.type}", child)
      end

      def on_if(node)
        children = node.children
        child = children[0]
        send(:"on_#{child.type}", child)
        if (child = children[1])
          send(:"on_#{child.type}", child)
        end
        return unless (child = children[2])
        send(:"on_#{child.type}", child)
      end

      def on_while(node)
        children = node.children
        child = children[0]
        send(:"on_#{child.type}", child)
        return unless (child = children[1])
        send(:"on_#{child.type}", child)
      end

      alias on_until  on_while
      alias on_when   on_while
      alias on_module on_while
      alias on_sclass on_while

      def on_block(node)
        children = node.children
        child = children[0]
        send(:"on_#{child.type}", child) # can be send, zsuper...
        on_args(children[1])
        return unless (child = children[2])
        send(:"on_#{child.type}", child)
      end

      def on_case(node)
        node.children.each do |child|
          send(:"on_#{child.type}", child) if child
        end
        nil
      end

      alias on_rescue  on_case
      alias on_resbody on_case
      alias on_ensure  on_case
      alias on_for     on_case
    end
  end
end
