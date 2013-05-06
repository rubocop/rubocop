# encoding: utf-8

module Rubocop
  module Cop
    class TrivialAccessors < Cop
      ERROR_MESSAGE = <<-SUGGESTION
'Prefer the attr family of functions to define trivial accessors or mutators.'
      SUGGESTION

      def inspect(file, source, token, sexp)
        each(:def, sexp) do |def_block|
          find_trivial_accessors def_block
        end
      end

      private

      # Parse the sexp given, corresponding to a def method.
      # Looking for a trivial reader/writer pattern
      def find_trivial_accessors(sexp)
        lineno = sexp[1][2].lineno
        accessor_var = sexp[1][1]
        if (is_trivial_reader(sexp, accessor_var) ||
            is_trivial_writer(sexp, accessor_var))
          add_offence(:convention, lineno, ERROR_MESSAGE)
        end
      end

      NON_TRIVIAL_BODYSTMT = [:void_stmt, :unary, :binary,
                              :@float, :@int, :hash, :begin,
                              :yield0]

      # looking for a trivial reader
      def is_trivial_reader(sexp, accessor_var)
        if (sexp[1][0] == :@ident &&
            sexp[2][0] == :params &&
            sexp[3][0] == :bodystmt)
          unless NON_TRIVIAL_BODYSTMT.include? sexp[3][1][0][0]
            accessor_body = sexp[3][1][0][1][1]
            accessor_body.slice!(0) if accessor_body[0] == '@'
            accessor_var == accessor_body
          end
        end
      end

      # looking for a trivial writer
      def is_trivial_writer(sexp, accessor_var)
        if (accessor_var[-1] == '=' &&
            sexp[1][0] == :@ident &&
            sexp[2][0] == :paren &&
            sexp[2][1][0] == :params &&
            sexp[3][0] == :bodystmt)
          unless NON_TRIVIAL_BODYSTMT.include? sexp[3][1][0][0]
            accessor_var.chop!
            accessor_body = sexp[3][1][0][1][1][1]
            accessor_body.slice!(0) if accessor_body[0] == '@'
            unless sexp[3][1][0][0] == :vcall
              body_purpose = sexp[3][1][0][2][0]
              accessor_var == accessor_body && body_purpose == :var_ref
            end
          end
        end
      end

    end # TrivialAccessors
  end # Cop
end # Rubocop
