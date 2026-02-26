# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateRescueException, :config do
  it 'registers an offense when duplicate exception exists' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue FirstError
      rescue SecondError, FirstError
                          ^^^^^^^^^^ Duplicate `rescue` exception detected.
      end
    RUBY
  end

  it 'registers an offense when duplicate exception splat exists' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue *ERRORS
      rescue SecondError, *ERRORS
                          ^^^^^^^ Duplicate `rescue` exception detected.
      end
    RUBY
  end

  it 'registers an offense when multiple duplicate exceptions exist' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue FirstError
      rescue SecondError
      rescue FirstError
             ^^^^^^^^^^ Duplicate `rescue` exception detected.
      rescue SecondError
             ^^^^^^^^^^^ Duplicate `rescue` exception detected.
      end
    RUBY
  end

  it 'registers an offense when duplicate exception exists within rescues with `else` branch' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue FirstError
      rescue SecondError, FirstError
                          ^^^^^^^^^^ Duplicate `rescue` exception detected.
      else
      end
    RUBY
  end

  it 'registers an offense when duplicate exception exists within rescues with empty `rescue` branch' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue FirstError
      rescue SecondError, FirstError
                          ^^^^^^^^^^ Duplicate `rescue` exception detected.
      rescue
      end
    RUBY
  end

  it 'does not register an offense when there are no duplicate exceptions' do
    expect_no_offenses(<<~RUBY)
      begin
        something
      rescue FirstError
      rescue SecondError
      end
    RUBY
  end
end
