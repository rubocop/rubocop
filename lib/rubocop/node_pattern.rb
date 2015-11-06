# encoding: utf-8

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/CyclomaticComplexity

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
  #    '^^send'            # each ^ ascends one level in the AST
  #                        # so this matches against the grandparent node
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
      META_CHAR = /\(|\)|\{|\}|\[|\]|\$\.\.\.|\$|!|\^|\.\.\./
      TOKEN     = /\G(?:\s+|#{META_CHAR}|#{ID_CHAR}+\??|%\d*|\d+|#{RSYM}|.)/

      NODE      = /\A#{ID_CHAR}+\Z/
      PREDICATE = /\A#{ID_CHAR}+\?\Z/
      LITERAL   = /\A(?:#{RSYM}|\d+|nil)\Z/
      WILDCARD  = /\A_#{ID_CHAR}*\Z/
      PARAM     = /\A%\d*\Z/
      CLOSING   = /\A(?:\)|\}|\])\Z/

      attr_reader :match_code

      def initialize(str, node_var = 'node0')
        @string   = str

        @temps    = 0  # avoid name clashes between temp variables
        @captures = 0  # number of captures seen
        @unify    = {} # named wildcard -> temp variable number
        @params   = 0  # highest % (param) number seen

        run(node_var)
      end

      def run(node_var)
        tokens = @string.scan(TOKEN)
        tokens.reject! { |token| token =~ /\A\s+\Z/ }
        @match_code = compile_expr(tokens, node_var, false)
        fail_due_to('unbalanced pattern') unless tokens.empty?
      end

      def compile_expr(tokens, cur_node, seq_head)
        token = tokens.shift
        case token
        when '('       then compile_seq(tokens, cur_node, seq_head)
        when '{'       then compile_union(tokens, cur_node, seq_head)
        when '['       then compile_intersect(tokens, cur_node, seq_head)
        when '!'       then compile_negation(tokens, cur_node, seq_head)
        when '$'       then compile_capture(tokens, cur_node, seq_head)
        when '^'       then compile_ascend(tokens, cur_node, seq_head)
        when WILDCARD  then compile_wildcard(cur_node, token[1..-1], seq_head)
        when LITERAL   then compile_literal(cur_node, token, seq_head)
        when PREDICATE then compile_predicate(cur_node, token, seq_head)
        when NODE      then compile_nodetype(cur_node, token)
        when PARAM     then compile_param(cur_node, token[1..-1], seq_head)
        when CLOSING   then fail_due_to("#{token} in invalid position")
        when nil       then fail_due_to('pattern ended prematurely')
        else fail_due_to("invalid token #{token.inspect}")
        end
      end

      def compile_seq(tokens, cur_node, seq_head)
        fail_due_to('empty parentheses') if tokens.first == ')'
        fail_due_to('parentheses at sequence head') if seq_head

        init = "temp#{@temps += 1} = #{cur_node}"
        cur_node = "temp#{@temps}"
        terms = compile_seq_terms(tokens, cur_node)

        join_terms(init, terms, ' && ')
      end

      def compile_seq_terms(tokens, cur_node)
        terms = []
        index = nil
        until tokens.first == ')'
          if tokens.first == '...'
            return compile_ellipsis(tokens, cur_node, terms, index || 0)
          elsif tokens.first == '$...'
            return compile_capt_ellip(tokens, cur_node, terms, index || 0)
          elsif index.nil?
            terms << compile_expr(tokens, cur_node, true)
            index = 0
          else
            child_node = "#{cur_node}.children[#{index}]"
            terms << compile_expr(tokens, child_node, false)
            index += 1
          end
        end
        terms << "(#{cur_node}.children.size == #{index})"
        tokens.shift # drop concluding )
        terms
      end

      def compile_ellipsis(tokens, cur_node, terms, index)
        if (term = compile_seq_tail(tokens, "#{cur_node}.children.last"))
          terms << "(#{cur_node}.children.size > #{index})"
          terms << term
        elsif index > 0
          terms << "(#{cur_node}.children.size >= #{index})"
        end
        terms
      end

      def compile_capt_ellip(tokens, cur_node, terms, index)
        capture = next_capture
        if (term = compile_seq_tail(tokens, "#{cur_node}.children.last"))
          terms << "(#{cur_node}.children.size > #{index})"
          terms << term
          terms << "(#{capture} = #{cur_node}.children[#{index}..-2])"
        else
          terms << "(#{cur_node}.children.size >= #{index})" if index > 0
          terms << "(#{capture} = #{cur_node}.children[#{index}..-1])"
        end
        terms
      end

      def compile_seq_tail(tokens, cur_node)
        tokens.shift
        if tokens.first == ')'
          tokens.shift
          nil
        else
          expr = compile_expr(tokens, cur_node, false)
          fail_due_to('missing )') unless tokens.shift == ')'
          expr
        end
      end

      def compile_union(tokens, cur_node, seq_head)
        fail_due_to('empty union') if tokens.first == '}'

        init = "temp#{@temps += 1} = #{cur_node}"
        cur_node = "temp#{@temps}"

        terms = []
        captures_before = @captures
        terms << compile_expr(tokens, cur_node, seq_head)
        captures_after = @captures

        until tokens.first == '}'
          @captures = captures_before
          terms << compile_expr(tokens, cur_node, seq_head)
          if @captures != captures_after
            fail_due_to('each branch of {} must have same # of captures')
          end
        end
        tokens.shift

        join_terms(init, terms, ' || ')
      end

      def compile_intersect(tokens, cur_node, seq_head)
        fail_due_to('empty intersection') if tokens.first == ']'

        init = "temp#{@temps += 1} = #{cur_node}"
        cur_node = "temp#{@temps}"

        terms = []
        until tokens.first == ']'
          terms << compile_expr(tokens, cur_node, seq_head)
        end
        tokens.shift

        join_terms(init, terms, ' && ')
      end

      def compile_capture(tokens, cur_node, seq_head)
        "(#{next_capture} = #{cur_node}#{'.type' if seq_head}; " <<
          compile_expr(tokens, cur_node, seq_head) <<
          ')'
      end

      def compile_negation(tokens, cur_node, seq_head)
        '(!' << compile_expr(tokens, cur_node, seq_head) << ')'
      end

      def compile_ascend(tokens, cur_node, seq_head)
        "(#{cur_node}.parent && " <<
          compile_expr(tokens, "#{cur_node}.parent", seq_head) <<
          ')'
      end

      def compile_wildcard(cur_node, name, seq_head)
        if name.empty?
          'true'
        elsif @unify.key?(name)
          # we have already seen a wildcard with this name before
          # so the value it matched the first time will already be stored
          # in a temp. check if this value matches the one stored in the temp
          "(#{cur_node}#{'.type' if seq_head} == temp#{@unify[name]})"
        else
          n = @unify[name] = (@temps += 1)
          "(temp#{n} = #{cur_node}#{'.type' if seq_head}; true)"
        end
      end

      def compile_literal(cur_node, literal, seq_head)
        "(#{cur_node}#{'.type' if seq_head} == #{literal})"
      end

      def compile_predicate(cur_node, predicate, seq_head)
        "(#{cur_node}#{'.type' if seq_head}.#{predicate})"
      end

      def compile_nodetype(cur_node, type)
        "(#{cur_node} && #{cur_node}.#{type}_type?)"
      end

      def compile_param(cur_node, number, seq_head)
        number = number.empty? ? 1 : Integer(number)
        @params = number if number > @params
        "(#{cur_node}#{'.type' if seq_head} == param#{number})"
      end

      def next_capture
        "capture#{@captures += 1}"
      end

      def join_terms(init, terms, operator)
        '(' << init << ';' << terms.join(operator) << ')'
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
          return nil unless #{@match_code}
          block_given? ? yield(#{emit_capture_list}) : (return #{emit_retval})
        CODE
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
              if #{compiler.match_code}
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
