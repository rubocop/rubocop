# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantElse, :config do
  %w[redo next break].each do |skip|
    it "registers an offense on an else made redundant by a #{skip} in a loop" do
      expect_offense(<<~RUBY, skip: skip)
        foo.each do |bar|
          if condition
            frob
            #{skip}
          else
          ^^^^ This else branch is unreachable when the if branch executes.
            qux
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        foo.each do |bar|
          if condition
            frob
            #{skip}
          end

            qux
        end
      RUBY
    end
  end

  %w[return raise fail].each do |skip|
    it "registers an offense on an else made redundant by a #{skip}" do
      expect_offense(<<~RUBY, skip: skip)
        if condition
          frob
          #{skip}
        else
        ^^^^ This else branch is unreachable when the if branch executes.
          qux
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          frob
          #{skip}
        end

          qux
      RUBY
    end
  end

  it 'does not register an offense on a non-redundant else' do
    expect_no_offenses(<<~RUBY)
      if condition
        frob
      else
        qux
      end
    RUBY
  end

  it 'does not register an offense on a condition with an empty if branch' do
    expect_no_offenses(<<~RUBY)
      if condition
        # do nothing
      else
        qux
      end
    RUBY
  end

  it 'does not register an offense on an elsif' do
    expect_no_offenses(<<~RUBY)
      if condition
        foo
        return
      elsif bar
        qux
      end
    RUBY
  end

  it 'does not register an offense on an else where the return in the if is conditional' do
    expect_no_offenses(<<~RUBY)
      if condition
        return unless frob
      else
        qux
      end
    RUBY
  end
end
