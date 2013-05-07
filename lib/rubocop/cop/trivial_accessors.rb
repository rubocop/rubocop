# encoding: utf-8

module Rubocop
  module Cop
    class TrivialAccessors < Cop
      READER_MESSAGE = 'Use attr_reader to define trivial reader methods.'
      WRITER_MESSAGE = 'Use attr_writer to define trivial writer methods.'

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
        if trivial_reader?(sexp, accessor_var)
          add_offence(:convention, lineno, READER_MESSAGE)
        elsif trivial_writer?(sexp, accessor_var)
          add_offence(:convention, lineno, WRITER_MESSAGE)
        end
      end

      NON_TRIVIAL_BODYSTMT = [:void_stmt, :unary, :binary,
                              :@float, :@int, :hash, :begin,
                              :yield0, :zsuper, :array]

      # looking for a trivial reader
      def trivial_reader?(sexp, accessor_var)
        if (sexp[1][0] == :@ident &&
            (sexp[2][0] == :params || empty_params?(sexp[2][0]))
            sexp[3][0] == :bodystmt)
          unless NON_TRIVIAL_BODYSTMT.include? sexp[3][1][0][0]
            accessor_body = sexp[3][1][0][1][1]
            accessor_body.slice!(0) if accessor_body[0] == '@'
            accessor_var == accessor_body
          end
        end
      end

      # detect "def foo() or "
      # "[:paren, [:params, nil, nil, nil, nil, nil, nil, nil]]"
      def empty_params?(sexp)
        sexp[0] == :paren && sexp[1] == :params &&
          sexp[1][1..-1] == nil
      end

      # looking for a trivial writer
      def trivial_writer?(sexp, accessor_var)
        if (accessor_var[-1] == '=' &&
            sexp[1][0] == :@ident &&
            with_braces?(sexp[2]) &&
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

      # detect "def name= name"
      def with_braces?(sexp)
        (sexp[0] == :paren && sexp[1][0] == :params) ||
          sexp[0] == :params
      end

    end # TrivialAccessors
  end # Cop
end # Rubocop
