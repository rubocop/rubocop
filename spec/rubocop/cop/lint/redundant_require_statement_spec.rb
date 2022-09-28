# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantRequireStatement, :config do
  context 'target ruby version < 2.2', :ruby21 do
    it "does not register an offense when using `require 'enumerator'`" do
      expect_no_offenses(<<~RUBY)
        require 'enumerator'
      RUBY
    end
  end

  context 'target ruby version >= 2.2', :ruby22 do
    it "registers an offense and corrects when using `require 'enumerator'`" do
      expect_offense(<<~RUBY)
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'uri'
      RUBY

      expect_correction(<<~RUBY)
        require 'uri'
      RUBY
    end
  end
end
