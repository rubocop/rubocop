# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantException, :config do
  shared_examples 'common behavior' do |keyword, runtime_error|
    it "reports an offense for a #{keyword} with #{runtime_error}" do
      expect_offense(<<~RUBY, keyword: keyword, runtime_error: runtime_error)
        %{keyword} %{runtime_error}, "message"
        ^{keyword}^^{runtime_error}^^^^^^^^^^^ Redundant `RuntimeError` argument can be removed.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} "message"
      RUBY
    end

    it "reports an offense for a #{keyword} with #{runtime_error} and ()" do
      expect_offense(<<~RUBY, keyword: keyword, runtime_error: runtime_error)
        %{keyword}(%{runtime_error}, "message")
        ^{keyword}^^{runtime_error}^^^^^^^^^^^^ Redundant `RuntimeError` argument can be removed.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword}("message")
      RUBY
    end

    it "reports an offense for a #{keyword} with #{runtime_error}.new" do
      expect_offense(<<~RUBY, keyword: keyword, runtime_error: runtime_error)
        %{keyword} %{runtime_error}.new "message"
        ^{keyword}^^{runtime_error}^^^^^^^^^^^^^^ Redundant `RuntimeError.new` call can be replaced with just the message.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} "message"
      RUBY
    end

    it "reports an offense for a #{keyword} with #{runtime_error}.new" do
      expect_offense(<<~RUBY, keyword: keyword, runtime_error: runtime_error)
        %{keyword} %{runtime_error}.new("message")
        ^{keyword}^^{runtime_error}^^^^^^^^^^^^^^^ Redundant `RuntimeError.new` call can be replaced with just the message.
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} "message"
      RUBY
    end

    it "accepts a #{keyword} with #{runtime_error} if it does not have 2 args" do
      expect_no_offenses("#{keyword} #{runtime_error}, 'message', caller")
    end

    it 'accepts rescue w/ non redundant error' do
      expect_no_offenses "#{keyword} OtherError, 'message'"
    end
  end

  include_examples 'common behavior', 'raise', 'RuntimeError'
  include_examples 'common behavior', 'raise', '::RuntimeError'
  include_examples 'common behavior', 'fail', 'RuntimeError'
  include_examples 'common behavior', 'fail', '::RuntimeError'

  it 'registers an offense for raise with RuntimeError, "#{message}"' do
    expect_offense(<<~'RUBY')
      raise RuntimeError, "#{message}"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError` argument can be removed.
    RUBY

    expect_correction(<<~'RUBY')
      raise "#{message}"
    RUBY
  end

  it 'registers an offense for raise with RuntimeError, `command`' do
    expect_offense(<<~RUBY)
      raise RuntimeError, `command`
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError` argument can be removed.
    RUBY

    expect_correction(<<~RUBY)
      raise `command`
    RUBY
  end

  it 'registers an offense for raise with RuntimeError, Object.new' do
    expect_offense(<<~RUBY)
      raise RuntimeError, Object.new
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError` argument can be removed.
    RUBY

    expect_correction(<<~RUBY)
      raise Object.new.to_s
    RUBY
  end

  it 'registers an offense for raise with RuntimeError.new, Object.new and parans' do
    expect_offense(<<~RUBY)
      raise RuntimeError.new(Object.new)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError.new` call can be replaced with just the message.
    RUBY

    expect_correction(<<~RUBY)
      raise Object.new.to_s
    RUBY
  end

  it 'registers an offense for raise with RuntimeError.new, Object.new no parens' do
    expect_offense(<<~RUBY)
      raise RuntimeError.new Object.new
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError.new` call can be replaced with just the message.
    RUBY

    expect_correction(<<~RUBY)
      raise Object.new.to_s
    RUBY
  end

  it 'registers an offense for raise with RuntimeError, variable' do
    expect_offense(<<~RUBY)
      raise RuntimeError, variable
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `RuntimeError` argument can be removed.
    RUBY

    expect_correction(<<~RUBY)
      raise variable.to_s
    RUBY
  end
end
