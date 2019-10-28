# frozen_string_literal: true

RSpec.describe RuboCop::ConfigObsoletion do
  include FileHelper

  subject(:config_obsoletion) { described_class.new(configuration) }

  let(:configuration) { RuboCop::Config.new(hash, loaded_path) }
  let(:loaded_path) { 'example/.rubocop.yml' }

  describe '#validate', :isolated_environment do
    let(:configuration_path) { '.rubocop.yml' }

    context 'when the configuration includes any obsolete cop name' do
      let(:hash) do
        {
          # Renamed cops
          'Lint/UnneededCopDisableDirective' => { 'Enabled': true },
          'Lint/UnneededCopEnableDirective' => { 'Enabled': true },
          'Lint/UnneededRequireStatement' => { 'Enabled': true },
          'Lint/UnneededSplatExpansion' => { 'Enabled': true },
          'Style/SingleSpaceBeforeFirstArg' => { 'Enabled': true },
          'Style/MethodCallParentheses' => { 'Enabled': true },
          'Style/DeprecatedHashMethods' => { 'Enabled': true },
          'Style/OpMethod' => { 'Enabled': true },
          'Style/UnneededCapitalW' => { 'Enabled': true },
          'Style/UnneededCondition' => { 'Enabled': true },
          'Style/UnneededInterpolation' => { 'Enabled': true },
          'Style/UnneededPercentQ' => { 'Enabled': true },
          'Style/UnneededSort' => { 'Enabled': true },
          'Layout/AlignArguments' => { 'Enabled': true },
          'Layout/AlignArray' => { 'Enabled': true },
          'Layout/AlignHash' => { 'Enabled': true },
          'Layout/AlignParameters' => { 'Enabled': true },
          'Layout/FirstParameterIndentation' => { 'Enabled': true },
          'Layout/IndentArray' => { 'Enabled': true },
          'Layout/IndentAssignment' => { 'Enabled': true },
          'Layout/IndentFirstArgument' => { 'Enabled': true },
          'Layout/IndentFirstArrayElement' => { 'Enabled': true },
          'Layout/IndentFirstHashElement' => { 'Enabled': true },
          'Layout/IndentFirstParameter' => { 'Enabled': true },
          'Layout/IndentHash' => { 'Enabled': true },
          # Moved cops
          'Lint/Eval' => { 'Enabled': true },
          'Lint/BlockAlignment' => { 'Enabled': true },
          'Lint/EndAlignment' => { 'Enabled': true },
          'Lint/DefEndAlignment' => { 'Enabled': true },
          'Style/ClassAndModuleCamelCase' => { 'Enabled': true },
          'Style/ConstantName' => { 'Enabled': true },
          'Style/FileName' => { 'Enabled': true },
          'Style/MethodName' => { 'Enabled': true },
          'Style/PredicateName' => { 'Enabled': true },
          'Style/VariableName' => { 'Enabled': true },
          'Style/VariableNumber' => { 'Enabled': true },
          'Style/FlipFlop' => { 'Enabled': true },
          'Style/AccessorMethodName' => { 'Enabled': true },
          'Style/AsciiIdentifiers' => { 'Enabled': true },
          # Removed cops
          'Rails/DefaultScope' => { 'Enabled': true },
          'Layout/SpaceAfterControlKeyword' => { 'Enabled': true },
          'Layout/SpaceBeforeModifierKeyword' => { 'Enabled': true },
          'Style/SpaceAfterControlKeyword' => { 'Enabled': true },
          'Style/SpaceBeforeModifierKeyword' => { 'Enabled': true },
          'Style/TrailingComma' => { 'Enabled': true },
          'Style/TrailingCommaInLiteral' => { 'Enabled': true },
          'Lint/RescueWithoutErrorClass' => { 'Enabled': true },
          'Lint/InvalidCharacterLiteral' => { 'Enabled': true },
          'Lint/SpaceBeforeFirstArg' => { 'Enabled': true },
          # Split cops
          'Style/MethodMissing' => { 'Enabled': true }
        }
      end

      let(:expected_message) do
        <<~OUTPUT.chomp
          The `Lint/UnneededCopDisableDirective` cop has been renamed to `Lint/RedundantCopDisableDirective`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/UnneededCopEnableDirective` cop has been renamed to `Lint/RedundantCopEnableDirective`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/UnneededRequireStatement` cop has been renamed to `Lint/RedundantRequireStatement`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/UnneededSplatExpansion` cop has been renamed to `Lint/RedundantSplatExpansion`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/SingleSpaceBeforeFirstArg` cop has been renamed to `Layout/SpaceBeforeFirstArg`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/MethodCallParentheses` cop has been renamed to `Style/MethodCallWithoutArgsParentheses`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/DeprecatedHashMethods` cop has been renamed to `Style/PreferredHashMethods`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/OpMethod` cop has been renamed to `Naming/BinaryOperatorParameterName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/UnneededCapitalW` cop has been renamed to `Style/RedundantCapitalW`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/UnneededCondition` cop has been renamed to `Style/RedundantCondition`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/UnneededInterpolation` cop has been renamed to `Style/RedundantInterpolation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/UnneededPercentQ` cop has been renamed to `Style/RedundantPercentQ`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/UnneededSort` cop has been renamed to `Style/RedundantSort`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/AlignArguments` cop has been renamed to `Layout/ArgumentAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/AlignArray` cop has been renamed to `Layout/ArrayAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/AlignHash` cop has been renamed to `Layout/HashAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/AlignParameters` cop has been renamed to `Layout/ParameterAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentAssignment` cop has been renamed to `Layout/AssignmentIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentFirstArgument` cop has been renamed to `Layout/FirstArgumentIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/FirstParameterIndentation` cop has been renamed to `Layout/FirstArgumentIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentArray` cop has been renamed to `Layout/FirstArrayElementIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentFirstArrayElement` cop has been renamed to `Layout/FirstArrayElementIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentFirstHashElement` cop has been renamed to `Layout/FirstHashElementIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentFirstParameter` cop has been renamed to `Layout/FirstParameterIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentHash` cop has been renamed to `Layout/FirstHashElementIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/Eval` cop has been moved to `Security/Eval`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/ClassAndModuleCamelCase` cop has been moved to `Naming/ClassAndModuleCamelCase`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/ConstantName` cop has been moved to `Naming/ConstantName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/FileName` cop has been moved to `Naming/FileName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/MethodName` cop has been moved to `Naming/MethodName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/PredicateName` cop has been moved to `Naming/PredicateName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/VariableName` cop has been moved to `Naming/VariableName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/VariableNumber` cop has been moved to `Naming/VariableNumber`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/AccessorMethodName` cop has been moved to `Naming/AccessorMethodName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/AsciiIdentifiers` cop has been moved to `Naming/AsciiIdentifiers`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/BlockAlignment` cop has been moved to `Layout/BlockAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/EndAlignment` cop has been moved to `Layout/EndAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/DefEndAlignment` cop has been moved to `Layout/DefEndAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/FlipFlop` cop has been moved to `Lint/FlipFlop`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Rails/DefaultScope` cop has been removed.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/SpaceAfterControlKeyword` cop has been removed. Please use `Layout/SpaceAroundKeyword` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/SpaceBeforeModifierKeyword` cop has been removed. Please use `Layout/SpaceAroundKeyword` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/SpaceAfterControlKeyword` cop has been removed. Please use `Layout/SpaceAroundKeyword` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/SpaceBeforeModifierKeyword` cop has been removed. Please use `Layout/SpaceAroundKeyword` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/TrailingComma` cop has been removed. Please use `Style/TrailingCommaInArguments`, `Style/TrailingCommaInArrayLiteral`, and/or `Style/TrailingCommaInHashLiteral` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/TrailingCommaInLiteral` cop has been removed. Please use `Style/TrailingCommaInArrayLiteral` and/or `Style/TrailingCommaInHashLiteral` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/RescueWithoutErrorClass` cop has been removed. Please use `Style/RescueStandardError` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/InvalidCharacterLiteral` cop has been removed since it was never being actually triggered.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/SpaceBeforeFirstArg` cop has been removed since it was a duplicate of `Layout/SpaceBeforeFirstArg`. Please use `Layout/SpaceBeforeFirstArg` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/MethodMissing` cop has been split into `Style/MethodMissingSuper` and `Style/MissingRespondToMissing`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
        OUTPUT
      end

      it 'prints a warning message' do
        begin
          config_obsoletion.reject_obsolete_cops_and_parameters
          raise 'Expected a RuboCop::ValidationError'
        rescue RuboCop::ValidationError => e
          expect(expected_message).to eq(e.message)
        end
      end
    end

    context 'when the configuration includes any obsolete parameters' do
      let(:hash) do
        {
          'Layout/SpaceAroundOperators' => {
            'MultiSpaceAllowedForOperators' => true
          },
          'Style/SpaceAroundOperators' => {
            'MultiSpaceAllowedForOperators' => true
          },
          'Style/Encoding' => {
            'EnforcedStyle' => 'a',
            'SupportedStyles' => %w[a b c],
            'AutoCorrectEncodingComment' => true
          },
          'Style/IfUnlessModifier' => { 'MaxLineLength' => 100 },
          'Style/WhileUntilModifier' => { 'MaxLineLength' => 100 },
          'AllCops' => { 'RunRailsCops' => true },
          'Layout/CaseIndentation' => { 'IndentWhenRelativeTo' => 'end' },
          'Layout/BlockAlignment' => { 'AlignWith' => 'end' },
          'Layout/EndAlignment' => { 'AlignWith' => 'end' },
          'Layout/DefEndAlignment' => { 'AlignWith' => 'end' },
          'Rails/UniqBeforePluck' => { 'EnforcedMode' => 'x' },
          # Moved cops with obsolete parameters
          'Lint/BlockAlignment' => { 'AlignWith' => 'end' },
          'Lint/EndAlignment' => { 'AlignWith' => 'end' },
          'Lint/DefEndAlignment' => { 'AlignWith' => 'end' }
        }
      end

      let(:expected_message) do
        <<~OUTPUT.chomp
          The `Lint/BlockAlignment` cop has been moved to `Layout/BlockAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/EndAlignment` cop has been moved to `Layout/EndAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/DefEndAlignment` cop has been moved to `Layout/DefEndAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          obsolete parameter MultiSpaceAllowedForOperators (for Layout/SpaceAroundOperators) found in example/.rubocop.yml
          If your intention was to allow extra spaces for alignment, please use AllowForAlignment: true instead.
          obsolete parameter MultiSpaceAllowedForOperators (for Style/SpaceAroundOperators) found in example/.rubocop.yml
          If your intention was to allow extra spaces for alignment, please use AllowForAlignment: true instead.
          obsolete parameter EnforcedStyle (for Style/Encoding) found in example/.rubocop.yml
          Style/Encoding no longer supports styles. The "never" behavior is always assumed.
          obsolete parameter SupportedStyles (for Style/Encoding) found in example/.rubocop.yml
          Style/Encoding no longer supports styles. The "never" behavior is always assumed.
          obsolete parameter AutoCorrectEncodingComment (for Style/Encoding) found in example/.rubocop.yml
          Style/Encoding no longer supports styles. The "never" behavior is always assumed.
          obsolete parameter MaxLineLength (for Style/IfUnlessModifier) found in example/.rubocop.yml
          `Style/IfUnlessModifier: MaxLineLength` has been removed. Use `Metrics/LineLength: Max` instead
          obsolete parameter MaxLineLength (for Style/WhileUntilModifier) found in example/.rubocop.yml
          `Style/WhileUntilModifier: MaxLineLength` has been removed. Use `Metrics/LineLength: Max` instead
          obsolete parameter RunRailsCops (for AllCops) found in example/.rubocop.yml
          Use the following configuration instead:
          Rails:
            Enabled: true
          obsolete parameter IndentWhenRelativeTo (for Layout/CaseIndentation) found in example/.rubocop.yml
          `IndentWhenRelativeTo` has been renamed to `EnforcedStyle`
          obsolete parameter AlignWith (for Lint/BlockAlignment) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`
          obsolete parameter AlignWith (for Layout/BlockAlignment) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`
          obsolete parameter AlignWith (for Lint/EndAlignment) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`
          obsolete parameter AlignWith (for Layout/EndAlignment) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`
          obsolete parameter AlignWith (for Lint/DefEndAlignment) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`
          obsolete parameter AlignWith (for Layout/DefEndAlignment) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`
          obsolete parameter EnforcedMode (for Rails/UniqBeforePluck) found in example/.rubocop.yml
          `EnforcedMode` has been renamed to `EnforcedStyle`
        OUTPUT
      end

      it 'prints a warning message' do
        begin
          config_obsoletion.reject_obsolete_cops_and_parameters
          raise 'Expected a RuboCop::ValidationError'
        rescue RuboCop::ValidationError => e
          expect(expected_message).to eq(e.message)
        end
      end
    end
  end
end
