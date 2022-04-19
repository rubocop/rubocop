# frozen_string_literal: true

RSpec.describe RuboCop::ConfigObsoletion::RenamedCop do
  subject(:rule) { described_class.new(config, old_name, new_name) }

  let(:config) { instance_double(RuboCop::Config, loaded_path: '.rubocop.yml').as_null_object }
  let(:old_name) { 'Style/MyCop' }

  describe '#message' do
    subject { rule.message }

    context 'when the cop has changed names but in the same department' do
      let(:new_name) { 'Style/NewCop' }

      it { is_expected.to start_with('The `Style/MyCop` cop has been renamed to `Style/NewCop`') }
    end

    context 'when the cop has changed names but in a new department' do
      let(:new_name) { 'Layout/NewCop' }

      it { is_expected.to start_with('The `Style/MyCop` cop has been renamed to `Layout/NewCop`') }
    end

    context 'when the cop has been moved to a new department' do
      let(:new_name) { 'Layout/MyCop' }

      it { is_expected.to start_with('The `Style/MyCop` cop has been moved to `Layout/MyCop`') }
    end
  end
end
