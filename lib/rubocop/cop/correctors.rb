# frozen_string_literal: true

module RuboCop
  module Cop # rubocop:disable Style/Documentation
    # Autoloads corrector classes used by cops. Classes are autoloaded to reduce the number of
    # required classes because they're referenced only when autocorrection is performed.

    # rubocop:disable Layout/LineLength
    autoload :AlignmentCorrector, 'rubocop/cop/correctors/alignment_corrector'
    autoload :ConditionCorrector, 'rubocop/cop/correctors/condition_corrector'
    autoload :EachToForCorrector, 'rubocop/cop/correctors/each_to_for_corrector'
    autoload :EmptyLineCorrector, 'rubocop/cop/correctors/empty_line_corrector'
    autoload :ForToEachCorrector, 'rubocop/cop/correctors/for_to_each_corrector'
    autoload :IfThenCorrector, 'rubocop/cop/correctors/if_then_corrector'
    autoload :LambdaLiteralToMethodCorrector, 'rubocop/cop/correctors/lambda_literal_to_method_corrector'
    autoload :LineBreakCorrector, 'rubocop/cop/correctors/line_break_corrector'
    autoload :MultilineLiteralBraceCorrector, 'rubocop/cop/correctors/multiline_literal_brace_corrector'
    autoload :OrderedGemCorrector, 'rubocop/cop/correctors/ordered_gem_corrector'
    autoload :ParenthesesCorrector, 'rubocop/cop/correctors/parentheses_corrector'
    autoload :PercentLiteralCorrector, 'rubocop/cop/correctors/percent_literal_corrector'
    autoload :PunctuationCorrector, 'rubocop/cop/correctors/punctuation_corrector'
    autoload :RequireLibraryCorrector, 'rubocop/cop/correctors/require_library_corrector'
    autoload :SpaceCorrector, 'rubocop/cop/correctors/space_corrector'
    autoload :StringLiteralCorrector, 'rubocop/cop/correctors/string_literal_corrector'
    autoload :UnusedArgCorrector, 'rubocop/cop/correctors/unused_arg_corrector'
    # rubocop:enable Layout/LineLength
  end
end
