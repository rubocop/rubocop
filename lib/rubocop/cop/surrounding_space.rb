# encoding: utf-8

module Rubocop
  module Cop
    module SurroundingSpace
      def inspect(file, source, tokens, ast)
        # TODO
      end
    end

    class SpaceAroundOperators < Cop
      include SurroundingSpace
      MSG = 'Surrounding space missing for operator '
    end

    class SpaceAroundBraces < Cop
      include SurroundingSpace
    end

    module SpaceInside
      include SurroundingSpace
    end

    class SpaceInsideParens < Cop
      include SpaceInside
    end

    class SpaceInsideBrackets < Cop
      include SpaceInside
    end

    class SpaceInsideHashLiteralBraces < Cop
      include SurroundingSpace
    end

    class SpaceAroundEqualsInParameterDefault < Cop
      def inspect(file, source, tokens, ast)
        # TODO
      end
    end
  end
end
