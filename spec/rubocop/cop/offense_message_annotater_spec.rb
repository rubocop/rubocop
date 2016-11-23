# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::OffenseMessageAnnotater do
  let(:options) { {} }
  let(:config) { RuboCop::Config.new({}) }
  let(:formatter) { described_class.new(config, config['Cop/Cop'], options) }

  describe '#annotate_message' do
    subject(:annotate_message) do
      formatter.annotate_message('message', 'Cop/Cop')
    end

    context 'with default options' do
      it 'returns the message' do
        expect(annotate_message).to eq('message')
      end
    end

    context 'with options on' do
      let(:options) do
        {
          extra_details: true,
          display_cop_names: true,
          display_style_guide: true
        }
      end
      let(:config) do
        RuboCop::Config.new(
          'Cop/Cop' => {
            'Details' => 'my cop details',
            'StyleGuide' => 'http://example.org/styleguide'
          }
        )
      end

      it 'returns an annotated message' do
        expect(annotate_message).to eq(
          'Cop/Cop: message my cop details (http://example.org/styleguide)'
        )
      end
    end
  end

  describe '#style_guide_url' do
    subject(:url) { formatter.style_guide_url }

    context 'when StyleGuide is not set in the config' do
      let(:config) { RuboCop::Config.new({}) }

      it { is_expected.to be_nil }
    end

    context 'when StyleGuide is set in the config' do
      let(:config) do
        RuboCop::Config.new(
          'Cop/Cop' => { 'StyleGuide' => 'http://example.org/styleguide' }
        )
      end

      it { is_expected.to eq('http://example.org/styleguide') }
    end

    context 'when a base URL is specified' do
      let(:config) do
        RuboCop::Config.new(
          'AllCops' => {
            'StyleGuideBaseURL' => 'http://example.org/styleguide'
          }
        )
      end

      it 'does not specify a URL if a cop does not have one' do
        config['Cop/Cop'] = { 'StyleGuide' => nil }
        expect(url).to be_nil
      end

      it 'combines correctly with a target-based setting' do
        config['Cop/Cop'] = { 'StyleGuide' => '#target_based_url' }
        expect(url).to eq('http://example.org/styleguide#target_based_url')
      end

      it 'can use a path-based setting' do
        config['Cop/Cop'] = { 'StyleGuide' => 'cop/path/rule#target_based_url' }
        expect(url).to eq('http://example.org/cop/path/rule#target_based_url')
      end

      it 'can accept relative paths if base has a full path' do
        config['AllCops'] = {
          'StyleGuideBaseURL' => 'http://github.com/bbatsov/ruby-style-guide/'
        }
        config['Cop/Cop'] = {
          'StyleGuide' => '../rails-style-guide#target_based_url'
        }
        expect(url).to eq('http://github.com/bbatsov/rails-style-guide#target_based_url')
      end

      it 'allows absolute URLs in the cop config' do
        config['Cop/Cop'] = { 'StyleGuide' => 'http://other.org#absolute_url' }
        expect(url).to eq('http://other.org#absolute_url')
      end
    end
  end
end
