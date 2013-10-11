# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks that operators have space around them, except for **
      # which should not have surrounding space.
      class SpaceAroundOperators < Cop
        include SurroundingSpace
        MSG_MISSING = "Surrounding space missing for operator '%s'."
        MSG_DETECTED = 'Space around operator ** detected.'

        # rubocop:disable SymbolName
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
    end
  end
end
