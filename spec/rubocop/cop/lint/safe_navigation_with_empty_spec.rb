# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SafeNavigationWithEmpty, :config do
  context 'in a conditional' do
    it 'registers an offense and corrects on `&.empty?`' do
      expect_offense(<<~RUBY)
        return unless foo&.empty?
                      ^^^^^^^^^^^ Avoid calling `empty?` with the safe navigation operator in conditionals.
      RUBY

      expect_correction(<<~RUBY)
        return unless foo && foo.empty?
      RUBY
    end

    it 'does not register an offense on `.empty?`' do
      expect_no_offenses(<<~RUBY)
        return if foo.empty?
      RUBY
    end
  end

  context 'outside a conditional' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        bar = foo&.empty?
      RUBY
    end
  end
end
