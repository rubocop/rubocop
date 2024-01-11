# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EachForSimpleLoop, :config do
  it 'does not register offense if range starting point is not constant' do
    expect_no_offenses('(a..10).each {}')
  end

  it 'does not register offense if range endpoint is not constant' do
    expect_no_offenses('(0..b).each {}')
  end

  context 'with inline block with no parameters' do
    it 'autocorrects an offense' do
      expect_offense(<<~RUBY)
        (0...10).each { do_something }
        ^^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
      RUBY

      expect_correction(<<~RUBY)
        10.times { do_something }
      RUBY
    end
  end

  context 'with inline block with parameters' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        (0...10).each { |n| do_something(n) }
      RUBY
    end
  end

  context 'with multiline block with no parameters' do
    it 'autocorrects an offense' do
      expect_offense(<<~RUBY)
        (0...10).each do
        ^^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
          do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        10.times do
          do_something
        end
      RUBY
    end
  end

  context 'with multiline block with parameters' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        (0...10).each do |n|
          do_something(n)
        end
      RUBY
    end
  end

  context 'when using safe navigation operator' do
    context 'with inline block with no parameters' do
      it 'autocorrects an offense' do
        expect_offense(<<~RUBY)
          (0...10)&.each { do_something }
          ^^^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
        RUBY

        expect_correction(<<~RUBY)
          10.times { do_something }
        RUBY
      end
    end

    context 'with inline block with parameters' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          (0...10)&.each { |n| do_something(n) }
        RUBY
      end
    end

    context 'with multiline block with no parameters' do
      it 'autocorrects an offense' do
        expect_offense(<<~RUBY)
          (0...10)&.each do
          ^^^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
            do_something
          end
        RUBY

        expect_correction(<<~RUBY)
          10.times do
            do_something
          end
        RUBY
      end
    end

    context 'with multiline block with parameters' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          (0...10)&.each do |n|
            do_something(n)
          end
        RUBY
      end
    end
  end

  it 'does not register offense for character range' do
    expect_no_offenses("('a'..'b').each {}")
  end

  context 'when using an inclusive end range' do
    it 'autocorrects the source with inline block' do
      expect_offense(<<~RUBY)
        (0..10).each {}
        ^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
      RUBY

      expect_correction(<<~RUBY)
        11.times {}
      RUBY
    end

    it 'autocorrects the source with multiline block' do
      expect_offense(<<~RUBY)
        (0..10).each do
        ^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
        end
      RUBY

      expect_correction(<<~RUBY)
        11.times do
        end
      RUBY
    end

    it 'autocorrects the range not starting with zero' do
      expect_offense(<<~RUBY)
        (3..7).each do
        ^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
        end
      RUBY

      expect_correction(<<~RUBY)
        5.times do
        end
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'autocorrects the range not starting with zero' do
        expect_offense(<<~RUBY)
          (3..7)&.each do
          ^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
          end
        RUBY

        expect_correction(<<~RUBY)
          5.times do
          end
        RUBY
      end
    end

    it 'does not register offense for range not starting with zero and using param' do
      expect_no_offenses(<<~RUBY)
        (3..7).each do |n|
        end
      RUBY
    end
  end

  context 'when using an exclusive end range' do
    it 'autocorrects the source with inline block' do
      expect_offense(<<~RUBY)
        (0...10).each {}
        ^^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
      RUBY

      expect_correction(<<~RUBY)
        10.times {}
      RUBY
    end

    it 'autocorrects the source with multiline block' do
      expect_offense(<<~RUBY)
        (0...10).each do
        ^^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
        end
      RUBY

      expect_correction(<<~RUBY)
        10.times do
        end
      RUBY
    end

    it 'autocorrects the range not starting with zero' do
      expect_offense(<<~RUBY)
        (3...7).each do
        ^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
        end
      RUBY

      expect_correction(<<~RUBY)
        4.times do
        end
      RUBY
    end

    it 'does not register offense for range not starting with zero and using param' do
      expect_no_offenses(<<~RUBY)
        (3...7).each do |n|
        end
      RUBY
    end
  end
end
