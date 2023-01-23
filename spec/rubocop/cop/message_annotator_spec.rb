# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MessageAnnotator do
  let(:options) { {} }
  let(:config) { RuboCop::Config.new({}) }
  let(:cop_name) { 'Cop/Cop' }
  let(:annotator) { described_class.new(config, cop_name, config[cop_name], options) }

  describe '#annotate' do
    subject(:annotate) { annotator.annotate('message') }

    context 'with default options' do
      it 'returns the message' do
        expect(annotate).to eq('message')
      end
    end

    context 'when the output format is JSON' do
      let(:options) { { format: 'json' } }

      it 'returns the message unannotated' do
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
        expect(annotate).to eq('Cop/Cop: message my cop details (http://example.org/styleguide)')
      end
    end
  end

  describe 'with style guide url' do
    subject(:annotate) { annotator.annotate('') }

    let(:cop_name) { 'Cop/Cop' }
    let(:options) { { display_style_guide: true } }

    context 'when StyleGuide is not set in the config' do
      let(:config) { RuboCop::Config.new({}) }

      it 'does not add style guide url' do
        expect(annotate).to eq('')
      end
    end

    context 'when StyleGuide is set in the config' do
      let(:config) do
        RuboCop::Config.new('Cop/Cop' => { 'StyleGuide' => 'http://example.org/styleguide' })
      end

      it 'adds style guide url' do
        expect(annotate.include?('http://example.org/styleguide')).to be(true)
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
        expect(annotate.include?('http://example.org/styleguide#target_based_url')).to be(true)
      end

      context 'when a department other than AllCops is specified' do
        let(:config) do
          RuboCop::Config.new(
            'AllCops' => {
              'StyleGuideBaseURL' => 'http://example.org/styleguide'
            },
            'Foo' => {
              'StyleGuideBaseURL' => 'http://foo.example.org'
            }
          )
        end

        let(:cop_name) { 'Foo/Cop' }
        let(:urls) { annotator.urls }

        it 'returns style guide url when it is specified' do
          config['Foo/Cop'] = { 'StyleGuide' => '#target_style_guide' }

          expect(urls).to eq(%w[http://foo.example.org#target_style_guide])
        end
      end

      context 'when a nested department is specified' do
        let(:config) do
          RuboCop::Config.new(
            'AllCops' => {
              'StyleGuideBaseURL' => 'http://example.org/styleguide'
            },
            'Foo/Bar' => {
              'StyleGuideBaseURL' => 'http://foo.example.org'
            }
          )
        end

        let(:cop_name) { 'Foo/Bar/Cop' }
        let(:urls) { annotator.urls }

        it 'returns style guide url when it is specified' do
          config['Foo/Bar/Cop'] = { 'StyleGuide' => '#target_style_guide' }

          expect(urls).to eq(%w[http://foo.example.org#target_style_guide])
        end
      end

      it 'can use a path-based setting' do
        config['Cop/Cop'] = { 'StyleGuide' => 'cop/path/rule#target_based_url' }
        expect(annotate.include?('http://example.org/cop/path/rule#target_based_url')).to be(true)
      end

      it 'can accept relative paths if base has a full path' do
        config['AllCops'] = {
          'StyleGuideBaseURL' => 'https://github.com/rubocop/ruby-style-guide/'
        }
        config['Cop/Cop'] = { 'StyleGuide' => '../rails-style-guide#target_based_url' }
        expect(annotate.include?('https://github.com/rubocop/rails-style-guide#target_based_url'))
          .to be(true)
      end

      it 'allows absolute URLs in the cop config' do
        config['Cop/Cop'] = { 'StyleGuide' => 'http://other.org#absolute_url' }
        expect(annotate.include?('http://other.org#absolute_url')).to be(true)
      end
    end
  end

  describe '#urls' do
    let(:urls) { annotator.urls }
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'StyleGuideBaseURL' => 'http://example.org/styleguide' })
    end

    it 'returns an empty array without StyleGuide URL' do
      expect(urls.empty?).to be(true)
    end

    it 'returns style guide url when it is specified' do
      config['Cop/Cop'] = { 'StyleGuide' => '#target_based_url' }
      expect(urls).to eq(%w[http://example.org/styleguide#target_based_url])
    end

    it 'returns reference url when it is specified' do
      config['Cop/Cop'] = { 'Reference' => 'https://example.com/some_style_guide' }
      expect(urls).to eq(%w[https://example.com/some_style_guide])
    end

    it 'returns an empty array if the reference url is blank' do
      config['Cop/Cop'] = { 'Reference' => '' }

      expect(urls.empty?).to be(true)
    end

    it 'returns multiple reference urls' do
      config['Cop/Cop'] = {
        'Reference' => ['https://example.com/some_style_guide',
                        'https://example.com/some_other_guide',
                        '']
      }

      expect(urls).to eq(['https://example.com/some_style_guide',
                          'https://example.com/some_other_guide'])
    end

    it 'returns style guide and reference url when they are specified' do
      config['Cop/Cop'] = {
        'StyleGuide' => '#target_based_url',
        'Reference' => 'https://example.com/some_style_guide'
      }
      expect(urls).to eq(%w[http://example.org/styleguide#target_based_url
                            https://example.com/some_style_guide])
    end
  end
end
