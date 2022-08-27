# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::For, :config do
  context 'when each is the enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'each' } }

    it 'registers an offense for for' do
      expect_offense(<<~RUBY)
        def func
          for n in [1, 2, 3] do
          ^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
            puts n
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          [1, 2, 3].each do |n|
            puts n
          end
        end
      RUBY
    end

    it 'registers an offense for opposite + correct style' do
      expect_offense(<<~RUBY)
        def func
          for n in [1, 2, 3] do
          ^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
            puts n
          end
          [1, 2, 3].each do |n|
            puts n
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          [1, 2, 3].each do |n|
            puts n
          end
          [1, 2, 3].each do |n|
            puts n
          end
        end
      RUBY
    end

    it 'registers multiple offenses' do
      expect_offense(<<~RUBY)
        for n in [1, 2, 3] do
        ^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
          puts n
        end
        [1, 2, 3].each do |n|
          puts n
        end
        for n in [1, 2, 3] do
        ^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
          puts n
        end
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].each do |n|
          puts n
        end
        [1, 2, 3].each do |n|
          puts n
        end
        [1, 2, 3].each do |n|
          puts n
        end
      RUBY
    end

    context 'autocorrect' do
      context 'with range' do
        let(:expected_each_with_range) do
          <<~RUBY
            def func
              (1...value).each do |n|
                puts n
              end
            end
          RUBY
        end

        it 'changes for to each' do
          expect_offense(<<~RUBY)
            def func
              for n in (1...value) do
              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
                puts n
              end
            end
          RUBY

          expect_correction(expected_each_with_range)
        end

        it 'changes for that does not have do or semicolon to each' do
          expect_offense(<<~RUBY)
            def func
              for n in (1...value)
              ^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
                puts n
              end
            end
          RUBY

          expect_correction(expected_each_with_range)
        end

        context 'without parentheses' do
          it 'changes for to each' do
            expect_offense(<<~RUBY)
              def func
                for n in 1...value do
                ^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
                  puts n
                end
              end
            RUBY

            expect_correction(expected_each_with_range)
          end

          it 'changes for that does not have do or semicolon to each' do
            expect_offense(<<~RUBY)
              def func
                for n in 1...value
                ^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
                  puts n
                end
              end
            RUBY

            expect_correction(expected_each_with_range)
          end
        end
      end

      it 'corrects a tuple of items' do
        expect_offense(<<~RUBY)
          def func
            for (a, b) in {a: 1, b: 2, c: 3} do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts a, b
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            {a: 1, b: 2, c: 3}.each do |(a, b)|
              puts a, b
            end
          end
        RUBY
      end

      it 'changes for that does not have do or semicolon to each' do
        expect_offense(<<~RUBY)
          def func
            for n in [1, 2, 3]
            ^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            [1, 2, 3].each do |n|
              puts n
            end
          end
        RUBY
      end

      it 'corrects an array with `+` operator' do
        expect_offense(<<~RUBY)
          def func
            a = [1, 2]
            b = [3, 4]
            c = [5]

            for n in a + b + c
            ^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            a = [1, 2]
            b = [3, 4]
            c = [5]

            (a + b + c).each do |n|
              puts n
            end
          end
        RUBY
      end

      it 'corrects an array with `-` operator' do
        expect_offense(<<~RUBY)
          def func
            a = [1, 2, 3, 4]
            b = [3]

            for n in a - b
            ^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            a = [1, 2, 3, 4]
            b = [3]

            (a - b).each do |n|
              puts n
            end
          end
        RUBY
      end

      it 'corrects an array with `*` operator' do
        expect_offense(<<~RUBY)
          def func
            for n in [1, 2, 3, 4] * 3
            ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            ([1, 2, 3, 4] * 3).each do |n|
              puts n
            end
          end
        RUBY
      end

      it 'corrects an array with `|` operator' do
        expect_offense(<<~RUBY)
          def func
            a = [1, 2, 3, 4]
            b = [4, 5]

            for n in a | b
            ^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            a = [1, 2, 3, 4]
            b = [4, 5]

            (a | b).each do |n|
              puts n
            end
          end
        RUBY
      end

      it 'corrects an array with `&` operator' do
        expect_offense(<<~RUBY)
          def func
            a = [1, 2, 3, 4]
            b = [4, 5]

            for n in a & b
            ^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            a = [1, 2, 3, 4]
            b = [4, 5]

            (a & b).each do |n|
              puts n
            end
          end
        RUBY
      end

      it 'corrects an array with `&&` operator' do
        expect_offense(<<~RUBY)
          def func
            a = []
            b = [1, 2, 3]

            for n in a && b
            ^^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            a = []
            b = [1, 2, 3]

            (a && b).each do |n|
              puts n
            end
          end
        RUBY
      end

      it 'corrects an array with `||` operator' do
        expect_offense(<<~RUBY)
          def func
            a = nil
            b = [1, 2, 3]

            for n in a || b
            ^^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            a = nil
            b = [1, 2, 3]

            (a || b).each do |n|
              puts n
            end
          end
        RUBY
      end

      it 'corrects to `each` without parenthesize collection if non-operator method called' do
        expect_offense(<<~RUBY)
          def func
            for n in [1, 2, nil].compact
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `each` over `for`.
              puts n
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            [1, 2, nil].compact.each do |n|
              puts n
            end
          end
        RUBY
      end
    end

    it 'accepts multiline each' do
      expect_no_offenses(<<~RUBY)
        def func
          [1, 2, 3].each do |n|
            puts n
          end
        end
      RUBY
    end

    it 'accepts :for' do
      expect_no_offenses('[:for, :ala, :bala]')
    end

    it 'accepts def for' do
      expect_no_offenses('def for; end')
    end
  end

  context 'when for is the enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'for' } }

    it 'accepts for' do
      expect_no_offenses(<<~RUBY)
        def func
          for n in [1, 2, 3] do
            puts n
          end
        end
      RUBY
    end

    it 'registers an offense for multiline each' do
      expect_offense(<<~RUBY)
        def func
          [1, 2, 3].each do |n|
          ^^^^^^^^^^^^^^^^^^^^^ Prefer `for` over `each`.
            puts n
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          for n in [1, 2, 3] do
            puts n
          end
        end
      RUBY
    end

    it 'registers an offense for each without an item and uses _ as the item' do
      expect_offense(<<~RUBY)
        def func
          [1, 2, 3].each do
          ^^^^^^^^^^^^^^^^^ Prefer `for` over `each`.
            something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          for _ in [1, 2, 3] do
            something
          end
        end
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it 'registers an offense for each without an item and uses _ as the item' do
        expect_offense(<<~RUBY)
          def func
            [1, 2, 3].each do
            ^^^^^^^^^^^^^^^^^ Prefer `for` over `each`.
              puts _1
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            for _ in [1, 2, 3] do
              puts _1
            end
          end
        RUBY
      end
    end

    it 'registers an offense for correct + opposite style' do
      expect_offense(<<~RUBY)
        def func
          for n in [1, 2, 3] do
            puts n
          end
          [1, 2, 3].each do |n|
          ^^^^^^^^^^^^^^^^^^^^^ Prefer `for` over `each`.
            puts n
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          for n in [1, 2, 3] do
            puts n
          end
          for n in [1, 2, 3] do
            puts n
          end
        end
      RUBY
    end

    it 'registers multiple offenses' do
      expect_offense(<<~RUBY)
        for n in [1, 2, 3] do
          puts n
        end
        [1, 2, 3].each do |n|
        ^^^^^^^^^^^^^^^^^^^^^ Prefer `for` over `each`.
          puts n
        end
        [1, 2, 3].each do |n|
        ^^^^^^^^^^^^^^^^^^^^^ Prefer `for` over `each`.
          puts n
        end
      RUBY

      expect_correction(<<~RUBY)
        for n in [1, 2, 3] do
          puts n
        end
        for n in [1, 2, 3] do
          puts n
        end
        for n in [1, 2, 3] do
          puts n
        end
      RUBY
    end

    it 'registers an offense for a tuple of items' do
      expect_offense(<<~RUBY)
        def func
          {a: 1, b: 2, c: 3}.each do |(a, b)|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `for` over `each`.
            puts a, b
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          for (a, b) in {a: 1, b: 2, c: 3} do
            puts a, b
          end
        end
      RUBY
    end

    it 'accepts single line each' do
      expect_no_offenses(<<~RUBY)
        def func
          [1, 2, 3].each { |n| puts n }
        end
      RUBY
    end

    context 'when using safe navigation operator', :ruby23 do
      it 'does not break' do
        expect_no_offenses(<<~RUBY)
          def func
            [1, 2, 3]&.each { |n| puts n }
          end
        RUBY
      end
    end
  end
end
