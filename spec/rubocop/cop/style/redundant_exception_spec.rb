# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantException, :config do
  shared_examples 'common behavior' do |keyword, runtime_error|
    it "reports an offense for a #{keyword} with #{runtime_error}" do
      expect_offense(<<~RUBY, keyword: keyword, runtime_error: runtime_error)
        %{keyword} %{runtime_error}, msg
        ^{keyword}^^{runtime_error}^^^^^ Redundant `RuntimeError` argument can be removed.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} msg
      RUBY
    end

    it "reports an offense for a #{keyword} with #{runtime_error} and ()" do
      expect_offense(<<~RUBY, keyword: keyword, runtime_error: runtime_error)
        %{keyword}(%{runtime_error}, msg)
        ^{keyword}^^{runtime_error}^^^^^^ Redundant `RuntimeError` argument can be removed.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword}(msg)
      RUBY
    end

    it "reports an offense for a #{keyword} with #{runtime_error}.new" do
      expect_offense(<<~RUBY, keyword: keyword, runtime_error: runtime_error)
        %{keyword} %{runtime_error}.new msg
        ^{keyword}^^{runtime_error}^^^^^^^^ Redundant `RuntimeError.new` call can be replaced with just the message.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} msg
      RUBY
    end

    it "reports an offense for a #{keyword} with #{runtime_error}.new" do
      expect_offense(<<~RUBY, keyword: keyword, runtime_error: runtime_error)
        %{keyword} %{runtime_error}.new(msg)
        ^{keyword}^^{runtime_error}^^^^^^^^^ Redundant `RuntimeError.new` call can be replaced with just the message.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} msg
      RUBY
    end

    it "accepts a #{keyword} with #{runtime_error} if it does not have 2 args" do
      expect_no_offenses("#{keyword} #{runtime_error}, msg, caller")
    end

    it 'accepts rescue w/ non redundant error' do
      expect_no_offenses "#{keyword} OtherError, msg"
    end
  end

  include_examples 'common behavior', 'raise', 'RuntimeError'
  include_examples 'common behavior', 'raise', '::RuntimeError'
  include_examples 'common behavior', 'fail', 'RuntimeError'
  include_examples 'common behavior', 'fail', '::RuntimeError'
end
