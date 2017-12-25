# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassCheck, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is is_a?' do
    let(:cop_config) { { 'EnforcedStyle' => 'is_a?' } }

    it 'registers an offense for kind_of?' do
      expect_offense(<<-RUBY.strip_indent)
        x.kind_of? y
          ^^^^^^^^ Prefer `Object#is_a?` over `Object#kind_of?`.
      RUBY
    end

    it 'auto-corrects kind_of? to is_a?' do
      corrected = autocorrect_source(['x.kind_of? y'])
      expect(corrected).to eq 'x.is_a? y'
    end
  end

  context 'when enforced style is kind_of?' do
    let(:cop_config) { { 'EnforcedStyle' => 'kind_of?' } }

    it 'registers an offense for is_a?' do
      expect_offense(<<-RUBY.strip_indent)
        x.is_a? y
          ^^^^^ Prefer `Object#kind_of?` over `Object#is_a?`.
      RUBY
    end

    it 'auto-corrects is_a? to kind_of?' do
      corrected = autocorrect_source(['x.is_a? y'])
      expect(corrected).to eq 'x.kind_of? y'
    end
  end
end
