# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength, Metrics/CyclomaticComplexity
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
  # - With no block and no captures: #match returns `true`.
  #
  # ## Pattern string format examples
  #
  #     ':sym'              # matches a literal symbol
  #     '1'                 # matches a literal integer
  #     'nil'               # matches a literal nil
  #     'send'              # matches (send ...)
  #     '(send)'            # matches (send)
  #     '(send ...)'        # matches (send ...)
  #     '(op-asgn)'         # node types with hyphenated names also work
  #     '{send class}'      # matches (send ...) or (class ...)
  #     '({send class})'    # matches (send) or (class)
  #     '(send const)'      # matches (send (const ...))
  #     '(send _ :new)'     # matches (send <anything> :new)
  #     '(send $_ :new)'    # as above, but whatever matches the $_ is captured
  #     '(send $_ $_)'      # you can use as many captures as you want
  #     '(send !const ...)' # ! negates the next part of the pattern
  #     '$(send const ...)' # arbitrary matching can be performed on a capture
  #     '(send _recv _msg)' # wildcards can be named (for readability)
  #     '(send ... :new)'   # you can specifically match against the last child
  #                         # (this only works for the very last)
  #     '(send $...)'       # capture all the children as an array
  #     '(send $... int)'   # capture all children but the last as an array
  #     '(send _x :+ _x)'   # unification is performed on named wildcards
  #                         # (like Prolog variables...)
  #                         # (#== is used to see if values unify)
  #     '(int odd?)'        # words which end with a ? are predicate methods,
  #                         # are are called on the target to see if it matches
  #                         # any Ruby method which the matched object supports
  #                         # can be used
  #                         # if a truthy value is returned, the match succeeds
  #     '(int [!1 !2])'     # [] contains multiple patterns, ALL of which must
  #                         # match in that position
  #                         # in other words, while {} is pattern union (logical
  #                         # OR), [] is intersection (logical AND)
  #     '(send %1 _)'       # % stands for a parameter which must be supplied to
  #                         # #match at matching time
  #                         # it will be compared to the corresponding value in
  #                         # the AST using #==
  #                         # a bare '%' is the same as '%1'
  #                         # the number of extra parameters passed to #match
  #                         # must equal the highest % value in the pattern
  #                         # for consistency, %0 is the 'root node' which is
  #                         # passed as the 1st argument to #match, where the
  #                         # matching process starts
  #     '^^send'            # each ^ ascends one level in the AST
  #                         # so this matches against the grandparent node
  #     '#method'           # we call this a 'funcall'; it calls a method in the
  #                         # context where a pattern-matching method is defined
  #                         # if that returns a truthy value, the match succeeds
  #     'equal?(%1)'        # predicates can be given 1 or more extra args
  #     '#method(%0, 1)'    # funcalls can also be given 1 or more extra args
  #
  # You can nest arbitrarily deep:
  #
  #     # matches node parsed from 'Const = Class.new' or 'Const = Module.new':
  #     '(casgn nil? :Const (send (const nil? {:Class :Module}) :new))'
  #     # matches a node parsed from an 'if', with a '==' comparison,
  #     # and no 'else' branch:
  #     '(if (send _ :== _) _ nil?)'
  #
  # Note that patterns like 'send' are implemented by calling `#send_type?` on
  # the node being matched, 'const' by `#const_type?`, 'int' by `#int_type?`,
  # and so on. Therefore, if you add methods which are named like
  # `#prefix_type?` to the AST node class, then 'prefix' will become usable as
  # a pattern.
  #
  # Also note that if you need a "guard clause" to protect against possible nils
  # in a certain place in the AST, you can do it like this: `[!nil <pattern>]`
  #
  # The compiler code is very simple; don't be afraid to read through it!
  class NodePattern
    # @private
    Invalid = Class.new(StandardError)

    # @private
    # Builds Ruby code which implements a pattern
    class Compiler
      SYMBOL       = %r{:(?:[\w+@*/?!<>=~|%^-]+|\[\]=?)}
      IDENTIFIER   = /[a-zA-Z_-]/
      META         = /\(|\)|\{|\}|\[|\]|\$\.\.\.|\$|!|\^|\.\.\./
      NUMBER       = /-?\d+(?:\.\d+)?/
      STRING       = /".+?"/
      METHOD_NAME  = /\#?#{IDENTIFIER}+[\!\?]?\(?/
      PARAM_NUMBER = /%\d*/

      SEPARATORS = /[\s]+/
      TOKENS     = Regexp.union(META, PARAM_NUMBER, NUMBER,
                                METHOD_NAME, SYMBOL, STRING)

      TOKEN = /\G(?:#{SEPARATORS}|#{TOKENS}|.)/

      NODE      = /\A#{IDENTIFIER}+\Z/
      PREDICATE = /\A#{IDENTIFIER}+\?\(?\Z/
      WILDCARD  = /\A_#{IDENTIFIER}*\Z/
      FUNCALL   = /\A\##{METHOD_NAME}/
      LITERAL   = /\A(?:#{SYMBOL}|#{NUMBER}|#{STRING})\Z/
      PARAM     = /\A#{PARAM_NUMBER}\Z/
      CLOSING   = /\A(?:\)|\}|\])\Z/

      attr_reader :match_code

      def initialize(str, node_var = 'node0')
        @string   = str
        @root     = node_var

        @temps    = 0  # avoid name clashes between temp variables
        @captures = 0  # number of captures seen
        @unify    = {} # named wildcard -> temp variable number
        @params   = 0  # highest % (param) number seen

        run(node_var)
      end

      def run(node_var)
        tokens =
          @string.scan(TOKEN).reject { |token| token =~ /\A#{SEPARATORS}\Z/ }

        @match_code = compile_expr(tokens, node_var, false)

        fail_due_to('unbalanced pattern') unless tokens.empty?
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def compile_expr(tokens, cur_node, seq_head)
        # read a single pattern-matching expression from the token stream,
        # return Ruby code which performs the corresponding matching operation
        # on 'cur_node' (which is Ruby code which evaluates to an AST node)
        #
        # the 'pattern-matching' expression may be a composite which
        # contains an arbitrary number of sub-expressions
        token = tokens.shift
        case token
        when '('       then compile_seq(tokens, cur_node, seq_head)
        when '{'       then compile_union(tokens, cur_node, seq_head)
        when '['       then compile_intersect(tokens, cur_node, seq_head)
        when '!'       then compile_negation(tokens, cur_node, seq_head)
        when '$'       then compile_capture(tokens, cur_node, seq_head)
        when '^'       then compile_ascend(tokens, cur_node, seq_head)
        when WILDCARD  then compile_wildcard(cur_node, token[1..-1], seq_head)
        when FUNCALL   then compile_funcall(tokens, cur_node, token, seq_head)
        when LITERAL   then compile_literal(cur_node, token, seq_head)
        when PREDICATE then compile_predicate(tokens, cur_node, token, seq_head)
        when NODE      then compile_nodetype(cur_node, token)
        when PARAM     then compile_param(cur_node, token[1..-1], seq_head)
        when CLOSING   then fail_due_to("#{token} in invalid position")
        when nil       then fail_due_to('pattern ended prematurely')
        else                fail_due_to("invalid token #{token.inspect}")
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def compile_seq(tokens, cur_node, seq_head)
        fail_due_to('empty parentheses') if tokens.first == ')'
        fail_due_to('parentheses at sequence head') if seq_head

        # 'cur_node' is a Ruby expression which evaluates to an AST node,
        # but we don't know how expensive it is
        # to be safe, cache the node in a temp variable and then use the
        # temp variable as 'cur_node'
        with_temp_node(cur_node) do |init, temp_node|
          terms = compile_seq_terms(tokens, temp_node)

          join_terms(init, terms, ' && ')
        end
      end

      def compile_seq_terms(tokens, cur_node)
        ret, size =
          compile_seq_terms_with_size(tokens, cur_node) do |token, terms, index|
            case token
            when '...'.freeze
              return compile_ellipsis(tokens, cur_node, terms, index)
            when '$...'.freeze
              return compile_capt_ellip(tokens, cur_node, terms, index)
            end
          end

        ret << "(#{cur_node}.children.size == #{size})"
      end

      def compile_seq_terms_with_size(tokens, cur_node)
        index = nil
        terms = []
        until tokens.first == ')'
          yield tokens.first, terms, index || 0
          term, index = compile_expr_with_index(tokens, cur_node, index)
          terms << term
        end

        tokens.shift # drop concluding )
        [terms, index]
      end

      def compile_expr_with_index(tokens, cur_node, index)
        if index.nil?
          # in 'sequence head' position; some expressions are compiled
          # differently at 'sequence head' (notably 'node type' expressions)
          # grep for seq_head to see where it makes a difference
          [compile_expr(tokens, cur_node, true), 0]
        else
          child_node = "#{cur_node}.children[#{index}]"
          [compile_expr(tokens, child_node, false), index + 1]
        end
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

        with_temp_node(cur_node) do |init, temp_node|
          terms = union_terms(tokens, temp_node, seq_head)
          join_terms(init, terms, ' || ')
        end
      end

      def union_terms(tokens, temp_node, seq_head)
        # we need to ensure that each branch of the {} contains the same
        # number of captures (since only one branch of the {} can actually
        # match, the same variables are used to hold the captures for each
        # branch)
        compile_expr_with_captures(tokens,
                                   temp_node, seq_head) do |term, before, after|
          terms = [term]
          until tokens.first == '}'
            terms << compile_expr_with_capture_check(tokens, temp_node,
                                                     seq_head, before, after)
          end
          tokens.shift

          terms
        end
      end

      def compile_expr_with_captures(tokens, temp_node, seq_head)
        captures_before = @captures
        expr = compile_expr(tokens, temp_node, seq_head)

        yield expr, captures_before, @captures
      end

      def compile_expr_with_capture_check(tokens, temp_node, seq_head, before,
                                          after)
        @captures = before
        expr = compile_expr(tokens, temp_node, seq_head)
        if @captures != after
          fail_due_to('each branch of {} must have same # of captures')
        end

        expr
      end

      def compile_intersect(tokens, cur_node, seq_head)
        fail_due_to('empty intersection') if tokens.first == ']'

        with_temp_node(cur_node) do |init, temp_node|
          terms = []
          until tokens.first == ']'
            terms << compile_expr(tokens, temp_node, seq_head)
          end
          tokens.shift

          join_terms(init, terms, ' && ')
        end
      end

      def compile_capture(tokens, cur_node, seq_head)
        "(#{next_capture} = #{cur_node}#{'.type' if seq_head}; " \
          "#{compile_expr(tokens, cur_node, seq_head)})"
      end

      def compile_negation(tokens, cur_node, seq_head)
        "(!#{compile_expr(tokens, cur_node, seq_head)})"
      end

      def compile_ascend(tokens, cur_node, seq_head)
        "(#{cur_node}.parent && " \
          "#{compile_expr(tokens, "#{cur_node}.parent", seq_head)})"
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
          n = @unify[name] = next_temp_value
          # double assign to temp#{n} to avoid "assigned but unused variable"
          "(temp#{n} = #{cur_node}#{'.type' if seq_head}; " \
          "temp#{n} = temp#{n}; true)"
        end
      end

      def compile_literal(cur_node, literal, seq_head)
        "(#{cur_node}#{'.type' if seq_head} == #{literal})"
      end

      def compile_predicate(tokens, cur_node, predicate, seq_head)
        if predicate.end_with?('(') # is there an arglist?
          args = compile_args(tokens)
          predicate = predicate[0..-2] # drop the trailing (
          "(#{cur_node}#{'.type' if seq_head}.#{predicate}(#{args.join(',')}))"
        else
          "(#{cur_node}#{'.type' if seq_head}.#{predicate})"
        end
      end

      def compile_funcall(tokens, cur_node, method, seq_head)
        # call a method in the context which this pattern-matching
        # code is used in. pass target value as an argument
        method = method[1..-1] # drop the leading #
        if method.end_with?('(') # is there an arglist?
          args = compile_args(tokens)
          method = method[0..-2] # drop the trailing (
          "(#{method}(#{cur_node}#{'.type' if seq_head},#{args.join(',')}))"
        else
          "(#{method}(#{cur_node}#{'.type' if seq_head}))"
        end
      end

      def compile_nodetype(cur_node, type)
        "(#{cur_node} && #{cur_node}.#{type.tr('-', '_')}_type?)"
      end

      def compile_param(cur_node, number, seq_head)
        "(#{cur_node}#{'.type' if seq_head} == #{get_param(number)})"
      end

      def compile_args(tokens)
        index = tokens.find_index { |token| token == ')' }

        tokens.slice!(0..index).each_with_object([]) do |token, args|
          next if [')', ','].include?(token)

          args << compile_arg(token)
        end
      end

      def compile_arg(token)
        case token
        when WILDCARD  then
          name   = token[1..-1]
          number = @unify[name] || fail_due_to('invalid in arglist: ' + token)
          "temp#{number}"
        when LITERAL   then token
        when PARAM     then get_param(token[1..-1])
        when CLOSING   then fail_due_to("#{token} in invalid position")
        when nil       then fail_due_to('pattern ended prematurely')
        else fail_due_to("invalid token in arglist: #{token.inspect}")
        end
      end

      def next_capture
        "capture#{@captures += 1}"
      end

      def get_param(number)
        number = number.empty? ? 1 : Integer(number)
        @params = number if number > @params
        number.zero? ? @root : "param#{number}"
      end

      def join_terms(init, terms, operator)
        "(#{init};#{terms.join(operator)})"
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

      def emit_trailing_params
        params = emit_param_list
        params.empty? ? '' : ",#{params}"
      end

      def emit_guard_clause
        <<-RUBY
          return unless node.is_a?(RuboCop::AST::Node)
        RUBY
      end

      def emit_method_code
        <<-RUBY
          return unless #{@match_code}
          block_given? ? yield(#{emit_capture_list}) : (return #{emit_retval})
        RUBY
      end

      def fail_due_to(message)
        raise Invalid, "Couldn't compile due to #{message}. Pattern: #{@string}"
      end

      def with_temp_node(cur_node)
        with_temp_variable do |temp_var|
          # double assign to temp#{n} to avoid "assigned but unused variable"
          yield "#{temp_var} = #{cur_node}; #{temp_var} = #{temp_var}", temp_var
        end
      end

      def with_temp_variable
        yield "temp#{next_temp_value}"
      end

      def next_temp_value
        @temps += 1
      end
    end
    private_constant :Compiler

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
        compiler = Compiler.new(pattern_str, 'node')
        src = "def #{method_name}(node = self" \
              "#{compiler.emit_trailing_params});" \
              "#{compiler.emit_guard_clause}" \
              "#{compiler.emit_method_code};end"

        location = caller_locations(1, 1).first
        class_eval(src, location.path, location.lineno)
      end

      # Define a method which recurses over the descendants of an AST node,
      # checking whether any of them match the provided pattern
      #
      # If the method name ends with '?', the new method will return `true`
      # as soon as it finds a descendant which matches. Otherwise, it will
      # yield all descendants which match.
      def def_node_search(method_name, pattern_str)
        compiler = Compiler.new(pattern_str, 'node')
        called_from = caller(1..1).first.split(':')

        if method_name.to_s.end_with?('?')
          node_search_first(method_name, compiler, called_from)
        else
          node_search_all(method_name, compiler, called_from)
        end
      end

      def node_search_first(method_name, compiler, called_from)
        node_search(method_name, compiler, 'return true', '', called_from)
      end

      def node_search_all(method_name, compiler, called_from)
        yieldval = compiler.emit_capture_list
        yieldval = 'node' if yieldval.empty?
        prelude = "return enum_for(:#{method_name}, node0" \
                  "#{compiler.emit_trailing_params}) unless block_given?"

        node_search(method_name, compiler, "yield(#{yieldval})", prelude,
                    called_from)
      end

      def node_search(method_name, compiler, on_match, prelude, called_from)
        src = node_search_body(method_name, compiler.emit_trailing_params,
                               prelude, compiler.match_code, on_match)
        filename, lineno = *called_from
        class_eval(src, filename, lineno.to_i)
      end

      def node_search_body(method_name, trailing_params, prelude, match_code,
                           on_match)
        <<-RUBY
          def #{method_name}(node0#{trailing_params})
            #{prelude}
            node0.each_node do |node|
              if #{match_code}
                #{on_match}
              end
            end
            nil
          end
        RUBY
      end
    end

    def initialize(str)
      compiler = Compiler.new(str)
      src = "def match(node0#{compiler.emit_trailing_params});" \
            "#{compiler.emit_method_code}end"
      instance_eval(src)
    end
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/CyclomaticComplexity
