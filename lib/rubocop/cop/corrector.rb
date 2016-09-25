# frozen_string_literal: true

module RuboCop
  module Cop
    # This class takes a source buffer and rewrite its source
    # based on the different correction rules supplied.
    #
    # Important!
    # The nodes modified by the corrections should be part of the
    # AST of the source_buffer.
    class Corrector
      #
      # @param source_buffer [Parser::Source::Buffer]
      # @param corrections [Array(#call)]
      #   Array of Objects that respond to #call. They will receive the
      #   corrector itself and should use its method to modify the source.
      #
      # @example
      #
      #   class AndOrCorrector
      #     def initialize(node)
      #       @node = node
      #     end
      #
      #     def call(corrector)
      #       replacement = (@node.type == :and ? '&&' : '||')
      #       corrector.replace(@node.loc.operator, replacement)
      #     end
      #   end
      #
      #   corrections = [AndOrCorrector.new(node)]
      #   corrector = Corrector.new(source_buffer, corrections)
      def initialize(source_buffer, corrections = [])
        @source_buffer = source_buffer
        @corrections = corrections
        @source_rewriter = Parser::Source::Rewriter.new(source_buffer)

        @diagnostics = []
        # Don't print warnings to stderr if corrections conflict with each other
        @source_rewriter.diagnostics.consumer = lambda do |diagnostic|
          @diagnostics << diagnostic
        end
      end

      attr_reader :corrections, :diagnostics

      # Does the actual rewrite and returns string corresponding to
      # the rewritten source.
      #
      # @return [String]
      def rewrite
        # rubocop:disable Lint/HandleExceptions
        @corrections.each do |correction|
          begin
            @source_rewriter.transaction do
              correction.call(self)
            end
          rescue ::Parser::ClobberingError
          end
        end
        # rubocop:enable Lint/HandleExceptions

        @source_rewriter.process
      end

      # Removes the source range.
      #
      # @param [Parser::Source::Range] range
      def remove(range)
        @source_rewriter.remove(range)
      end

      # Inserts new code before the given source range.
      #
      # @param [Parser::Source::Range] range
      # @param [String] content
      def insert_before(range, content)
        @source_rewriter.insert_before(range, content)
      end

      # Inserts new code after the given source range.
      #
      # @param [Parser::Source::Range] range
      # @param [String] content
      def insert_after(range, content)
        @source_rewriter.insert_after(range, content)
      end

      # Replaces the code of the source range `range` with `content`.
      #
      # @param [Parser::Source::Range] range
      # @param [String] content
      def replace(range, content)
        @source_rewriter.replace(range, content)
      end

      # Removes `size` characters prior to the source range.
      #
      # @param [Parser::Source::Range] range
      # @param [Integer] size
      def remove_preceding(range, size)
        to_remove = Parser::Source::Range.new(range.source_buffer,
                                              range.begin_pos - size,
                                              range.begin_pos)
        @source_rewriter.remove(to_remove)
      end

      # Removes `size` characters from the beginning of the given range.
      # If `size` is greater than the size of `range`, the removed region can
      # overrun the end of `range`.
      #
      # @param [Parser::Source::Range] range
      # @param [Integer] size
      def remove_leading(range, size)
        to_remove = Parser::Source::Range.new(range.source_buffer,
                                              range.begin_pos,
                                              range.begin_pos + size)
        @source_rewriter.remove(to_remove)
      end

      # Removes `size` characters from the end of the given range.
      # If `size` is greater than the size of `range`, the removed region can
      # overrun the beginning of `range`.
      #
      # @param [Parser::Source::Range] range
      # @param [Integer] size
      def remove_trailing(range, size)
        to_remove = Parser::Source::Range.new(range.source_buffer,
                                              range.end_pos - size,
                                              range.end_pos)
        @source_rewriter.remove(to_remove)
      end
    end
  end
end
