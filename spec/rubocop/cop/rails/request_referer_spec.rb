# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RequestReferer, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is referer' do
    before { inspect_source('puts request.referrer') }
    let(:cop_config) { { 'EnforcedStyle' => 'referer' } }

    it 'registers an offense for request.referrer' do
      expect(cop.offenses.size).to eq(1)
    end

    it 'highlights the offence' do
      expect(cop.highlights).to eq(['request.referrer'])
    end

    it 'sends a message to the user' do
      expect(cop.messages)
        .to eq(['Use `request.referer` instead of `request.referrer`.'])
    end

    it 'autocorrects referrer with referer' do
      corrected = autocorrect_source(['puts request.referrer'])
      expect(corrected).to eq 'puts request.referer'
    end
  end

  context 'when EnforcedStyle is referrer' do
    before { inspect_source('puts request.referer') }
    let(:cop_config) { { 'EnforcedStyle' => 'referrer' } }

    it 'registers an offense for request.referer' do
      expect(cop.offenses.size).to eq(1)
    end

    it 'highlights the offence' do
      expect(cop.highlights).to eq(['request.referer'])
    end

    it 'sends a message to the user' do
      expect(cop.messages)
        .to eq(['Use `request.referrer` instead of `request.referer`.'])
    end

    it 'autocorrects referer with referrer' do
      corrected = autocorrect_source(['puts request.referer'])
      expect(corrected).to eq 'puts request.referrer'
    end
  end
end
