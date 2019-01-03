# frozen_string_literal: true

module RuboCop
  module AST
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

      NO_CHILD_NODES   = %i[arg back_ref blockarg cbase complex const cvar
                            false float gvar int ivar kwrestarg lambda lvar nil
                            nth_ref rational redo regopt restarg retry self
                            shadowarg str sym true zsuper].freeze
      SOME_CHILD_NODES = %i[alias and and_asgn arg_expr args array begin block
                            block_pass break case casgn class csend cvasgn def
                            defined? defs dstr dsym eflipflop ensure erange for
                            gvasgn hash if iflipflop irange ivasgn kwarg
                            kwbegin kwoptarg kwsplat lvasgn masgn
                            match_current_line match_with_lvasgn mlhs module
                            next not op_asgn optarg or or_asgn pair postexe
                            preexe regexp resbody rescue return sclass send
                            splat super undef until until_post when while
                            while_post xstr yield].freeze

      NO_CHILD_NODES.each do |type|
        module_eval("def on_#{type}(node); end", __FILE__, __LINE__)
      end

      SOME_CHILD_NODES.each do |type|
        module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def on_#{type}(node)
            node.children.each do |child|
              next if child.nil?
              next if child.is_a?(Symbol)

              send(:"on_\#{child.type}", child)
            end
            nil
          end
        RUBY
      end
    end
  end
end
