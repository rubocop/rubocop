# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantException do
  subject(:cop) { described_class.new }

  shared_examples 'common behavior' do |keyword|
    it "reports an offense for a #{keyword} with RuntimeError" do
      expect_offense(<<~RUBY, keyword: keyword)
        %{keyword} RuntimeError, msg
        ^{keyword}^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError` argument can be removed.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} msg
      RUBY
    end

    it "reports an offense for a #{keyword} with RuntimeError and ()" do
      expect_offense(<<~RUBY, keyword: keyword)
        %{keyword}(RuntimeError, msg)
        ^{keyword}^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError` argument can be removed.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword}(msg)
      RUBY
    end

    it "reports an offense for a #{keyword} with RuntimeError.new" do
      expect_offense(<<~RUBY, keyword: keyword)
        %{keyword} RuntimeError.new msg
        ^{keyword}^^^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError.new` call can be replaced with just the message.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} msg
      RUBY
    end

    it "reports an offense for a #{keyword} with RuntimeError.new" do
      expect_offense(<<~RUBY, keyword: keyword)
        %{keyword} RuntimeError.new(msg)
        ^{keyword}^^^^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError.new` call can be replaced with just the message.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} msg
      RUBY
    end

    it "accepts a #{keyword} with RuntimeError if it does not have 2 args" do
      expect_no_offenses("#{keyword} RuntimeError, msg, caller")
    end

    it 'accepts rescue w/ non redundant error' do
      expect_no_offenses "#{keyword} OtherError, msg"
    end
  end

  include_examples 'common behavior', 'raise'
  include_examples 'common behavior', 'fail'
end
