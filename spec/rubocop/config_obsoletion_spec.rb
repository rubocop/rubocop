# frozen_string_literal: true

RSpec.describe RuboCop::ConfigObsoletion do
  include FileHelper

  subject(:config_obsoletion) { described_class.new(configuration) }

  let(:configuration) { RuboCop::Config.new(hash, loaded_path) }
  let(:loaded_path) { 'example/.rubocop.yml' }
  let(:requires) { [] }

  before do
    allow(configuration).to receive(:loaded_features).and_return(requires)
    described_class.files = [described_class::DEFAULT_RULES_FILE]
  end

  after { described_class.files = [described_class::DEFAULT_RULES_FILE] }

  describe '#validate', :isolated_environment do
    context 'when the configuration includes any obsolete cop name' do
      let(:hash) do
        {
          # Renamed cops
          'Layout/AlignArguments' => { Enabled: true },
          'Layout/AlignArray' => { Enabled: true },
          'Layout/AlignHash' => { Enabled: true },
          'Layout/AlignParameters' => { Enabled: true },
          'Layout/FirstParameterIndentation' => { Enabled: true },
          'Layout/IndentArray' => { Enabled: true },
          'Layout/IndentAssignment' => { Enabled: true },
          'Layout/IndentFirstArgument' => { Enabled: true },
          'Layout/IndentFirstArrayElement' => { Enabled: true },
          'Layout/IndentFirstHashElement' => { Enabled: true },
          'Layout/IndentFirstParameter' => { Enabled: true },
          'Layout/IndentHash' => { Enabled: true },
          'Layout/IndentHeredoc' => { Enabled: true },
          'Layout/LeadingBlankLines' => { Enabled: true },
          'Layout/Tab' => { Enabled: true },
          'Layout/TrailingBlankLines' => { Enabled: true },
          'Lint/DuplicatedKey' => { Enabled: true },
          'Lint/HandleExceptions' => { Enabled: true },
          'Lint/MultipleCompare' => { Enabled: true },
          'Lint/StringConversionInInterpolation' => { Enabled: true },
          'Lint/UnneededCopDisableDirective' => { Enabled: true },
          'Lint/UnneededCopEnableDirective' => { Enabled: true },
          'Lint/UnneededRequireStatement' => { Enabled: true },
          'Lint/UnneededSplatExpansion' => { Enabled: true },
          'Naming/UncommunicativeBlockParamName' => { Enabled: true },
          'Naming/UncommunicativeMethodParamName' => { Enabled: true },
          'Style/DeprecatedHashMethods' => { Enabled: true },
          'Style/MethodCallParentheses' => { Enabled: true },
          'Style/OpMethod' => { Enabled: true },
          'Style/SingleSpaceBeforeFirstArg' => { Enabled: true },
          'Style/UnneededCapitalW' => { Enabled: true },
          'Style/UnneededCondition' => { Enabled: true },
          'Style/UnneededInterpolation' => { Enabled: true },
          'Style/UnneededPercentQ' => { Enabled: true },
          'Style/UnneededSort' => { Enabled: true },
          # Moved cops
          'Lint/BlockAlignment' => { Enabled: true },
          'Lint/DefEndAlignment' => { Enabled: true },
          'Lint/EndAlignment' => { Enabled: true },
          'Lint/Eval' => { Enabled: true },
          'Style/AccessorMethodName' => { Enabled: true },
          'Style/AsciiIdentifiers' => { Enabled: true },
          'Style/ClassAndModuleCamelCase' => { Enabled: true },
          'Style/ConstantName' => { Enabled: true },
          'Style/FileName' => { Enabled: true },
          'Style/FlipFlop' => { Enabled: true },
          'Style/MethodName' => { Enabled: true },
          'Style/PredicateName' => { Enabled: true },
          'Style/VariableName' => { Enabled: true },
          'Style/VariableNumber' => { Enabled: true },
          # Removed cops
          'Layout/SpaceAfterControlKeyword' => { Enabled: true },
          'Layout/SpaceBeforeModifierKeyword' => { Enabled: true },
          'Lint/InvalidCharacterLiteral' => { Enabled: true },
          'Style/MethodMissingSuper' => { Enabled: true },
          'Lint/UselessComparison' => { Enabled: true },
          'Lint/RescueWithoutErrorClass' => { Enabled: true },
          'Lint/SpaceBeforeFirstArg' => { Enabled: true },
          'Style/SpaceAfterControlKeyword' => { Enabled: true },
          'Style/SpaceBeforeModifierKeyword' => { Enabled: true },
          'Style/TrailingComma' => { Enabled: true },
          'Style/TrailingCommaInLiteral' => { Enabled: true },
          # Split cops
          'Style/MethodMissing' => { Enabled: true }
        }
      end

      let(:expected_message) do
        <<~OUTPUT.chomp
          The `Layout/AlignArguments` cop has been renamed to `Layout/ArgumentAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/AlignArray` cop has been renamed to `Layout/ArrayAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/AlignHash` cop has been renamed to `Layout/HashAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/AlignParameters` cop has been renamed to `Layout/ParameterAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentArray` cop has been renamed to `Layout/FirstArrayElementIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentAssignment` cop has been renamed to `Layout/AssignmentIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentFirstArgument` cop has been renamed to `Layout/FirstArgumentIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentFirstArrayElement` cop has been renamed to `Layout/FirstArrayElementIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentFirstHashElement` cop has been renamed to `Layout/FirstHashElementIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentFirstParameter` cop has been renamed to `Layout/FirstParameterIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentHash` cop has been renamed to `Layout/FirstHashElementIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/IndentHeredoc` cop has been renamed to `Layout/HeredocIndentation`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/LeadingBlankLines` cop has been renamed to `Layout/LeadingEmptyLines`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/Tab` cop has been renamed to `Layout/IndentationStyle`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/TrailingBlankLines` cop has been renamed to `Layout/TrailingEmptyLines`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/BlockAlignment` cop has been moved to `Layout/BlockAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/DefEndAlignment` cop has been moved to `Layout/DefEndAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/DuplicatedKey` cop has been renamed to `Lint/DuplicateHashKey`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/EndAlignment` cop has been moved to `Layout/EndAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/Eval` cop has been moved to `Security/Eval`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/HandleExceptions` cop has been renamed to `Lint/SuppressedException`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/MultipleCompare` cop has been renamed to `Lint/MultipleComparison`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/StringConversionInInterpolation` cop has been renamed to `Lint/RedundantStringCoercion`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/UnneededCopDisableDirective` cop has been renamed to `Lint/RedundantCopDisableDirective`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/UnneededCopEnableDirective` cop has been renamed to `Lint/RedundantCopEnableDirective`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/UnneededRequireStatement` cop has been renamed to `Lint/RedundantRequireStatement`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/UnneededSplatExpansion` cop has been renamed to `Lint/RedundantSplatExpansion`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Naming/UncommunicativeBlockParamName` cop has been renamed to `Naming/BlockParameterName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Naming/UncommunicativeMethodParamName` cop has been renamed to `Naming/MethodParameterName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/AccessorMethodName` cop has been moved to `Naming/AccessorMethodName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/AsciiIdentifiers` cop has been moved to `Naming/AsciiIdentifiers`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/ClassAndModuleCamelCase` cop has been moved to `Naming/ClassAndModuleCamelCase`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/ConstantName` cop has been moved to `Naming/ConstantName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/DeprecatedHashMethods` cop has been renamed to `Style/PreferredHashMethods`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/FileName` cop has been moved to `Naming/FileName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/FlipFlop` cop has been moved to `Lint/FlipFlop`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/MethodCallParentheses` cop has been renamed to `Style/MethodCallWithoutArgsParentheses`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/MethodName` cop has been moved to `Naming/MethodName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/OpMethod` cop has been renamed to `Naming/BinaryOperatorParameterName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/PredicateName` cop has been moved to `Naming/PredicateName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/SingleSpaceBeforeFirstArg` cop has been renamed to `Layout/SpaceBeforeFirstArg`.
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
          The `Style/VariableName` cop has been moved to `Naming/VariableName`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/VariableNumber` cop has been moved to `Naming/VariableNumber`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/SpaceAfterControlKeyword` cop has been removed. Please use `Layout/SpaceAroundKeyword` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Layout/SpaceBeforeModifierKeyword` cop has been removed. Please use `Layout/SpaceAroundKeyword` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/InvalidCharacterLiteral` cop has been removed since it was never being actually triggered.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/RescueWithoutErrorClass` cop has been removed. Please use `Style/RescueStandardError` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/SpaceBeforeFirstArg` cop has been removed since it was a duplicate of `Layout/SpaceBeforeFirstArg`. Please use `Layout/SpaceBeforeFirstArg` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/UselessComparison` cop has been removed since it has been superseded by `Lint/BinaryOperatorWithIdenticalOperands`. Please use `Lint/BinaryOperatorWithIdenticalOperands` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/MethodMissingSuper` cop has been removed since it has been superseded by `Lint/MissingSuper`. Please use `Lint/MissingSuper` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/SpaceAfterControlKeyword` cop has been removed. Please use `Layout/SpaceAroundKeyword` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/SpaceBeforeModifierKeyword` cop has been removed. Please use `Layout/SpaceAroundKeyword` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/TrailingComma` cop has been removed. Please use `Style/TrailingCommaInArguments`, `Style/TrailingCommaInArrayLiteral` and/or `Style/TrailingCommaInHashLiteral` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/TrailingCommaInLiteral` cop has been removed. Please use `Style/TrailingCommaInArrayLiteral` and/or `Style/TrailingCommaInHashLiteral` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Style/MethodMissing` cop has been split into `Style/MethodMissingSuper` and `Style/MissingRespondToMissing`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
        OUTPUT
      end

      it 'prints a warning message' do
        config_obsoletion.reject_obsolete!
        raise 'Expected a RuboCop::ValidationError'
      rescue RuboCop::ValidationError => e
        expect(e.message).to eq(expected_message)
      end
    end

    context 'when the configuration includes any extracted cops' do
      let(:hash) do
        {
          'Performance/Casecmp' => { Enabled: true },
          'Performance/RedundantSortBlock' => { Enabled: true },
          'Rails/Date' => { Enabled: true },
          'Rails/DynamicFindBy' => { Enabled: true }
        }
      end

      context 'when the extensions are loaded' do
        let(:requires) { %w[rubocop-rails rubocop-performance] }

        it 'does not print a warning message' do
          expect { config_obsoletion.reject_obsolete! }.not_to raise_error
        end
      end

      context 'when only one extension is loaded' do
        let(:requires) { %w[rubocop-performance] }

        let(:expected_message) do
          <<~OUTPUT.chomp
            `Rails` cops have been extracted to the `rubocop-rails` gem.
            (obsolete configuration found in example/.rubocop.yml, please update it)
          OUTPUT
        end

        it 'prints a warning message' do
          config_obsoletion.reject_obsolete!
          raise 'Expected a RuboCop::ValidationError'
        rescue RuboCop::ValidationError => e
          expect(e.message).to eq(expected_message)
        end
      end

      context 'when the extensions are not loaded' do
        let(:expected_message) do
          <<~OUTPUT.chomp
            `Performance` cops have been extracted to the `rubocop-performance` gem.
            (obsolete configuration found in example/.rubocop.yml, please update it)
            `Rails` cops have been extracted to the `rubocop-rails` gem.
            (obsolete configuration found in example/.rubocop.yml, please update it)
          OUTPUT
        end

        it 'prints a warning message' do
          config_obsoletion.reject_obsolete!
          raise 'Expected a RuboCop::ValidationError'
        rescue RuboCop::ValidationError => e
          expect(e.message).to eq(expected_message)
        end
      end
    end

    context 'when the extensions are loaded via inherit_gem', :restore_registry do
      let(:resolver) { RuboCop::ConfigLoaderResolver.new }
      let(:gem_root) { File.expand_path('gems') }

      let(:hash) do
        {
          'inherit_gem' => { 'rubocop-includes' => '.rubocop.yml' },
          'Performance/Casecmp' => { Enabled: true }
        }
      end

      before do
        create_file("#{gem_root}/rubocop-includes/.rubocop.yml", <<~YAML)
          require:
            - rubocop-performance
        YAML

        # Mock out a gem in order to test `inherit_gem`.
        gem_class = Struct.new(:gem_dir)
        mock_spec = gem_class.new(File.join(gem_root, 'rubocop-includes'))
        allow(Gem::Specification).to receive(:find_by_name)
          .with('rubocop-includes').and_return(mock_spec)

        # Resolve `inherit_gem`
        resolver.resolve_inheritance_from_gems(hash)
        resolver.resolve_inheritance(loaded_path, hash, loaded_path, false)

        allow(configuration).to receive(:loaded_features).and_call_original
      end

      it 'does not raise a ValidationError' do
        expect { config_obsoletion.reject_obsolete! }.not_to raise_error
      end
    end

    context 'when the configuration includes any obsolete parameters' do
      before { allow(configuration).to receive(:loaded_features).and_return(%w[rubocop-rails]) }

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
          'Lint/DefEndAlignment' => { 'AlignWith' => 'end' },
          # Obsolete EnforcedStyles
          'Layout/IndentationConsistency' => { 'EnforcedStyle' => 'rails' }
        }
      end

      let(:expected_message) do
        <<~OUTPUT.chomp
          The `Lint/BlockAlignment` cop has been moved to `Layout/BlockAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/DefEndAlignment` cop has been moved to `Layout/DefEndAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Lint/EndAlignment` cop has been moved to `Layout/EndAlignment`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          obsolete parameter `MultiSpaceAllowedForOperators` (for `Layout/SpaceAroundOperators`) found in example/.rubocop.yml
          If your intention was to allow extra spaces for alignment, please use `AllowForAlignment: true` instead.
          obsolete parameter `MultiSpaceAllowedForOperators` (for `Style/SpaceAroundOperators`) found in example/.rubocop.yml
          If your intention was to allow extra spaces for alignment, please use `AllowForAlignment: true` instead.
          obsolete parameter `EnforcedStyle` (for `Style/Encoding`) found in example/.rubocop.yml
          `Style/Encoding` no longer supports styles. The "never" behavior is always assumed.
          obsolete parameter `SupportedStyles` (for `Style/Encoding`) found in example/.rubocop.yml
          `Style/Encoding` no longer supports styles. The "never" behavior is always assumed.
          obsolete parameter `AutoCorrectEncodingComment` (for `Style/Encoding`) found in example/.rubocop.yml
          `Style/Encoding` no longer supports styles. The "never" behavior is always assumed.
          obsolete parameter `MaxLineLength` (for `Style/IfUnlessModifier`) found in example/.rubocop.yml
          `Style/IfUnlessModifier: MaxLineLength` has been removed. Use `Layout/LineLength: Max` instead
          obsolete parameter `MaxLineLength` (for `Style/WhileUntilModifier`) found in example/.rubocop.yml
          `Style/WhileUntilModifier: MaxLineLength` has been removed. Use `Layout/LineLength: Max` instead
          obsolete parameter `RunRailsCops` (for `AllCops`) found in example/.rubocop.yml
          Use the following configuration instead:
          Rails:
            Enabled: true
          obsolete parameter `IndentWhenRelativeTo` (for `Layout/CaseIndentation`) found in example/.rubocop.yml
          `IndentWhenRelativeTo` has been renamed to `EnforcedStyle`.
          obsolete parameter `AlignWith` (for `Lint/BlockAlignment`) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`.
          obsolete parameter `AlignWith` (for `Layout/BlockAlignment`) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`.
          obsolete parameter `AlignWith` (for `Lint/EndAlignment`) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`.
          obsolete parameter `AlignWith` (for `Layout/EndAlignment`) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`.
          obsolete parameter `AlignWith` (for `Lint/DefEndAlignment`) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`.
          obsolete parameter `AlignWith` (for `Layout/DefEndAlignment`) found in example/.rubocop.yml
          `AlignWith` has been renamed to `EnforcedStyleAlignWith`.
          obsolete parameter `EnforcedMode` (for `Rails/UniqBeforePluck`) found in example/.rubocop.yml
          `EnforcedMode` has been renamed to `EnforcedStyle`.
          obsolete `EnforcedStyle: rails` (for `Layout/IndentationConsistency`) found in example/.rubocop.yml
          `EnforcedStyle: rails` has been renamed to `EnforcedStyle: indented_internal_methods`.
        OUTPUT
      end

      it 'prints a error message' do
        config_obsoletion.reject_obsolete!
        raise 'Expected a RuboCop::ValidationError'
      rescue RuboCop::ValidationError => e
        expect(e.message).to eq(expected_message)
      end
    end

    context 'when the configuration includes any deprecated parameters' do
      let(:hash) do
        {
          'Lint/AmbiguousBlockAssociation' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Lint/NumberConversion' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Metrics/AbcSize' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Metrics/BlockLength' => {
            'ExcludedMethods' => %w[foo bar],
            'IgnoredMethods' => %w[foo bar]
          },
          'Metrics/CyclomaticComplexity' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Metrics/MethodLength' => {
            'ExcludedMethods' => %w[foo bar],
            'IgnoredMethods' => %w[foo bar]
          },
          'Metrics/PerceivedComplexity' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Style/BlockDelimiters' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Style/ClassEqualityComparison' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Style/FormatStringToken' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Style/MethodCallWithArgsParentheses' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Style/MethodCallWithoutArgsParentheses' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Style/NumericPredicate' => {
            'IgnoredMethods' => %w[foo bar]
          },
          'Style/SymbolLiteral' => {
            'IgnoredMethods' => %w[foo bar]
          }
        }
      end

      let(:warning_message)  { config_obsoletion.warnings.join("\n") }

      let(:expected_message) do
        <<~OUTPUT.chomp
          obsolete parameter `ExcludedMethods` (for `Metrics/BlockLength`) found in example/.rubocop.yml
          `ExcludedMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `ExcludedMethods` (for `Metrics/MethodLength`) found in example/.rubocop.yml
          `ExcludedMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Lint/AmbiguousBlockAssociation`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Lint/NumberConversion`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Metrics/AbcSize`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Metrics/BlockLength`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Metrics/CyclomaticComplexity`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Metrics/MethodLength`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Metrics/PerceivedComplexity`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Style/BlockDelimiters`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Style/ClassEqualityComparison`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Style/FormatStringToken`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Style/MethodCallWithArgsParentheses`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Style/MethodCallWithoutArgsParentheses`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Style/NumericPredicate`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
          obsolete parameter `IgnoredMethods` (for `Style/SymbolLiteral`) found in example/.rubocop.yml
          `IgnoredMethods` has been renamed to `AllowedMethods` and/or `AllowedPatterns`.
        OUTPUT
      end

      it 'prints a warning message' do
        expect { config_obsoletion.reject_obsolete! }.not_to raise_error
        expect(warning_message).to eq(expected_message)
      end
    end

    context 'when additional obsoletions are defined externally' do
      let(:hash) do
        {
          'Foo/Bar' => { Enabled: true },
          'Vegetable/Tomato' => { Enabled: true },
          'Legacy/Test' => { Enabled: true },
          'Other/Cop' => { Enabled: true },
          'Style/FlipFlop' => { Enabled: true }
        }
      end

      let(:file_with_renamed_config) do
        create_file('obsoletions1.yml', <<~YAML)
          renamed:
            Foo/Bar: Foo/Baz
            Vegetable/Tomato: Fruit/Tomato
        YAML
      end

      let(:file_with_removed_and_split_config) do
        create_file('obsoletions2.yml', <<~YAML)
          removed:
            Legacy/Test:
              alternatives:
                - Style/Something

          split:
            Other/Cop:
              alternatives:
                - Style/One
                - Style/Two
        YAML
      end

      let(:expected_message) do
        <<~OUTPUT.chomp
          The `Style/FlipFlop` cop has been moved to `Lint/FlipFlop`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Foo/Bar` cop has been renamed to `Foo/Baz`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Vegetable/Tomato` cop has been moved to `Fruit/Tomato`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Legacy/Test` cop has been removed. Please use `Style/Something` instead.
          (obsolete configuration found in example/.rubocop.yml, please update it)
          The `Other/Cop` cop has been split into `Style/One` and `Style/Two`.
          (obsolete configuration found in example/.rubocop.yml, please update it)
        OUTPUT
      end

      it 'includes obsoletions from all sources' do
        described_class.files << file_with_renamed_config
        described_class.files << file_with_removed_and_split_config

        begin
          config_obsoletion.reject_obsolete!
          raise 'Expected a RuboCop::ValidationError'
        rescue RuboCop::ValidationError => e
          expect(e.message).to eq(expected_message)
        end
      end
    end

    context 'when extractions are disabled by an external library' do
      let(:hash) { { 'Performance/CollectionLiteralInLoop' => { Enabled: true } } }

      let(:external_obsoletions) do
        create_file('external/obsoletions.yml', <<~YAML)
          extracted:
            Performance/*: ~
        YAML
      end

      it 'allows the extracted cops' do
        described_class.files << external_obsoletions

        expect { config_obsoletion.reject_obsolete! }.not_to raise_error
      end
    end

    context 'when using `changed_parameters` by an external library' do
      let(:hash) { {} }
      let(:external_obsoletions) do
        create_file('external/obsoletions.yml', <<~YAML)
          changed_parameters:
            - cops: Rails/FindEach
              parameters: IgnoredMethods
              alternatives:
                - AllowedMethods
                - AllowedPatterns
              severity: warning
        YAML
      end

      it 'allows the extracted cops' do
        described_class.files << external_obsoletions

        expect { config_obsoletion.reject_obsolete! }.not_to raise_error
      end
    end
  end
end
