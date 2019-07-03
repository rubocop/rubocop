# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::PerceivedMethodLength, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Max' => 5 } }

  context 'when method is an instance method' do
    it 'register an  offense' do
      expect_offense(<<~RUBY)
        def m
        ^^^^^ Method has too many statements. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def m
          [
            1,
            2,
            3,
            4,
            5,
            6
          ]
        end
      RUBY
    end
  end

  context 'when method is defined with `define_method`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        define_method(:m) do
        ^^^^^^^^^^^^^^^^^^^^ Method has too many statements. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        define_method(:m) do
          {
            a: 1,
            b: 2,
            c: 3,
            d: 4,
            e: 5,
            f: 6
          }
        end
      RUBY
    end
  end

  context 'when method has a block inside' do
    it 'register an offense' do
      expect_offense(<<~RUBY)
        def m
        ^^^^^ Method has too many statements. [6/5]
          my_block do
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def m
          my_block do
            a = 1
            a = 2
            a = 3
            a = 4
          end
        end
      RUBY
    end
  end

  context 'when method is a one-liner method' do
    it 'register an offense' do
      expect_offense(<<~RUBY)
        def m
        ^^^^^ Method has too many statements. [6/5]
          a = 1; a = 2; a = 3; a = 4; a = 5; a = 6;
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def m
          a = 1; a = 2; a = 3; a = 4; a = 5
        end
      RUBY
    end
  end

  context 'when method has a if statement' do
    it 'register an offense' do
      expect_offense(<<~RUBY)
        def m
        ^^^^^ Method has too many statements. [6/5]
          if a
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
        end
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def m
          if a
            a = 1
            a = 2
            a = 3
            a = 4
          end
        end
      RUBY
    end
  end
end
