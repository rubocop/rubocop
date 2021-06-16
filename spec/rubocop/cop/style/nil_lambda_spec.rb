# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NilLambda, :config do
  context 'block lambda' do
    it 'registers an offense when returning nil implicitly' do
      expect_offense(<<~RUBY)
        lambda do
        ^^^^^^^^^ Use an empty lambda instead of always returning nil.
          nil
        end
      RUBY

      expect_correction(<<~RUBY)
        lambda do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `return`' do
      expect_offense(<<~RUBY)
        lambda do
        ^^^^^^^^^ Use an empty lambda instead of always returning nil.
          return nil
        end
      RUBY

      expect_correction(<<~RUBY)
        lambda do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `break`' do
      expect_offense(<<~RUBY)
        lambda do
        ^^^^^^^^^ Use an empty lambda instead of always returning nil.
          break nil
        end
      RUBY

      expect_correction(<<~RUBY)
        lambda do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `next`' do
      expect_offense(<<~RUBY)
        lambda do
        ^^^^^^^^^ Use an empty lambda instead of always returning nil.
          next nil
        end
      RUBY

      expect_correction(<<~RUBY)
        lambda do
        end
      RUBY
    end

    it 'does not register an offense when not returning nil' do
      expect_no_offenses(<<~RUBY)
        lambda do
          6
        end
      RUBY
    end

    it 'does not register an offense when doing more than returning nil' do
      expect_no_offenses(<<~RUBY)
        lambda do |x|
          x ? x.method : nil
        end
      RUBY
    end

    it 'does not remove block params or change spacing' do
      expect_offense(<<~RUBY)
        fn = lambda do |x|
             ^^^^^^^^^^^^^ Use an empty lambda instead of always returning nil.
               nil
             end
      RUBY

      expect_correction(<<~RUBY)
        fn = lambda do |x|
             end
      RUBY
    end

    it 'properly corrects single line' do
      expect_offense(<<~RUBY)
        lambda { nil }
        ^^^^^^^^^^^^^^ Use an empty lambda instead of always returning nil.
      RUBY

      expect_correction(<<~RUBY)
        lambda {}
      RUBY
    end
  end

  context 'stabby lambda' do
    it 'registers an offense when returning nil implicitly' do
      expect_offense(<<~RUBY)
        -> { nil }
        ^^^^^^^^^^ Use an empty lambda instead of always returning nil.
      RUBY

      expect_correction(<<~RUBY)
        -> {}
      RUBY
    end

    it 'registers an offense when returning nil with `return`' do
      expect_offense(<<~RUBY)
        -> { return nil }
        ^^^^^^^^^^^^^^^^^ Use an empty lambda instead of always returning nil.
      RUBY

      expect_correction(<<~RUBY)
        -> {}
      RUBY
    end

    it 'registers an offense when returning nil with `break`' do
      expect_offense(<<~RUBY)
        -> { break nil }
        ^^^^^^^^^^^^^^^^ Use an empty lambda instead of always returning nil.
      RUBY

      expect_correction(<<~RUBY)
        -> {}
      RUBY
    end

    it 'registers an offense when returning nil with `next`' do
      expect_offense(<<~RUBY)
        -> { next nil }
        ^^^^^^^^^^^^^^^ Use an empty lambda instead of always returning nil.
      RUBY

      expect_correction(<<~RUBY)
        -> {}
      RUBY
    end

    it 'does not register an offense when not returning nil' do
      expect_no_offenses(<<~RUBY)
        -> { 6 }
      RUBY
    end

    it 'does not register an offense when doing more than returning nil' do
      expect_no_offenses(<<~RUBY)
        ->(x) { x ? x.method : nil }
      RUBY
    end

    it 'properly corrects multiline' do
      expect_offense(<<~RUBY)
        -> do
        ^^^^^ Use an empty lambda instead of always returning nil.
          nil
        end
      RUBY

      expect_correction(<<~RUBY)
        -> do
        end
      RUBY
    end
  end

  context 'proc' do
    it 'registers an offense when returning nil implicitly' do
      expect_offense(<<~RUBY)
        proc do
        ^^^^^^^ Use an empty proc instead of always returning nil.
          nil
        end
      RUBY

      expect_correction(<<~RUBY)
        proc do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `return`' do
      expect_offense(<<~RUBY)
        proc do
        ^^^^^^^ Use an empty proc instead of always returning nil.
          return nil
        end
      RUBY

      expect_correction(<<~RUBY)
        proc do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `break`' do
      expect_offense(<<~RUBY)
        proc do
        ^^^^^^^ Use an empty proc instead of always returning nil.
          break nil
        end
      RUBY

      expect_correction(<<~RUBY)
        proc do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `next`' do
      expect_offense(<<~RUBY)
        proc do
        ^^^^^^^ Use an empty proc instead of always returning nil.
          next nil
        end
      RUBY

      expect_correction(<<~RUBY)
        proc do
        end
      RUBY
    end

    it 'does not register an offense when not returning nil' do
      expect_no_offenses(<<~RUBY)
        proc do
          6
        end
      RUBY
    end

    it 'does not register an offense when doing more than returning nil' do
      expect_no_offenses(<<~RUBY)
        proc do |x|
          x ? x.method : nil
        end
      RUBY
    end

    it 'does not remove block params or change spacing' do
      expect_offense(<<~RUBY)
        fn = proc do |x|
             ^^^^^^^^^^^ Use an empty proc instead of always returning nil.
               nil
             end
      RUBY

      expect_correction(<<~RUBY)
        fn = proc do |x|
             end
      RUBY
    end

    it 'properly corrects single line' do
      expect_offense(<<~RUBY)
        proc { nil }
        ^^^^^^^^^^^^ Use an empty proc instead of always returning nil.
      RUBY

      expect_correction(<<~RUBY)
        proc {}
      RUBY
    end
  end

  context 'Proc.new' do
    it 'registers an offense when returning nil implicitly' do
      expect_offense(<<~RUBY)
        Proc.new do
        ^^^^^^^^^^^ Use an empty proc instead of always returning nil.
          nil
        end
      RUBY

      expect_correction(<<~RUBY)
        Proc.new do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `return`' do
      expect_offense(<<~RUBY)
        Proc.new do
        ^^^^^^^^^^^ Use an empty proc instead of always returning nil.
          return nil
        end
      RUBY

      expect_correction(<<~RUBY)
        Proc.new do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `break`' do
      expect_offense(<<~RUBY)
        Proc.new do
        ^^^^^^^^^^^ Use an empty proc instead of always returning nil.
          break nil
        end
      RUBY

      expect_correction(<<~RUBY)
        Proc.new do
        end
      RUBY
    end

    it 'registers an offense when returning nil with `next`' do
      expect_offense(<<~RUBY)
        Proc.new do
        ^^^^^^^^^^^ Use an empty proc instead of always returning nil.
          next nil
        end
      RUBY

      expect_correction(<<~RUBY)
        Proc.new do
        end
      RUBY
    end

    it 'does not register an offense when not returning nil' do
      expect_no_offenses(<<~RUBY)
        Proc.new do
          6
        end
      RUBY
    end

    it 'does not register an offense when doing more than returning nil' do
      expect_no_offenses(<<~RUBY)
        Proc.new do |x|
          x ? x.method : nil
        end
      RUBY
    end

    it 'does not remove block params or change spacing' do
      expect_offense(<<~RUBY)
        fn = Proc.new do |x|
             ^^^^^^^^^^^^^^^ Use an empty proc instead of always returning nil.
               nil
             end
      RUBY

      expect_correction(<<~RUBY)
        fn = Proc.new do |x|
             end
      RUBY
    end

    it 'properly corrects single line' do
      expect_offense(<<~RUBY)
        Proc.new { nil }
        ^^^^^^^^^^^^^^^^ Use an empty proc instead of always returning nil.
      RUBY

      expect_correction(<<~RUBY)
        Proc.new {}
      RUBY
    end
  end
end
