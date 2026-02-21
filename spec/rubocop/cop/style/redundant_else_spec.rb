# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantElse, :config do
  %w[return next break].each do |skip|
    it "registers an offense on an else made redundant by a #{skip}" do
      expect_offense(<<~RUBY, skip: skip)
        foo.each do |bar|
          if condition
            frob
            #{skip}
          else
          ^^^^ This condition is redundant because the if statement skips the rest of the loop.
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

  it 'does not register an offense on a non-redundant else' do
    expect_no_offenses(<<~RUBY)
      foo.each do |bar|
        if condition
          frob
        else
          qux
        end
      end
    RUBY
  end

  it 'does not register an offense on an else where the next in the if is conditional' do
    expect_no_offenses(<<~RUBY)
      foo.each do |bar|
        if condition
          next unless frob
        else
          qux
        end
      end
    RUBY
  end
end
