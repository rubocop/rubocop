# frozen_string_literal: true

RSpec.describe RuboCop::InconsistentConfig do
  include FileHelper

  subject(:warning_message) { warnings.join("\n") }

  let(:warnings) { inconsistent_config.warnings }
  let(:inconsistent_config) { described_class.new(configuration) }
  let(:configuration) { RuboCop::Config.new(hash, loaded_path) }
  let(:loaded_path) { 'example/.rubocop.yml' }
  let(:files) { [described_class::DEFAULT_RULES_FILE] }

  after { described_class.files = [described_class::DEFAULT_RULES_FILE] }

  describe '#validate!', :isolated_environment do
    before { described_class.files = files }

    context 'when the configuration does not include cops that have potential inconsistencies' do
      let(:hash) { {} }

      it 'prints a warning message' do
        inconsistent_config.validate!
        expect(warnings).to be_empty
      end
    end

    context 'when the configuration is consistent' do
      let(:hash) do
        {
          'Style/SafeNavigation' => { 'Enabled' => true, 'MaxChainLength' => 5 },
          'Style/SafeNavigationChainLength' => { 'Enabled' => true, 'Max' => 5 }
        }
      end

      it 'prints a warning message' do
        inconsistent_config.validate!
        expect(warnings).to be_empty
      end
    end

    context 'when the configuration disables cops that have potential inconsistencies' do
      let(:hash) do
        {
          'Style/SafeNavigation' => { 'Enabled' => false, 'MaxChainLength' => 2 },
          'Style/SafeNavigationChainLength' => { 'Enabled' => false, 'Max' => 5 }
        }
      end

      it 'prints a warning message' do
        inconsistent_config.validate!
        expect(warnings).to be_empty
      end
    end

    context 'when the configuration does not have values for every potential inconsistency' do
      let(:hash) do
        {
          'Style/SafeNavigation' => { 'Enabled' => true, 'MaxChainLength' => nil },
          'Style/SafeNavigationChainLength' => { 'Enabled' => true, 'Max' => 5 }
        }
      end

      it 'prints a warning message' do
        inconsistent_config.validate!
        expect(warnings).to be_empty
      end
    end

    context 'when the configuration includes inconsistent parameter values' do
      let(:hash) do
        {
          'Style/SafeNavigation' => { 'Enabled' => true, 'MaxChainLength' => 2 },
          'Style/SafeNavigationChainLength' => { 'Enabled' => true, 'Max' => 5 }
        }
      end

      let(:expected) do
        <<~WARNINGS.chomp
          `Style/SafeNavigation` value for `MaxChainLength` (2) is inconsistent with `Style/SafeNavigationChainLength` value for `Max` (5)
          Use the same value to prevent incompatibilities when evaluating safe navigation chains.
        WARNINGS
      end

      it 'prints a warning message' do
        inconsistent_config.validate!
        expect(warning_message).to eq(expected)
      end
    end

    context 'when additional inconsistencies are defined externally' do
      let(:hash) do
        {
          'A/B' => { 'Enabled' => true, 'Size' => 8 },
          'C/D' => { 'Enabled' => true, 'MaxSize' => 42, 'SeparatorToUse' => '$' },
          'E/F' => { 'Enabled' => true, 'Separator' => '!' }
        }
      end

      let(:files) { [size_inconsistencies, separator_inconsistencies, empty_inconsistencies] }

      let(:size_inconsistencies) do
        create_file('inconsistencies1.yml', <<~YAML)
          size:
            rules:
              - cop: A/B
                parameter: Size
              - cop: C/D
                parameter: MaxSize
        YAML
      end

      let(:separator_inconsistencies) do
        create_file('inconsistencies2.yml', <<~YAML)
          separator:
            rules:
              - cop: E/F
                parameter: Separator
              - cop: C/D
                parameter: SeparatorToUse
        YAML
      end

      let(:empty_inconsistencies) do
        create_file('inconsistencies3.yml', <<~YAML)
          # Placeholder for eventual rules, so we can hook up the file regardless
        YAML
      end

      let(:expected) do
        <<~WARNINGS.chomp
          `A/B` value for `Size` (8) is inconsistent with `C/D` value for `MaxSize` (42)
          `E/F` value for `Separator` (!) is inconsistent with `C/D` value for `SeparatorToUse` ($)
        WARNINGS
      end

      it 'includes rules from all sources' do
        inconsistent_config.validate!
        expect(warning_message).to eq(expected)
      end
    end
  end
end
