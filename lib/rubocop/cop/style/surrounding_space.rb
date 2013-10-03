# encoding: utf-8

# rubocop:disable SymbolName

module Rubocop
  module Cop
    module Style
      # Common functionality for checking surrounding space.
      module SurroundingSpace
        def space_between?(t1, t2)
          char_preceding_2nd_token =
            @processed_source[t2.pos.line - 1][t2.pos.column - 1]
          if char_preceding_2nd_token == '+' && t1.type != :tPLUS
            # Special case. A unary plus is not present in the tokens.
            char_preceding_2nd_token =
              @processed_source[t2.pos.line - 1][t2.pos.column - 2]
          end
          t2.pos.line > t1.pos.line || char_preceding_2nd_token == ' '
        end

        def index_of_first_token(node)
          b = node.loc.expression.begin
          token_table[[b.line, b.column]]
        end

        def index_of_last_token(node)
          e = node.loc.expression.end
          (0...e.column).to_a.reverse.find do |c|
            ix = token_table[[e.line, c]]
            return ix if ix
          end
        end

        def token_table
          @token_table ||= begin
            table = {}
            @processed_source.tokens.each_with_index do |t, ix|
              table[[t.pos.line, t.pos.column]] = ix
            end
            table
          end
        end
      end

      # Checks that operators have space around them, except for **
      # which should not have surrounding space.
      class SpaceAroundOperators < Cop
        include SurroundingSpace
        MSG_MISSING = "Surrounding space missing for operator '%s'."
        MSG_DETECTED = 'Space around operator ** detected.'

        BINARY_OPERATORS =
          [:tEQL,    :tAMPER2,  :tPIPE,  :tCARET, :tPLUS,  :tMINUS, :tSTAR2,
           :tDIVIDE, :tPERCENT, :tEH,    :tCOLON, :tANDOP, :tOROP,  :tMATCH,
           :tNMATCH, :tEQ,      :tNEQ,   :tGT,    :tRSHFT, :tGEQ,   :tLT,
           :tLSHFT,  :tLEQ,     :tASSOC, :tEQQ,   :tCMP,   :tOP_ASGN]

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source
          tokens = processed_source.tokens
          tokens.each_cons(3) do |token_before, token, token_after|
            next if token_before.type == :kDEF # TODO: remove?
            next if token_before.type == :tDOT # Called as method.
            next if positions_not_to_check.include?(token.pos)

            case token.type
            when :tPOW
              if has_space?(token_before, token, token_after)
                convention(nil, token.pos, MSG_DETECTED)
              end
            when *BINARY_OPERATORS
              check_missing_space(token_before, token, token_after)
            end
          end
        end

        # Returns an array of positions marking the tokens that this cop
        # should not check, either because the token is not an operator
        # or because another cop does the check.
        def positions_not_to_check
          @positions_not_to_check ||= begin
            positions = []
            positions.concat(do_not_check_block_arg_pipes)
            positions.concat(do_not_check_param_default)
            positions.concat(do_not_check_class_lshift_self)
            positions.concat(do_not_check_def_things)
            positions.concat(do_not_check_singleton_operator_defs)
            positions
          end
        end

        def do_not_check_block_arg_pipes
          # each { |a| }
          #        ^ ^
          positions = []
          on_node(:block, @processed_source.ast) do |b|
            on_node(:args, b) do |a|
              positions << a.loc.begin << a.loc.end if a.loc.begin
            end
          end
          positions
        end

        def do_not_check_param_default
          # func(a, b=nil)
          #          ^
          positions = []
          tokens = @processed_source.tokens
          on_node(:optarg, @processed_source.ast) do |optarg|
            _arg, equals, _value = tokens[index_of_first_token(optarg),
                                          3]
            positions << equals.pos
          end
          positions
        end

        def do_not_check_class_lshift_self
          # class <<self
          #       ^
          positions = []
          tokens = @processed_source.tokens
          on_node(:sclass, @processed_source.ast) do |sclass|
            ix = index_of_first_token(sclass)
            if tokens[ix, 2].map(&:type) == [:kCLASS, :tLSHFT]
              positions << tokens[ix + 1].pos
            end
          end
          positions
        end

        def do_not_check_def_things
          # def +(other)
          #     ^
          positions = []
          tokens = @processed_source.tokens
          on_node(:def, @processed_source.ast) do |def_node|
            # def each &block
            #          ^
            # def each *args
            #          ^
            on_node([:blockarg, :restarg], def_node) do |arg_node|
              positions << tokens[index_of_first_token(arg_node)].pos
            end
            positions << tokens[index_of_first_token(def_node) + 1].pos
          end
          positions
        end

        def do_not_check_singleton_operator_defs
          # def self.===(other)
          #          ^
          positions = []
          tokens = @processed_source.tokens
          on_node(:defs, @processed_source.ast) do |defs_node|
            _receiver, name, _args = *defs_node
            ix = index_of_first_token(defs_node)
            name_token = tokens[ix..-1].find { |t| t.text == name.to_s }
            positions << name_token.pos
          end
          positions
        end

        def check_missing_space(token_before, token, token_after)
          unless has_space?(token_before, token, token_after)
            text = token.text.to_s + (token.type == :tOP_ASGN ? '=' : '')
            convention(nil, token.pos, MSG_MISSING.format(text))
          end
        end

        def has_space?(token_before, token, token_after)
          space_between?(token_before, token) && space_between?(token,
                                                                token_after)
        end
      end

      # Checks that block braces have or don't have surrounding space depending
      # on configuration. For blocks taking parameters, it checks that the left
      # brace has or doesn't have trailing space depending on configuration.
      class SpaceAroundBlockBraces < Cop
        include SurroundingSpace

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source

          processed_source.tokens.each_cons(2) do |t1, t2|
            next if ([t1.pos, t2.pos] - positions_not_to_check).size < 2

            type1, type2 = t1.type, t2.type
            if [:tLCURLY, :tRCURLY].include?(type2)
              check(t1, t2)
            elsif type1 == :tLCURLY
              if type2 == :tPIPE
                check_pipe(t1, t2)
              else
                check(t1, t2)
              end
            end
          end
        end

        def positions_not_to_check
          @positions_not_to_check ||= begin
            positions = []
            ast = @processed_source.ast
            tokens = @processed_source.tokens

            on_node(:hash, ast) do |hash|
              b_ix = index_of_first_token(hash)
              e_ix = index_of_last_token(hash)
              positions << tokens[b_ix].pos << tokens[e_ix].pos
            end

            # TODO: Check braces inside string/symbol/regexp/xstr
            #   interpolation.
            on_node([:dstr, :dsym, :regexp, :xstr], ast) do |s|
              b_ix = index_of_first_token(s)
              e_ix = index_of_last_token(s)
              tokens[b_ix..e_ix].each do |t|
                positions << t.pos if t.type == :tRCURLY
              end
            end

            positions
          end
        end

        def check(t1, t2)
          if cop_config['EnforcedStyle'] == 'space_inside_braces'
            check_space_inside_braces(t1, t2)
          else
            check_no_space_inside_braces(t1, t2)
          end
          check_space_outside_left_brace(t1, t2)
        end

        def check_space_inside_braces(t1, t2)
          unless space_between?(t1, t2)
            if t1.text == '{'
              convention(nil, t1.pos, 'Space missing inside {.')
            elsif t2.text == '}'
              convention(nil, t2.pos, 'Space missing inside }.')
            end
          end
        end

        def check_no_space_inside_braces(t1, t2)
          if t1.text == '{' || t2.text == '}'
            if space_between?(t1, t2)
              if t1.text == '{'
                convention(nil, space_range(t1), 'Space inside { detected.')
              elsif t2.text == '}'
                convention(nil, space_range(t2), 'Space inside } detected.')
              end
            end
          end
        end

        def check_space_outside_left_brace(t1, t2)
          if t2.text == '{' && !space_between?(t1, t2)
            convention(nil, t2.pos, 'Space missing to the left of {.')
          end
        end

        def check_pipe(t1, t2)
          if cop_config['SpaceBeforeBlockParameters']
            unless space_between?(t1, t2)
              convention(nil, t1.pos, 'Space between { and | missing.')
            end
          elsif space_between?(t1, t2)
            convention(nil, space_range(t1), 'Space between { and | detected.')
          end
        end

        def space_range(token)
          src = @processed_source.buffer.source
          if token.text == '{'
            b = token.pos.begin_pos + 1
            e = b + 1
            e += 1 while src[e] =~ /\s/
          else
            e = token.pos.begin_pos
            b = e - 1
            b -= 1 while src[b - 1] =~ /\s/
          end
          Parser::Source::Range.new(@processed_source.buffer, b, e)
        end
      end

      # Common functionality for checking for spaces inside various
      # kinds of parentheses.
      module SpaceInside
        include SurroundingSpace
        MSG = 'Space inside %s detected.'

        def investigate(processed_source)
          @processed_source = processed_source
          left, right, kind = specifics
          processed_source.tokens.each_cons(2) do |t1, t2|
            if t1.type == left || t2.type == right
              if t2.pos.line == t1.pos.line && space_between?(t1, t2)
                range = Parser::Source::Range.new(processed_source.buffer,
                                                  t1.pos.end_pos,
                                                  t2.pos.begin_pos)
                convention(nil, range, format(MSG, kind))
              end
            end
          end
        end
      end

      # Checks for spaces inside ordinary round parentheses.
      class SpaceInsideParens < Cop
        include SpaceInside

        def specifics
          [:tLPAREN2, :tRPAREN, 'parentheses']
        end
      end

      # Checks for spaces inside square brackets.
      class SpaceInsideBrackets < Cop
        include SpaceInside

        def specifics
          [:tLBRACK, :tRBRACK, 'square brackets']
        end
      end

      # Checks that braces used for hash literals have or don't have
      # surrounding space depending on configuration.
      class SpaceInsideHashLiteralBraces < Cop
        include SurroundingSpace
        MSG = 'Space inside hash literal braces %s.'

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source
          tokens = processed_source.tokens

          on_node(:hash, processed_source.ast) do |hash|
            b_ix = index_of_first_token(hash)
            e_ix = index_of_last_token(hash)
            if tokens[b_ix].type == :tLBRACE # Hash literal with braces?
              check(tokens[b_ix], tokens[b_ix + 1])
              check(tokens[e_ix - 1], tokens[e_ix])
            end
          end
        end

        def check(t1, t2)
          types = [t1, t2].map(&:type)
          braces = [:tLBRACE, :tRCURLY]
          return if types == braces || (braces - types).size == 2
          # No offence if line break inside.
          return if t1.pos.line < t2.pos.line
          has_space = space_between?(t1, t2)
          is_offence, word = if cop_config['EnforcedStyleIsWithSpaces']
                               [!has_space, 'missing']
                             else
                               [has_space, 'detected']
                             end
          brace_token = t1.text == '{' ? t1 : t2
          convention(nil, brace_token.pos, sprintf(MSG, word)) if is_offence
        end
      end

      # Checks that the equals signs in parameter default assignments
      # have surrounding space.
      class SpaceAroundEqualsInParameterDefault < Cop
        include SurroundingSpace
        MSG = 'Surrounding space missing in default value assignment.'

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source
          on_node(:optarg, processed_source.ast) do |optarg|
            index = index_of_first_token(optarg)
            arg, equals, value = processed_source.tokens[index, 3]
            unless space_between?(arg, equals) && space_between?(equals, value)
              convention(nil, equals.pos)
            end
          end
        end
      end
    end
  end
end
