# encoding: utf-8

module Rubocop
  module Cop
    # Commissioner class is responsible for processing the AST and delagating
    # work to the specified cops.
    class Commissioner < Parser::AST::Processor
      attr_reader :errors

      def initialize(cops, options = {})
        @cops = cops
        @options = options
        reset_errors
      end

      %w(on_dstr on_dsym on_regexp on_xstr on_splat on_array on_pair on_hash
         on_irange on_erange on_var on_lvar on_ivar on_gvar on_cvar on_back_ref
         on_nth_ref on_vasgn on_lvasgn on_ivasgn on_gvasgn on_cvasgn
         on_and_asgn on_or_asgn on_op_asgn on_mlhs on_masgn on_const on_casgn
         on_args on_argument on_arg on_optarg on_restarg on_blockarg
         on_shadowarg on_kwarg on_kwoptarg on_kwrestarg on_arg_expr
         on_restarg_expr on_blockarg_expr on_module on_class on_sclass on_def
         on_defs on_undef on_alias on_send on_block on_while on_while_post
         on_until on_until_post on_for on_return on_break on_next on_redo
         on_retry on_super on_yield on_defined?  on_not on_and on_or on_if
         on_when on_case on_iflipflop on_eflipflop on_match_current_line
         on_match_with_lvasgn on_resbody on_rescue on_ensure on_begin
         on_kwbegin on_preexe on_postexe
        ).each do |callback|
          class_eval <<-EOS
            def #{callback}(node)
              @cops.each do |cop|
                if cop.respond_to?(:#{callback})
                  delegate_to(cop, :#{callback}, node)
                end
              end
            end
          EOS
      end

      def inspect(source_buffer, source, tokens, ast, comments)
        reset_errors
        process(ast) if ast
        process_source(source_buffer, source, tokens, ast, comments)
        @cops.reduce([]) do |offences, cop|
          offences.concat(cop.offences)
          offences
        end
      end

      private

      def reset_errors
        @errors = Hash.new { |hash, k| hash[k] = [] }
      end

      def process_source(source_buffer, source, tokens, ast, comments)
        @cops.each do |cop|
          if cop.respond_to?(:source_callback)
            cop.source_callback(source_buffer, source, tokens, ast, comments)
          end
        end
      end

      def delegate_to(cop, callback, node)
        cop.send callback, node
      rescue => e
        if @options[:raise_error]
          fail e
        else
          @errors[cop] << e
        end
      end
    end
  end
end
