# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::WhenThen, :config do
  it 'registers an offense for when b;' do
    expect_offense(<<~RUBY)
      case a
      when b; c
            ^ Do not use `when b;`. Use `when b then` instead.
      end
    RUBY

    expect_correction(<<~RUBY)
      case a
      when b then c
      end
    RUBY
  end

  it 'registers an offense for when b, c;' do
    expect_offense(<<~RUBY)
      case a
      when b, c; d
               ^ Do not use `when b, c;`. Use `when b, c then` instead.
      end
    RUBY

    expect_correction(<<~RUBY)
      case a
      when b, c then d
      end
    RUBY
  end

  it 'accepts ; separating statements in the body of when' do
    expect_no_offenses(<<~RUBY)
      case a
      when b then c; d
      end

      case e
      when f
        g; h
      end
    RUBY
  end

  # Regression: https://github.com/rubocop/rubocop/issues/3868
  context 'when inspecting a case statement with an empty branch' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        case value
        when cond1
        end
      RUBY
    end
  end
end
