# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EachForSimpleLoop do
  subject(:cop) { described_class.new }

  it 'does not register offense if range startpoint is not constant' do
    expect_no_offenses('(a..10).each {}')
  end

  it 'does not register offense if range endpoint is not constant' do
    expect_no_offenses('(0..b).each {}')
  end

  it 'does not register offense for inline block with parameters' do
    expect_no_offenses('(0..10).each { |n| puts n }')
  end

  it 'does not register offense for multiline block with parameters' do
    expect_no_offenses(<<~RUBY)
      (0..10).each do |n|
      end
    RUBY
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

    it 'does not register offense for range not starting with zero and ' \
       'using param' do
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

    it 'does not register offense for range not starting with zero and ' \
       'using param' do
      expect_no_offenses(<<~RUBY)
        (3...7).each do |n|
        end
      RUBY
    end
  end
end
