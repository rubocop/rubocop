# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RequestReferer, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is referer' do
    let(:cop_config) { { 'EnforcedStyle' => 'referer' } }

    it 'registers an offense for request.referrer' do
      expect_offense(<<-RUBY.strip_indent)
        puts request.referrer
             ^^^^^^^^^^^^^^^^ Use `request.referer` instead of `request.referrer`.
      RUBY
    end

    it 'autocorrects referrer with referer' do
      corrected = autocorrect_source(['puts request.referrer'])
      expect(corrected).to eq 'puts request.referer'
    end
  end

  context 'when EnforcedStyle is referrer' do
    let(:cop_config) { { 'EnforcedStyle' => 'referrer' } }

    it 'registers an offense for request.referer' do
      expect_offense(<<-RUBY.strip_indent)
        puts request.referer
             ^^^^^^^^^^^^^^^ Use `request.referrer` instead of `request.referer`.
      RUBY
    end

    it 'autocorrects referer with referrer' do
      corrected = autocorrect_source(['puts request.referer'])
      expect(corrected).to eq 'puts request.referrer'
    end
  end
end
