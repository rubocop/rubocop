# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::LineLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 80 } }

  it "registers an offense for a line that's 81 characters wide" do
    inspect_source(cop, ['#' * 81])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq('Line is too long. [81/80]')
    expect(cop.config_to_allow_offenses).to eq('Max' => 81)
  end

  it 'highlights excessive characters' do
    inspect_source(cop, '#' * 80 + 'abc')
    expect(cop.highlights).to eq(['abc'])
  end

  it "accepts a line that's 80 characters wide" do
    inspect_source(cop, ['#' * 80])
    expect(cop.offenses).to be_empty
  end

  context 'when AllowURI option is enabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => true } }

    context 'and all the excessive characters are part of an URL' do
      # This code example is allowed by AllowURI feature itself :).
      let(:source) { <<-END }
        # Some documentation comment...
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
      END

      it 'accepts the line' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    context 'and the excessive characters include a complete URL' do
      # rubocop:disable Style/LineLength
      let(:source) { <<-END }
        # See: http://google.com/, http://gmail.com/, https://maps.google.com/, http://plus.google.com/
      END
      # rubocop:enable Style/LineLength

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights all the excessive characters' do
        inspect_source(cop, source)
        expect(cop.highlights).to eq(['http://plus.google.com/'])
      end
    end

    context 'and the excessive characters include part of an URL ' \
            'and another word' do
      # rubocop:disable Style/LineLength
      let(:source) { <<-END }
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c and
        #   http://google.com/
      END
      # rubocop:enable Style/LineLength

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights only the non-URL part' do
        inspect_source(cop, source)
        expect(cop.highlights).to eq([' and'])
      end
    end
  end

  context 'when AllowURI option is disabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => false } }

    context 'and all the excessive characters are part of an URL' do
      let(:source) { <<-END }
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
      END

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end
    end
  end
end
