# frozen_string_literal: true

describe RuboCop::Cop::MessageAnnotator do
  let(:options) { {} }
  let(:config) { RuboCop::Config.new({}) }
  let(:annotator) { described_class.new(config, config['Cop/Cop'], options) }

  describe '#annotate' do
    subject(:annotate) do
      annotator.annotate('message', 'Cop/Cop')
    end

    context 'with default options' do
      it 'returns the message' do
        expect(annotate).to eq('message')
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
        expect(annotate).to eq(
          'Cop/Cop: message my cop details (http://example.org/styleguide)'
        )
      end
    end
  end

  describe 'with style guide url' do
    subject(:annotate) do
      annotator.annotate('', 'Cop/Cop')
    end

    let(:options) do
      {
        display_style_guide: true
      }
    end

    context 'when StyleGuide is not set in the config' do
      let(:config) { RuboCop::Config.new({}) }

      it 'does not add style guide url' do
        expect(annotate).to eq('')
      end
    end

    context 'when StyleGuide is set in the config' do
      let(:config) do
        RuboCop::Config.new(
          'Cop/Cop' => { 'StyleGuide' => 'http://example.org/styleguide' }
        )
      end

      it 'adds style guide url' do
        expect(annotate).to include('http://example.org/styleguide')
      end
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
        expect(annotate).to eq('')
      end

      it 'combines correctly with a target-based setting' do
        config['Cop/Cop'] = { 'StyleGuide' => '#target_based_url' }
        expect(annotate).to include('http://example.org/styleguide#target_based_url')
      end

      it 'can use a path-based setting' do
        config['Cop/Cop'] = { 'StyleGuide' => 'cop/path/rule#target_based_url' }
        expect(annotate).to include('http://example.org/cop/path/rule#target_based_url')
      end

      it 'can accept relative paths if base has a full path' do
        config['AllCops'] = {
          'StyleGuideBaseURL' => 'http://github.com/bbatsov/ruby-style-guide/'
        }
        config['Cop/Cop'] = {
          'StyleGuide' => '../rails-style-guide#target_based_url'
        }
        expect(annotate).to include('http://github.com/bbatsov/rails-style-guide#target_based_url')
      end

      it 'allows absolute URLs in the cop config' do
        config['Cop/Cop'] = { 'StyleGuide' => 'http://other.org#absolute_url' }
        expect(annotate).to include('http://other.org#absolute_url')
      end
    end
  end

  describe '#urls' do
    let(:urls) { annotator.urls }
    let(:config) do
      RuboCop::Config.new(
        'AllCops' => {
          'StyleGuideBaseURL' => 'http://example.org/styleguide'
        }
      )
    end

    it 'returns an empty array without StyleGuide URL' do
      expect(urls).to be_empty
    end

    it 'returns style guide url when it is specified' do
      config['Cop/Cop'] = { 'StyleGuide' => '#target_based_url' }
      expect(urls).to eq(%w(http://example.org/styleguide#target_based_url))
    end

    it 'returns reference url when it is specified' do
      config['Cop/Cop'] = {
        'Reference' => 'https://example.com/some_style_guide'
      }
      expect(urls).to eq(%w(https://example.com/some_style_guide))
    end

    it 'returns style guide and reference url when they are specified' do
      config['Cop/Cop'] = {
        'StyleGuide' => '#target_based_url',
        'Reference' => 'https://example.com/some_style_guide'
      }
      expect(urls).to eq(%w(http://example.org/styleguide#target_based_url https://example.com/some_style_guide))
    end
  end
end
