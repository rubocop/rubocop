# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NoRescueErrorMessageChecking, :config do
  include CopHelper

  it do
    expect_no_offenses(<<~RUBY)
      def foo
        business_logic
      rescue => e
        raise CustomError
      end

      def bar
        business_logic
      rescue StandardError => e
        raise CustomError
      rescue => e
        # handle_error
      end
    RUBY
  end

  it 'registers an offense when there is an if condition matching exception message' do
    expect_offense(<<~RUBY)
      begin
        business_logic
      rescue => e
        if e.message.match?(/pattern/)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid checking error message while handling exceptions. This is brittle and can break easily.
          # handle error
        end
      end
    RUBY
  end

  it 'registers an offense when there is an unless condition matching exception message' do
    expect_offense(<<~RUBY)
      begin
        business_logic
      rescue => e
        unless e.message.match?(/pattern/)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid checking error message while handling exceptions. This is brittle and can break easily.
          # handle error
        end
      end
    RUBY
  end

  it 'registers an offense when these is an if condition including exception message' do
    expect_offense(<<~RUBY)
      begin
        business_logic
      rescue => e
        if e.message.include?('pattern')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid checking error message while handling exceptions. This is brittle and can break easily.
          # handle error
        end
      end
    RUBY
  end

  it 'registers an offense when these is an unless condition including exception message' do
    expect_offense(<<~RUBY)
      begin
        business_logic
      rescue => e
        unless e.message.include?('pattern')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid checking error message while handling exceptions. This is brittle and can break easily.
          # handle error
        end
      end
    RUBY
  end

  it 'does not register an offense for other conditions' do
    expect_no_offenses(<<~RUBY)
      begin
        # some code
      rescue => e
        if e.class == StandardError
          # handle standard error
        end
      end
    RUBY
  end

  it 'does not register an offense if there is no message check' do
    expect_no_offenses(<<~RUBY)
      begin
        # some code
      rescue => e
        # handle error
      end
    RUBY
  end
end
