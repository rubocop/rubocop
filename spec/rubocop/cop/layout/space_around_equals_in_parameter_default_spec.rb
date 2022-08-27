# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAroundEqualsInParameterDefault, :config do
  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it 'registers an offense and corrects default value assignment without space' do
      expect_offense(<<~RUBY)
        def f(x, y=0, z= 1)
                  ^ Surrounding space missing in default value assignment.
                       ^^ Surrounding space missing in default value assignment.
        end
      RUBY

      expect_correction(<<~RUBY)
        def f(x, y = 0, z = 1)
        end
      RUBY
    end

    it 'registers an offense and corrects default value assignment where first is partially right ' \
       'without space' do
      expect_offense(<<~RUBY)
        def f(x, y= 0, z=1)
                  ^^ Surrounding space missing in default value assignment.
                        ^ Surrounding space missing in default value assignment.
        end
      RUBY

      expect_correction(<<~RUBY)
        def f(x, y = 0, z = 1)
        end
      RUBY
    end

    it 'registers an offense and corrects assigning empty string without space' do
      expect_offense(<<~RUBY)
        def f(x, y="")
                  ^ Surrounding space missing in default value assignment.
        end
      RUBY

      expect_correction(<<~RUBY)
        def f(x, y = "")
        end
      RUBY
    end

    it 'registers an offense and corrects assignment of empty list without space' do
      expect_offense(<<~RUBY)
        def f(x, y=[])
                  ^ Surrounding space missing in default value assignment.
        end
      RUBY

      expect_correction(<<~RUBY)
        def f(x, y = [])
        end
      RUBY
    end

    it 'accepts default value assignment with space' do
      expect_no_offenses(<<~RUBY)
        def f(x, y = 0, z = {})
        end
      RUBY
    end

    it 'accepts default value assignment with spaces and unary + operator' do
      expect_no_offenses(<<~RUBY)
        def f(x, y = +1, z = {})
        end
      RUBY
    end

    it 'registers an offense and corrects missing space for arguments with unary operators' do
      expect_offense(<<~RUBY)
        def f(x=-1, y= 0, z =+1)
                           ^^ Surrounding space missing in default value assignment.
                     ^^ Surrounding space missing in default value assignment.
               ^ Surrounding space missing in default value assignment.
        end
      RUBY

      expect_correction(<<~RUBY)
        def f(x = -1, y = 0, z = +1)
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense and corrects default value assignment with space' do
      expect_offense(<<~RUBY)
        def f(x, y = 0, z =1, w= 2)
                  ^^^ Surrounding space detected in default value assignment.
                         ^^ Surrounding space detected in default value assignment.
                               ^^ Surrounding space detected in default value assignment.
        end
      RUBY

      expect_correction(<<~RUBY)
        def f(x, y=0, z=1, w=2)
        end
      RUBY
    end

    it 'registers an offense and corrects assignment of empty string with space' do
      expect_offense(<<~RUBY)
        def f(x, y = "")
                  ^^^ Surrounding space detected in default value assignment.
        end
      RUBY

      expect_correction(<<~RUBY)
        def f(x, y="")
        end
      RUBY
    end

    it 'registers an offense and corrects assignment of empty list with space' do
      expect_offense(<<~RUBY)
        def f(x, y = [])
                  ^^^ Surrounding space detected in default value assignment.
        end
      RUBY

      expect_correction(<<~RUBY)
        def f(x, y=[])
        end
      RUBY
    end

    it 'accepts default value assignment without space' do
      expect_no_offenses(<<~RUBY)
        def f(x, y=0, z={})
        end
      RUBY
    end
  end
end
