# encoding: utf-8

# rubocop:disable SymbolName

module Rubocop
  module Cop
    module SurroundingSpace
      def space_between?(t1, t2)
        char_preceding_2nd_token =
          @source[t2.pos.line - 1][t2.pos.column - 1]
        if char_preceding_2nd_token == '+' && t1.type != :tPLUS
          # Special case. A unary plus is not present in the tokens.
          char_preceding_2nd_token =
            @source[t2.pos.line - 1][t2.pos.column - 2]
        end
        t2.pos.line > t1.pos.line || char_preceding_2nd_token == ' '
      end

      def index_of_first_token(node, tokens)
        @token_table ||= build_token_table(tokens)
        b = node.loc.expression.begin
        @token_table[[b.line, b.column]]
      end

      def index_of_last_token(node, tokens)
        @token_table ||= build_token_table(tokens)
        e = node.loc.expression.end
        (0...e.column).to_a.reverse.find do |c|
          ix = @token_table[[e.line, c]]
          return ix if ix
        end
      end

      def build_token_table(tokens)
        table = {}
        tokens.each_with_index do |t, ix|
          table[[t.pos.line, t.pos.column]] = ix
        end
        table
      end
    end

    class SpaceAroundOperators < Cop
      include SurroundingSpace
      MSG_MISSING = "Surrounding space missing for operator '%s'."
      MSG_DETECTED = 'Space around operator ** detected.'

      BINARY_OPERATORS =
        [:tEQL,    :tAMPER2,  :tPIPE,  :tCARET, :tPLUS,  :tMINUS, :tSTAR2,
         :tDIVIDE, :tPERCENT, :tEH,    :tCOLON, :tANDOP, :tOROP,  :tMATCH,
         :tNMATCH, :tEQ,      :tNEQ,   :tGT,    :tRSHFT, :tGEQ,   :tLT,
         :tLSHFT,  :tLEQ,     :tASSOC, :tEQQ,   :tCMP,   :tOP_ASGN]

      def inspect(source, tokens, sexp, comments)
        @source = source
        positions_not_to_check = get_positions_not_to_check(tokens, sexp)

        tokens.each_cons(3) do |token_before, token, token_after|
          next if token_before.type == :kDEF # TODO: remove?
          next if positions_not_to_check.include?(token.pos)

          case token.type
          when :tPOW
            if has_space?(token_before, token, token_after)
              add_offence(:convention, token.pos.line, MSG_DETECTED)
            end
          when *BINARY_OPERATORS
            check_missing_space(token_before, token, token_after)
          end
        end
      end

      # Returns an array of positions marking the tokens that this cop
      # should not check, either because the token is not an operator
      # or because another cop does the check.
      def get_positions_not_to_check(tokens, sexp)
        positions_not_to_check = []
        do_not_check_block_arg_pipes(sexp, positions_not_to_check)
        do_not_check_param_default(tokens, sexp, positions_not_to_check)
        do_not_check_class_lshift_self(tokens, sexp, positions_not_to_check)
        do_not_check_def_things(tokens, sexp, positions_not_to_check)
        do_not_check_singleton_operator_defs(tokens, sexp,
                                             positions_not_to_check)
        positions_not_to_check
      end

      def do_not_check_block_arg_pipes(sexp, positions_not_to_check)
        # each { |a| }
        #        ^ ^
        on_node(:block, sexp) do |b|
          on_node(:args, b) do |a|
            positions_not_to_check << a.loc.begin << a.loc.end if a.loc.begin
          end
        end
      end

      def do_not_check_param_default(tokens, sexp, positions_not_to_check)
        # func(a, b=nil)
        #          ^
        on_node(:optarg, sexp) do |optarg|
          _arg, equals, _value = tokens[index_of_first_token(optarg, tokens),
                                        3]
          positions_not_to_check << equals.pos
        end
      end

      def do_not_check_class_lshift_self(tokens, sexp, positions_not_to_check)
        # class <<self
        #       ^
        on_node(:sclass, sexp) do |sclass|
          ix = index_of_first_token(sclass, tokens)
          if tokens[ix, 2].map(&:type) == [:kCLASS, :tLSHFT]
            positions_not_to_check << tokens[ix + 1].pos
          end
        end
      end

      def do_not_check_def_things(tokens, sexp, positions_not_to_check)
        # def +(other)
        #     ^
        on_node(:def, sexp) do |def_node|
          # def each &block
          #          ^
          # def each *args
          #          ^
          on_node([:blockarg, :restarg], def_node) do |arg_node|
            positions_not_to_check << tokens[index_of_first_token(arg_node,
                                                                  tokens)].pos
          end
          positions_not_to_check <<
            tokens[index_of_first_token(def_node, tokens) + 1].pos
        end
      end

      def do_not_check_singleton_operator_defs(tokens, sexp,
                                               positions_not_to_check)
        # def self.===(other)
        #          ^
        on_node(:defs, sexp) do |defs_node|
          _receiver, name, _args = *defs_node
          ix = index_of_first_token(defs_node, tokens)
          name_token = tokens[ix..-1].find { |t| t.text == name.to_s }
          positions_not_to_check << name_token.pos
        end
      end

      def check_missing_space(token_before, token, token_after)
        unless has_space?(token_before, token, token_after)
          text = token.text.to_s + (token.type == :tOP_ASGN ? '=' : '')
          add_offence(:convention, token.pos.line, MSG_MISSING % text)
        end
      end

      def has_space?(token_before, token, token_after)
        space_between?(token_before, token) && space_between?(token,
                                                              token_after)
      end
    end

    class SpaceAroundBraces < Cop
      include SurroundingSpace
      MSG_LEFT = "Surrounding space missing for '{'."
      MSG_RIGHT = "Space missing to the left of '}'."

      def inspect(source, tokens, sexp, comments)
        @source = source
        positions_not_to_check = get_positions_not_to_check(tokens, sexp)
        tokens.each_cons(2) do |t1, t2|
          next if ([t1.pos, t2.pos] - positions_not_to_check).size < 2

          type1, type2 = t1.type, t2.type
          # :tLBRACE in hash literals, :tLCURLY otherwise.
          next if [:tLCURLY, :tLBRACE].include?(type1) && type2 == :tRCURLY
          check(t1, t2, MSG_LEFT) if type1 == :tLCURLY || type2 == :tLCURLY
          check(t1, t2, MSG_RIGHT) if type2 == :tRCURLY
        end
      end

      def get_positions_not_to_check(tokens, sexp)
        positions_not_to_check = []

        on_node(:hash, sexp) do |hash|
          b_ix = index_of_first_token(hash, tokens)
          e_ix = index_of_last_token(hash, tokens)
          positions_not_to_check << tokens[b_ix].pos << tokens[e_ix].pos
        end

        # TODO: Check braces inside string/symbol/regexp/xstr interpolation.
        on_node([:dstr, :dsym, :regexp, :xstr], sexp) do |s|
          b_ix = index_of_first_token(s, tokens)
          e_ix = index_of_last_token(s, tokens)
          tokens[b_ix..e_ix].each do |t|
            positions_not_to_check << t.pos if t.type == :tRCURLY
          end
        end

        positions_not_to_check
      end

      def check(t1, t2, msg)
        unless space_between?(t1, t2)
          add_offence(:convention, t1.pos.line, msg)
        end
      end
    end

    module SpaceInside
      include SurroundingSpace
      MSG = 'Space inside %s detected.'

      def inspect(source, tokens, sexp, comments)
        @source = source
        left, right, kind = specifics
        tokens.each_cons(2) do |t1, t2|
          if t1.type == left || t2.type == right
            if t2.pos.line == t1.pos.line && space_between?(t1, t2)
              add_offence(:convention, t1.pos.line, MSG % kind)
            end
          end
        end
      end
    end

    class SpaceInsideParens < Cop
      include SpaceInside

      def specifics
        [:tLPAREN2, :tRPAREN, 'parentheses']
      end
    end

    class SpaceInsideBrackets < Cop
      include SpaceInside

      def specifics
        [:tLBRACK, :tRBRACK, 'square brackets']
      end
    end

    class SpaceInsideHashLiteralBraces < Cop
      include SurroundingSpace
      MSG = 'Space inside hash literal braces %s.'

      def inspect(source, tokens, sexp, comments)
        @source = source
        on_node(:hash, sexp) do |hash|
          b_ix = index_of_first_token(hash, tokens)
          e_ix = index_of_last_token(hash, tokens)
          check(tokens[b_ix], tokens[b_ix + 1])
          check(tokens[e_ix - 1], tokens[e_ix])
        end
      end

      def check(t1, t2)
        types = [t1, t2].map(&:type)
        braces = [:tLBRACE, :tRCURLY]
        return if types == braces || (braces - types).size == 2
        has_space = space_between?(t1, t2)
        is_offence, word = if self.class.config['EnforcedStyleIsWithSpaces']
                             [!has_space, 'missing']
                           else
                             [has_space, 'detected']
                           end
        add_offence(:convention, t1.pos.line, MSG % word) if is_offence
      end
    end

    class SpaceAroundEqualsInParameterDefault < Cop
      include SurroundingSpace
      MSG = 'Surrounding space missing in default value assignment.'

      def inspect(source, tokens, sexp, comments)
        @source = source
        on_node(:optarg, sexp) do |optarg|
          arg, equals, value = tokens[index_of_first_token(optarg, tokens), 3]
          unless space_between?(arg, equals) && space_between?(equals, value)
            add_offence(:convention, equals.pos.line, MSG)
          end
        end
      end
    end
  end
end
