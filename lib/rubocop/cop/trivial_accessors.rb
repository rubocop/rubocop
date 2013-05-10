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

      # body statements that exclude a trivial accessor
      NON_TRIVIAL_BODYSTMT = [:void_stmt, :unary, :binary,
                              :@float, :@int, :hash, :begin,
                              :yield0, :zsuper, :array]

      # looking for a trivial reader method
      def trivial_reader?(sexp, accessor_var)
        if reader_shape?(sexp)
          accessor_body = sexp[3][1][0][1][1]
          accessor_body.slice!(0) if accessor_body[0] == '@'
          accessor_var == accessor_body
        end
      end

      # looking for a trivial writer method
      def trivial_writer?(sexp, accessor_var)
        if accessor_var[-1] == '=' &&
           writer_shape?(sexp) &&
           has_only_one_assignment?(sexp)
          accessor_var.chop!
          accessor_body = sexp[3][1][0][1][1][1]
          accessor_body.slice!(0) if accessor_body[0] == '@'
          unless sexp[3][1][0][0] == :vcall
            body_purpose = sexp[3][1][0][2][0]
            accessor_var == accessor_body && body_purpose == :var_ref
          end
        end
      end

      # return true if the sexp is a reader accessor, without params
      # or with empty braces
      def reader_shape?(sexp)
        accessor_shape?(sexp) &&
          (sexp[2][0] == :params || empty_params?(sexp[2]))
      end

      # return true if the sexp is a writer accessor, with a param
      # and with or without braces
      def writer_shape?(sexp)
        accessor_shape?(sexp) && with_braces?(sexp[2])
      end

      # return true if the sexp has the common shape of an accessor
      def accessor_shape?(sexp)
        [:@ident, :@const].include?(sexp[1][0]) &&
        sexp[3][0] == :bodystmt &&
        !NON_TRIVIAL_BODYSTMT.include?(sexp[3][1][0][0])
      end

      # detect "def foo() ..." or
      # "[:paren, [:params, nil, nil, nil, nil, nil, nil, nil]]"
      def empty_params?(sexp)
        sexp[0] == :paren &&
        sexp[1][0] == :params &&
        sexp[1][1..-1].reject { |x| !x }.empty?
      end

      # detect "def name= name" or "def name=(name)
      def with_braces?(sexp)
        (sexp[0] == :paren && sexp[1][0] == :params) ||
          sexp[0] == :params
      end

      # return true if the sexp has only one assignment in the body
      # false otherwise (maybe one or more function calls).
      # why [3..-1]? because:
      # [:bodystmt, [[:assign, [:var_field, [:var_ref ...] and no :vcall
      # thus [:bodystmt, :assign, :var_ref, nil, nil, nil ...]
      def has_only_one_assignment?(sexp)
        sexp[3][1][1] == nil
      end

    end # TrivialAccessors
  end # Cop
end # Rubocop
