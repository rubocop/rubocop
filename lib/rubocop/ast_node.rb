# encoding: utf-8

require 'astrolabe/node'

module Astrolabe
  # RuboCop's extensions to Astrolabe::Node (which extends Parser::AST::Node)
  #
  # Contribute as much of this as possible to the `astrolabe` gem
  # If any of it is accepted, it can be deleted from here
  #
  class Node
    include Astrolabe::Sexp

    COMPARISON_OPERATORS = [:==, :===, :!=, :<=, :>=, :>, :<, :<=>].freeze

    TRUTHY_LITERALS = [:str, :dstr, :xstr, :int, :float, :sym, :dsym, :array,
                       :hash, :regexp, :true, :irange, :erange, :complex,
                       :rational].freeze
    FALSEY_LITERALS = [:false, :nil].freeze
    LITERALS = (TRUTHY_LITERALS + FALSEY_LITERALS).freeze
    BASIC_LITERALS = LITERALS - [:dstr, :xstr, :dsym, :array, :hash, :irange,
                                 :erange].freeze

    VARIABLES = [:ivar, :gvar, :cvar, :lvar].freeze
    REFERENCES = [:nth_ref, :back_ref].freeze

    # def_matcher can be used to define a pattern-matching method on Node
    class << self
      def def_matcher(method_name, pattern_str)
        compiler = RuboCop::NodePattern::Compiler.new(pattern_str, 'self')
        src = "def #{method_name}(" <<
              compiler.emit_param_list <<
              ');' <<
              compiler.emit_method_code <<
              ';end'

        file, lineno = *caller.first.split(':')
        class_eval(src, file, lineno.to_i)
      end
    end

    def source
      loc.expression.source
    end

    ## Destructuring

    def_matcher :receiver,    '{(send $_ ...) (block (send $_ ...) ...)}'
    def_matcher :method_name, '{(send _ $_ ...) (block (send _ $_ ...) ...)}'
    def_matcher :method_args, '{(send _ _ $...) (block (send _ _ $...) ...)}'
    # Note: for masgn, #asgn_rhs will be an array node
    def_matcher :asgn_rhs, '[assignment? (... $_)]'
    def_matcher :str_content, '(str $_)'

    def const_name
      return unless const_type?
      namespace, name = *self
      if namespace && !namespace.cbase_type?
        "#{namespace.const_name}::#{name}"
      else
        name.to_s
      end
    end

    def_matcher :defined_module0, <<-PATTERN
      {(class (const $_ $_) ...)
       (module (const $_ $_) ...)
       (casgn $_ $_        (send (const nil {:Class :Module}) :new ...))
       (casgn $_ $_ (block (send (const nil {:Class :Module}) :new ...) ...))}
    PATTERN
    private :defined_module0

    def defined_module
      namespace, name = *defined_module0
      s(:const, namespace, name) if name
    end

    def defined_module_name
      (const = defined_module) && const.const_name
    end

    ## Searching the AST

    def parent_module_name
      # what class or module is this method/constant/etc definition in?
      # returns nil if answer cannot be determined
      ancestors = each_ancestor(:class, :module, :sclass, :casgn, :block)
      result    = ancestors.map do |ancestor|
        case ancestor.type
        when :class, :module, :casgn
          # TODO: if constant name has cbase (leading ::), then we don't need
          # to keep traversing up through nested classes/modules
          ancestor.defined_module_name
        when :sclass
          obj = ancestor.children[0]
          # TODO: look for constant definition and see if it is nested
          # inside a class or module
          return "#<Class:#{obj.const_name}>" if obj.const_type?
          return "#<Class:#{ancestor.parent_module_name}>" if obj.self_type?
          return nil
        else # block
          # Known DSL methods which eval body inside an anonymous class/module
          return nil if [:describe, :it].include?(ancestor.method_name) &&
                        ancestor.receiver.nil?
          if ancestor.method_name == :class_eval
            return nil unless ancestor.receiver.const_type?
            ancestor.receiver.const_name
          end
        end
      end.compact.reverse.join('::')
      result.empty? ? 'Object' : result
    end

    ## Predicates

    def multiline?
      expr = loc.expression
      expr && (expr.first_line != expr.last_line)
    end

    def single_line?
      !multiline?
    end

    def asgn_method_call?
      !COMPARISON_OPERATORS.include?(method_name) &&
        method_name.to_s.end_with?('=')
    end

    def_matcher :equals_asgn?, '{lvasgn ivasgn cvasgn gvasgn casgn masgn}'
    def_matcher :shorthand_asgn?, '{op_asgn or_asgn and_asgn}'
    def_matcher :assignment?, '{equals_asgn? shorthand_asgn? asgn_method_call?}'

    def literal?
      LITERALS.include?(type)
    end

    def basic_literal?
      BASIC_LITERALS.include?(type)
    end

    def truthy_literal?
      TRUTHY_LITERALS.include?(type)
    end

    def falsey_literal?
      FALSEY_LITERALS.include?(type)
    end

    def variable?
      VARIABLES.include?(type)
    end

    def reference?
      REFERENCES.include?(type)
    end

    def_matcher :command?, '(send nil %1 ...)'
    def_matcher :lambda?,  '(block (send nil :lambda) ...)'
    def_matcher :proc?, <<-PATTERN
      {(block (send nil :proc) ...)
       (block (send (const nil :Proc) :new) ...)
       (send (const nil :Proc) :new)}
    PATTERN
    def_matcher :lambda_or_proc?, '{lambda? proc?}'

    def_matcher :class_constructor?, <<-PATTERN
      {       (send (const nil {:Class :Module}) :new ...)
       (block (send (const nil {:Class :Module}) :new ...) ...)}
    PATTERN

    def_matcher :module_definition?, <<-PATTERN
      {class module (casgn _ _ class_constructor?)}
    PATTERN

    # Some expressions are evaluated for their value, some for their side
    # effects, and some for both
    # If we know that an expression is useful only for its side effects, that
    # means we can transform it in ways which preserve the side effects, but
    # change the return value
    # So, does the return value of this node matter? If we changed it to
    # `(...; nil)`, might that affect anything?
    #
    def value_used?
      # Be conservative and return true if we're not sure
      return false if parent.nil?
      index = parent.children.index { |child| child.equal?(self) }

      case parent.type
      when :array, :block, :defined?, :dstr, :dsym, :eflipflop, :erange, :float,
           :hash, :iflipflop, :irange, :not, :pair, :regexp, :str, :sym, :when,
           :xstr
        parent.value_used?
      when :begin, :kwbegin
        # the last child node determines the value of the parent
        index == parent.children.size - 1 ? parent.value_used? : false
      when :for
        # `for var in enum; body; end`
        # (for <var> <enum> <body>)
        index == 2 ? parent.value_used? : true
      when :case, :if
        # (case <condition> <when...>)
        # (if <condition> <truebranch> <falsebranch>)
        index == 0 ? true : parent.value_used?
      when :while, :until, :while_post, :until_post
        # (while <condition> <body>) -> always evaluates to `nil`
        index == 0
      else
        true
      end
    end

    # Some expressions are evaluated for their value, some for their side
    # effects, and some for both
    # If we know that expressions are useful only for their return values, and
    # have no side effects, that means we can reorder them, change the number
    # of times they are evaluated, or replace them with other expressions which
    # are equivalent in value
    # So, is evaluation of this node free of side effects?
    #
    def pure?
      # Be conservative and return false if we're not sure
      case type
      when :__FILE__, :__LINE__, :const, :cvar, :defined?, :false, :float,
           :gvar, :int, :ivar, :lvar, :nil, :str, :sym, :true
        true
      when :and, :array, :begin, :case, :dstr, :dsym, :eflipflop, :ensure,
           :erange, :for, :hash, :if, :iflipflop, :irange, :kwbegin, :not, :or,
           :pair, :regexp, :until, :until_post, :when, :while, :while_post
        child_nodes.all?(&:pure?)
      else
        false
      end
    end
  end
end
