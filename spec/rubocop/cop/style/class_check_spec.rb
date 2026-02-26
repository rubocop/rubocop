# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassCheck, :config do
  context 'when enforced style is is_a?' do
    let(:cop_config) { { 'EnforcedStyle' => 'is_a?' } }

    it 'registers an offense for kind_of? and corrects to is_a?' do
      expect_offense(<<~RUBY)
        x.kind_of? y
          ^^^^^^^^ Prefer `Object#is_a?` over `Object#kind_of?`.
      RUBY

      expect_correction(<<~RUBY)
        x.is_a? y
      RUBY
    end
  end

  context 'when enforced style is kind_of?' do
    let(:cop_config) { { 'EnforcedStyle' => 'kind_of?' } }

    it 'registers an offense for is_a? and corrects to kind_of?' do
      expect_offense(<<~RUBY)
        x.is_a? y
          ^^^^^ Prefer `Object#kind_of?` over `Object#is_a?`.
      RUBY

      expect_correction(<<~RUBY)
        x.kind_of? y
      RUBY
    end
  end
end
