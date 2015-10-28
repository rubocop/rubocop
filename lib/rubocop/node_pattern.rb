# encoding: utf-8

# rubocop:disable Metrics/ClassLength

module RuboCop
  # This class performs a pattern-matching operation on an AST node.
  #
  # Initialize a new `NodePattern` with `NodePattern.new(pattern_string)`, then
  # pass an AST node to `NodePattern#match`. Alternatively, use one of the class
  # macros in `NodePattern::Macros` to define your own pattern-matching method.
  #
  # If the match fails, `nil` will be returned. If the match succeeds, the
  # return value depends on whether a block was provided to `#match`, and
  # whether the pattern contained any "captures" (values which are extracted
  # from a matching AST.)
  #
  # - With block: #match yields the captures (if any) and passes the return
  #               value of the block through.
  # - With no block, but one capture: the capture is returned.
  # - With no block, but multiple captures: captures are returned as an array.
  # - With no captures: #match returns `true`.
  #
  # ## Pattern string format examples
  #
  #    ':sym'              # matches a literal symbol
  #    '1'                 # matches a literal integer
  #    'nil'               # matches a literal nil
  #    'send'              # matches (send ...)
  #    '(send)'            # matches (send)
  #    '(send ...)'        # matches (send ...)
  #    '{send class}'      # matches (send ...) or (class ...)
  #    '({send class})'    # matches (send) or (class)
  #    '(send const)'      # matches (send (const ...))
  #    '(send _ :new)'     # matches (send <anything> :new)
  #    '(send $_ :new)'    # as above, but whatever matches the $_ is captured
  #    '(send $_ $_)'      # you can use as many captures as you want
  #    '(send !const ...)' # ! negates the next part of the pattern
  #    '$(send const ...)' # arbitrary matching can be performed on a capture
  #    '(send _recv _msg)' # wildcards can be named (for readability)
  #    '(send ... :new)'   # you can specifically match against the last child
  #                        # (this only works for the very last)
  #    '(send $...)'       # capture all the children as an array
  #    '(send $... int)'   # capture all children but the last as an array
  #    '(send _x :+ _x)'   # unification is performed on named wildcards
  #                        # (like Prolog variables...)
  #    '(int odd?)'        # words which end with a ? are predicate methods,
  #                        # are are called on the target to see if it matches
  #                        # any Ruby method which the matched object supports
  #                        # can be used
  #    '(int [!1 !2])'     # [] contains multiple patterns, ALL of which must
  #                        # match in that position
  #                        # ({} is pattern union, [] is intersection)
  #    '(send %1 _)'       # % stands for a parameter which must be supplied to
  #                        # #match at matching time
  #                        # it will be compared to the corresponding value in
  #                        # the AST using #==
  #                        # a bare '%' is the same as '%1'
  #
  # You can nest arbitrarily deep:
  #
  #     # matches node parsed from 'Const = Class.new' or 'Const = Module.new':
  #     '(casgn nil const (send (const nil {:Class :Module}) :new)))'
  #     # matches a node parsed from an 'if', with a '==' comparison,
  #     # and no 'else' branch:
  #     '(if (send _ :== _) _ nil)'
  #
  # Note that patterns like 'send' are implemented by calling `#send_type?` on
  # the node being matched, 'const' by `#const_type?`, 'int' by `#int_type?`,
  # and so on. Therefore, if you add methods which are named like
  # `#prefix_type?` to the AST node class, then 'prefix' will become usable as
  # a pattern.
  #
  # Also node that if you need a "guard clause" to protect against possible nils
  # in a certain place in the AST, you can do it like this: `[!nil <pattern>]`
  #
  class NodePattern
    # @private
    Invalid = Class.new(StandardError)

    # @private
    # Builds Ruby code which implements a pattern
    class Compiler
      RSYM      = %r{:(?:[\w+-@_*/?!<>~|%^]+|==|\[\]=?)}
      ID_CHAR   = /[a-zA-Z_]/
      META_CHAR = /\(|\)|\{|\}|\[|\]|\$|\!|\.\.\./
      TOKEN     = /\G(?:\s+|#{META_CHAR}|#{ID_CHAR}+\??|%\d*|\d+|#{RSYM}|.)/

      META      = /\A#{META_CHAR}\Z/
      NODE      = /\A#{ID_CHAR}+\Z/
      PREDICATE = /\A#{ID_CHAR}+\?\Z/
      LITERAL   = /\A(?:#{RSYM}|\d+|nil)\Z/
      WILDCARD  = /\A_#{ID_CHAR}*\Z/
      PARAM     = /\A%\d*\Z/

      # Rather than using (explicit) recursion for nested patterns, we
      # use a state machine with a stack, and run over the tokens in the
      # pattern from left to right, updating state variables as we go.

      def initialize(str, node_var = 'node0')
        @string   = str
        @stack    = []    # when entering (), [], or {}, push state on the stack

        @temps    = 0     # avoid name clashes between temp variables
        @index    = nil   # which position the match is at in ()
        @context  = :root
        @node     = node_var
        @negated  = false # just saw a !

        @captures = 0     # number of captures seen
        @capture  = false # just saw a $
        @cstack   = []    # used only when processing {}

        @terms    = []    # used when building up a && or || expression
        @unify    = {}    # named wildcard -> temp variable number
        @params   = 0     # highest % (param) number seen

        run
      end

      def run
        @string.scan(TOKEN) do |token|
          case token
          when /^\s+/ # do nothing
          when META then meta_token(token)
          when WILDCARD then wildcard(token[1..-1])
          when LITERAL then atom("(#{current_value} == #{token})")
          when PREDICATE then atom("(#{current_node}.#{token})")
          when NODE then atom("((temp=#{current_node}) && temp.#{token}_type?)")
          when PARAM then param(token[1..-1])
          else fail_due_to("invalid token #{token.inspect}")
          end
        end

        fail_due_to('unbalanced pattern') unless @stack.empty?
      end

      def meta_token(token)
        case token
        when '(' then opening_paren
        when ')' then closing_paren
        when '{' then opening_curly
        when '}' then closing_curly
        when '[' then opening_square
        when ']' then closing_square
        when '$' then capture
        when '!' then negate
        when '...' then goto_last_child
        end
      end

      def emit_match_code
        @terms.empty? ? 'true' : @terms.join(' && ')
      end

      def emit_capture_list
        (1..@captures).map { |n| "capture#{n}" }.join(',')
      end

      def emit_retval
        if @captures.zero?
          'true'
        elsif @captures == 1
          'capture1'
        else
          "[#{emit_capture_list}]"
        end
      end

      def emit_param_list
        (1..@params).map { |n| "param#{n}" }.join(',')
      end

      def emit_trailing_param_list
        params = emit_param_list
        params.empty? ? '' : ',' << params
      end

      def emit_method_code
        <<-CODE
          return nil unless #{emit_match_code}
          block_given? ? yield(#{emit_capture_list}) : (return #{emit_retval})
        CODE
      end

      def opening_paren
        if @context != :root && @index == 0
          # ((...) ...) is invalid, since you cannot destructure a node TYPE,
          # you can only destructure child nodes
          # ({(...) ...} ...) is equally invalid, since that would also mean
          # trying to destructure a node type
          fail_due_to('parentheses in invalid position')
        end
        enter_new_context(:sequence)
      end

      def closing_paren
        # when entering (), @terms is initialized with a single entry, so if
        # the parens are empty, there will be only 1 item in @terms
        fail_due_to('empty parentheses') if @terms.one?
        fail_due_to('! before )') if @negated

        if @context != :last_child
          # when inside ( ), context will be either :sequence or :last_child
          # :last_child indicates that we have seen a ... token, which makes
          # us jump to the last child of the destructured node
          # if the ( ) is nested properly, context should be :sequence here
          fail_due_to('unbalanced parentheses') if @context != :sequence
          fail_due_to('$ before )') if @capture
          # since we haven't seen a ..., add a check that there are no
          # remaining children
          add_term "(#{@node}.children.size == #{@index - 1})"
        else
          @terms << "(#{@node}.children.size >= #{@index - 1})" if @index > 1

          if @capture
            # we have a $... pattern, so capture all the remaining children
            @terms << "(capture#{@captures} = " \
              "#{@node}.children[#{@index - 1}..-1])"
            @capture = false
          end
        end

        leave_context("(#{@terms.join(' && ')})")
      end

      def opening_curly
        fail_due_to('nested curly braces') if @context == :union
        enter_new_context(:union)
      end

      def closing_curly
        fail_due_to('unbalanced curly braces') if @context != :union
        # when entering a { }, @terms is initialized with a single
        # expression which stores the current node in a temp variable
        # so if the { } is empty, @terms.size will be 1 right here
        fail_due_to('empty set') if @terms.one?
        fail_due_to('! before }') if @negated
        leave_context("(#{@terms.shift}; #{@terms.join(' || ')})")
      end

      def opening_square
        fail_due_to('nested square brackets') if @context == :intersection
        enter_new_context(:intersection)
      end

      def closing_square
        fail_due_to('unbalanced square brackets') if @context != :intersection
        fail_due_to('empty square brackets') if @terms.one?
        fail_due_to('! before ]') if @negated
        leave_context("(#{@terms.join(' && ')})")
      end

      def capture
        fail_due_to('$ after !') if @negated # $! is OK, but not !$
        fail_due_to('use $[], not [$]') if @context == :intersection
        # check if we are in ( ) and have seen a $... earlier
        # if so, it will capture all the children but the last, and the
        # following part will capture the last child
        maybe_capture_intervening_children
        fail_due_to('repeated $') if @capture
        @captures += 1
        @capture = true
      end

      def negate
        fail_due_to('repeated !') if @negated
        @negated = true
      end

      def wildcard(name)
        fail_due_to('_ inside { ... }') if @context == :union
        fail_due_to('_ inside [ ... ]') if @context == :intersection
        if name.empty?
          atom('true')
        elsif @unify.key?(name)
          # we have already seen a wildcard with this name before
          # so the value it matched the first time will already be stored
          # in a temp. check if this value matches the one stored in the temp
          atom("(#{current_value} == temp#{@unify[name]})")
        else
          n = @unify[name] = (@temps += 1)
          atom("(temp#{n} = #{current_value}; true)")
        end
      end

      def atom(term)
        maybe_capture_intervening_children
        if @context == :last_child
          # this is AFTER a ...
          # so make sure that there are enough children for it to match,
          # without rematching one of the children which already matched
          @terms << "(#{@node}.children.size > #{@index - 1})" if @index > 1
        end
        add_term term
        @index += 1 if @context == :sequence
      end

      def param(number)
        number = number.empty? ? 1 : Integer(number)
        @params = number if number > @params
        atom("(#{current_value} == param#{number})")
      end

      def goto_last_child
        fail_due_to('... repeated') if @context == :last_child
        fail_due_to('... used outside of parens') unless @context == :sequence
        fail_due_to('! before ...') if @negated
        # set @capture to a special value to indicate that we have seen $...
        @capture = :children if @capture
        @context = :last_child
      end

      def enter_new_context(context)
        # just entering (), [], or {}
        # does this pattern appear after ...? if so capture intervening children
        maybe_capture_intervening_children

        if @context == :last_child && @index > 1
          @terms << "(#{@node}.children.size > #{@index - 1})"
        end
        term = "(node#{@temps += 1} = #{current_node})"

        # store state machine vars on the stack
        @stack.push([@node, @index, @terms, @negated, @capture, @captures,
                     @context])

        # "stack frame" -- second slot, which is initialized to 'nil',
        # is a "local variable" used for processing captures within each
        # branch of a {}
        # it stores the value of @captures after processing the first branch
        @cstack.push([@captures, nil]) if context == :union

        # re-initialize state machine vars for new context
        @context = context
        @terms = [term]
        @node = "node#{@temps}"
        @negated = @capture = false
        @index = 0 if context == :sequence
      end

      def leave_context(term)
        fail_due_to('unbalanced pattern') if @stack.empty?

        _, @captures = @cstack.pop if @context == :union

        # why do we pop 'captures' off the stack, but don't store it in
        # @captures? we want to know what @captures was before entering this
        # context, IN CASE it was captured
        # for example, if compiling $(send $...), @captures will be different
        # after processing the children, due to the $...
        # but we need to know the capture # for the OUTER capture
        @node, @index, @terms, @negated, @capture, captures, @context =
          @stack.pop
        add_term(term, captures)
        @index += 1 if @context == :sequence
      end

      def maybe_capture_intervening_children
        # if $... is followed by a final pattern, gather up all the intervening
        # children into a capture before generating code for that pattern
        return unless @context == :last_child && @capture == :children
        @terms << "(capture#{@captures} = #{@node}.children[#{@index - 1}..-2])"
        @capture = false
      end

      def add_term(term, capture_n = @captures)
        ((term = "(!#{term})") && (@negated = false)) if @negated
        if @capture
          term = "((#{term}) && (capture#{capture_n} = #{current_value}; true))"
          @capture = false
        end
        @terms << term

        return unless @context == :union
        # we push a "frame" on cstack for each nested {}
        # this enables us to check after each branch to ensure that they all
        # have the same number of captures
        previous_captures, union_captures = @cstack.last
        if !union_captures
          @cstack.last[1] = @captures
        elsif union_captures != @captures
          fail_due_to('each branch of {} must have same # of captures')
        end
        @captures = previous_captures
      end

      def current_node
        if @context == :last_child
          "#{@node}.children.last"
        elsif @context == :sequence && @index > 0
          "#{@node}.children[#{@index - 1}]"
        else
          @node
        end
      end

      def current_value
        if @context == :sequence && @index == 0
          "#{@node}.type"
        else
          current_node
        end
      end

      def fail_due_to(message)
        fail Invalid, "Couldn't compile due to #{message}. Pattern: #{@string}"
      end
    end

    # Helpers for defining methods based on a pattern string
    module Macros
      # Define a method which applies a pattern to an AST node
      #
      # The new method will return nil if the node does not match
      # If the node matches, and a block is provided, the new method will
      # yield to the block (passing any captures as block arguments).
      # If the node matches, and no block is provided, the new method will
      # return the captures, or `true` if there were none.
      def def_node_matcher(method_name, pattern_str)
        compiler = RuboCop::NodePattern::Compiler.new(pattern_str, 'node')
        src = "def #{method_name}(node" << compiler.emit_trailing_param_list <<
              ');' << compiler.emit_method_code << ';end'
        class_eval(src)
      end

      # Define a method which recurses over the descendants of an AST node,
      # checking whether any of them match the provided pattern
      #
      # If the method name ends with '?', the new method will return `true`
      # as soon as it finds a descendant which matches. Otherwise, it will
      # yield all descendants which match.
      def def_node_search(method_name, pattern_str)
        compiler = RuboCop::NodePattern::Compiler.new(pattern_str, 'node')
        if method_name.to_s.end_with?('?')
          on_match = 'return true'
          prelude = ''
        else
          yieldval = compiler.emit_capture_list
          yieldval = 'node' if yieldval.empty?
          on_match = "yield(#{yieldval})"
          prelude = "return enum_for(:#{method_name},node0) unless block_given?"
        end
        src = <<-END
          def #{method_name}(node0#{compiler.emit_trailing_param_list})
            #{prelude}
            node0.each_node do |node|
              if #{compiler.emit_match_code}
                #{on_match}
              end
            end
            nil
          end
        END
        class_eval(src)
      end
    end

    def initialize(str)
      compiler = Compiler.new(str)
      src = 'def match(node0' << compiler.emit_trailing_param_list << ');' <<
            compiler.emit_method_code << 'end'
      instance_eval(src)
    end
  end
end
