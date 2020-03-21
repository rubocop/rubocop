# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantRequireStatement, :config do
  subject(:cop) { described_class.new(config) }

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
