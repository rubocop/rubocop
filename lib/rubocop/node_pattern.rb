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
  #     '(send ... :new)'   # you can match against the last children
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
      SYMBOL       = %r{:(?:[\w+@*/?!<>=~|%^-]+|\[\]=?)}.freeze
      IDENTIFIER   = /[a-zA-Z_][a-zA-Z0-9_-]*/.freeze
      META         = /\(|\)|\{|\}|\[|\]|\$\.\.\.|\$|!|\^|\.\.\./.freeze
      NUMBER       = /-?\d+(?:\.\d+)?/.freeze
      STRING       = /".+?"/.freeze
      METHOD_NAME  = /\#?#{IDENTIFIER}[\!\?]?\(?/.freeze
      PARAM_NUMBER = /%\d*/.freeze

      SEPARATORS = /[\s]+/.freeze
      TOKENS     = Regexp.union(META, PARAM_NUMBER, NUMBER,
                                METHOD_NAME, SYMBOL, STRING)

      TOKEN = /\G(?:#{SEPARATORS}|#{TOKENS}|.)/.freeze

      NODE      = /\A#{IDENTIFIER}\Z/.freeze
      PREDICATE = /\A#{IDENTIFIER}\?\(?\Z/.freeze
      WILDCARD  = /\A_(?:#{IDENTIFIER})?\Z/.freeze

      FUNCALL   = /\A\##{METHOD_NAME}/.freeze
      LITERAL   = /\A(?:#{SYMBOL}|#{NUMBER}|#{STRING})\Z/.freeze
      PARAM     = /\A#{PARAM_NUMBER}\Z/.freeze
      CLOSING   = /\A(?:\)|\}|\])\Z/.freeze

      REST      = '...'.freeze
      CAPTURED_REST = '$...'.freeze

      attr_reader :match_code, :tokens

      SEQ_HEAD_INDEX = -1

      # Placeholders while compiling, see with_..._context methods
      CUR_PLACEHOLDER = '@@@cur'.freeze
      CUR_NODE = "#{CUR_PLACEHOLDER} node@@@".freeze
      CUR_ELEMENT = "#{CUR_PLACEHOLDER} element@@@".freeze
      SEQ_HEAD_GUARD = '@@@seq guard head@@@'.freeze

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
        @tokens = Compiler.tokens(@string)

        @match_code = with_context(compile_expr, node_var, use_temp_node: false)

        fail_due_to('unbalanced pattern') unless tokens.empty?
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def compile_expr
        # read a single pattern-matching expression from the token stream,
        # return Ruby code which performs the corresponding matching operation
        #
        # the 'pattern-matching' expression may be a composite which
        # contains an arbitrary number of sub-expressions, but that composite
        # must all have precedence higher or equal to that of `&&`
        #
        # Expressions may use placeholders like:
        #   CUR_NODE: Ruby code that evaluates to an AST node
        #   CUR_ELEMENT: Either the node or the type if in first element of
        #   a sequence (aka seq_head, e.g. "(seq_head first_node_arg ...")

        token = tokens.shift
        case token
        when '('       then compile_seq
        when '{'       then compile_union
        when '['       then compile_intersect
        when '!'       then compile_negation
        when '$'       then compile_capture
        when '^'       then compile_ascend
        when WILDCARD  then compile_wildcard(token[1..-1])
        when FUNCALL   then compile_funcall(token)
        when LITERAL   then compile_literal(token)
        when PREDICATE then compile_predicate(token)
        when NODE      then compile_nodetype(token)
        when PARAM     then compile_param(token[1..-1])
        when CLOSING   then fail_due_to("#{token} in invalid position")
        when nil       then fail_due_to('pattern ended prematurely')
        else                fail_due_to("invalid token #{token.inspect}")
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def compile_seq
        fail_due_to('empty parentheses') if tokens.first == ')'

        terms = compile_seq_terms
        terms.unshift(compile_guard_clause)
        terms.join(" &&\n") << SEQ_HEAD_GUARD
      end

      def compile_guard_clause
        "#{CUR_NODE}.is_a?(RuboCop::AST::Node)"
      end

      def compile_seq_terms
        ret =
          compile_seq_terms_with_size do |token, terms, index|
            capture = next_capture if token == CAPTURED_REST
            if capture || token == REST
              index = 0 if index == SEQ_HEAD_INDEX # Consider ($...) as (_ $...)
              return compile_ellipsis(terms, index, capture)
            end
          end
        ret << "#{CUR_NODE}.children.size == #{ret.size - 1}"
      end

      def compile_seq_terms_with_size
        index = SEQ_HEAD_INDEX
        terms = []
        until tokens.first == ')'
          yield tokens.first, terms, index
          term = compile_expr_with_index(index)
          index += 1
          terms << term
        end

        tokens.shift # drop concluding )
        terms
      end

      def compile_expr_with_index(index)
        if index == SEQ_HEAD_INDEX
          with_seq_head_context(compile_expr)
        else
          with_child_context(compile_expr, index)
        end
      end

      def compile_ellipsis(terms, index, capture = nil)
        tokens.shift # drop ellipsis
        tail = compile_seq_tail
        terms << "#{CUR_NODE}.children.size >= #{index + tail.size}"
        terms.concat tail
        if capture
          range = index..-tail.size - 1
          terms << "(#{capture} = #{CUR_NODE}.children[#{range}])"
        end
        terms
      end

      def compile_seq_tail
        terms = []
        terms << compile_expr until tokens.first == ')'
        tokens.shift # drop ')'
        terms.map.with_index do |term, i|
          with_child_context(term, i - terms.size)
        end
      end

      def compile_union
        fail_due_to('empty union') if tokens.first == '}'

        union = union_terms.join(' || ')
        "(#{union})"
      end

      def union_terms
        # we need to ensure that each branch of the {} contains the same
        # number of captures (since only one branch of the {} can actually
        # match, the same variables are used to hold the captures for each
        # branch)
        compile_expr_with_captures do |term, before, after|
          terms = [term]
          until tokens.first == '}'
            terms << compile_expr_with_capture_check(before, after)
          end
          tokens.shift

          terms
        end
      end

      def compile_expr_with_captures
        captures_before = @captures
        expr = compile_expr

        yield expr, captures_before, @captures
      end

      def compile_expr_with_capture_check(before, after)
        @captures = before
        expr = compile_expr
        if @captures != after
          fail_due_to('each branch of {} must have same # of captures')
        end

        expr
      end

      def compile_intersect
        fail_due_to('empty intersection') if tokens.first == ']'

        terms = []
        terms << compile_expr until tokens.first == ']'
        tokens.shift

        terms.join(' && ')
      end

      def compile_capture
        "(#{next_capture} = #{CUR_ELEMENT}; #{compile_expr})"
      end

      def compile_negation
        "!(#{compile_expr})"
      end

      def compile_ascend
        with_context("#{CUR_NODE} && #{compile_expr}", "#{CUR_NODE}.parent")
      end

      def compile_wildcard(name)
        if name.empty?
          'true'
        elsif @unify.key?(name)
          # we have already seen a wildcard with this name before
          # so the value it matched the first time will already be stored
          # in a temp. check if this value matches the one stored in the temp
          "#{CUR_ELEMENT} == temp#{@unify[name]}"
        else
          n = @unify[name] = next_temp_value
          # double assign to temp#{n} to avoid "assigned but unused variable"
          "(temp#{n} = #{CUR_ELEMENT}; " \
          "temp#{n} = temp#{n}; true)"
        end
      end

      def compile_literal(literal)
        "#{CUR_ELEMENT} == #{literal}"
      end

      def compile_predicate(predicate)
        if predicate.end_with?('(') # is there an arglist?
          args = compile_args(tokens)
          predicate = predicate[0..-2] # drop the trailing (
          "#{CUR_ELEMENT}.#{predicate}(#{args.join(',')})"
        else
          "#{CUR_ELEMENT}.#{predicate}"
        end
      end

      def compile_funcall(method)
        # call a method in the context which this pattern-matching
        # code is used in. pass target value as an argument
        method = method[1..-1] # drop the leading #
        if method.end_with?('(') # is there an arglist?
          args = compile_args(tokens)
          method = method[0..-2] # drop the trailing (
          "#{method}(#{CUR_ELEMENT},#{args.join(',')})"
        else
          "#{method}(#{CUR_ELEMENT})"
        end
      end

      def compile_nodetype(type)
        "#{compile_guard_clause} && #{CUR_NODE}.#{type.tr('-', '_')}_type?"
      end

      def compile_param(number)
        "#{CUR_ELEMENT} == #{get_param(number)}"
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
          yield "(#{temp_var} = #{cur_node})", temp_var
        end
          .gsub("\n", "\n  ") # Nicer indent for debugging
      end

      def with_temp_variable
        yield "temp#{next_temp_value}"
      end

      def next_temp_value
        @temps += 1
      end

      def auto_use_temp_node?(code)
        code.scan(CUR_PLACEHOLDER).count > 1
      end

      # with_<...>_context methods are used whenever the context,
      # i.e the current node or the current element can be determined.

      def with_child_context(code, child_index)
        with_context(code, "#{CUR_NODE}.children[#{child_index}]")
      end

      def with_context(code, cur_node,
                       use_temp_node: auto_use_temp_node?(code))
        if use_temp_node
          with_temp_node(cur_node) do |init, temp_var|
            substitute_cur_node(code, temp_var, first_cur_node: init)
          end
        else
          substitute_cur_node(code, cur_node)
        end
      end

      def with_seq_head_context(code)
        if code.include?(SEQ_HEAD_GUARD)
          fail_due_to('parentheses at sequence head')
        end

        code.gsub CUR_ELEMENT, "#{CUR_NODE}.type"
      end

      def substitute_cur_node(code, cur_node, first_cur_node: cur_node)
        iter = 0
        code
          .gsub(CUR_ELEMENT, CUR_NODE)
          .gsub(CUR_NODE) do
            iter += 1
            iter == 1 ? first_cur_node : cur_node
          end
          .gsub(SEQ_HEAD_GUARD, '')
      end

      def self.tokens(pattern)
        pattern.scan(TOKEN).reject { |token| token =~ /\A#{SEPARATORS}\Z/ }
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

    attr_reader :pattern

    def initialize(str)
      @pattern = str
      compiler = Compiler.new(str)
      src = "def match(node0#{compiler.emit_trailing_params});" \
            "#{compiler.emit_method_code}end"
      instance_eval(src, __FILE__, __LINE__ + 1)
    end

    def match(*args)
      # If we're here, it's because the singleton method has not been defined,
      # either because we've been dup'ed or serialized through YAML
      initialize(pattern)
      match(*args)
    end

    def marshal_load(pattern)
      initialize pattern
    end

    def marshal_dump
      pattern
    end

    def ==(other)
      other.is_a?(NodePattern) &&
        Compiler.tokens(other.pattern) == Compiler.tokens(pattern)
    end
    alias eql? ==

    def to_s
      "#<#{self.class} #{pattern}>"
    end
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/CyclomaticComplexity
