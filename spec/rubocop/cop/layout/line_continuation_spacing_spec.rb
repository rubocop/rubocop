# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::LineContinuationSpacing, :config do
  context 'EnforcedStyle: space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it 'registers an offense when no space in front of backslash' do
      expect_offense(<<~'RUBY')
        if 2 + 2\
                ^ Use one space in front of backslash.
          == 4
          foo
        end
      RUBY

      expect_correction(<<~'RUBY')
        if 2 + 2 \
          == 4
          foo
        end
      RUBY
    end

    it 'registers an offense when too much space in front of backslash' do
      expect_offense(<<~'RUBY')
        if 2 + 2  \
                ^^^ Use one space in front of backslash.
          == 4
          foo
        end
      RUBY

      expect_correction(<<~'RUBY')
        if 2 + 2 \
          == 4
          foo
        end
      RUBY
    end

    it 'marks the offense correctly when offense is not in first line' do
      expect_offense(<<~'RUBY')
        foo
        bar
        baz
        if 2 + 2    \
                ^^^^^ Use one space in front of backslash.
          == 4
          foo
        end
      RUBY

      expect_correction(<<~'RUBY')
        foo
        bar
        baz
        if 2 + 2 \
          == 4
          foo
        end
      RUBY
    end

    it 'registers an offense when too much space in front of backslash in array literals' do
      expect_offense(<<~'RUBY')
        [
          :foo  \
              ^^^ Use one space in front of backslash.
        ]
      RUBY

      expect_correction(<<~'RUBY')
        [
          :foo \
        ]
      RUBY
    end

    it 'registers no offense with one space in front of backslash' do
      expect_no_offenses(<<~'RUBY')
        if 2 + 2 \
          == 4
          foo
        end
      RUBY
    end

    it 'ignores heredocs and comments' do
      expect_no_offenses(<<~'RUBY')
        # this\
        <<-X
          is\
          ok
        X
      RUBY
    end

    it 'ignores percent literals' do
      expect_no_offenses(<<~'RUBY')
        %i[
          foo  \
        ]
      RUBY
    end

    it 'ignores when too much space in front of backslash after `__END__`' do
      expect_no_offenses(<<~'RUBY')
        foo
        bar
        __END__
        baz    \
        qux
      RUBY
    end

    it 'ignores empty code' do
      expect_no_offenses('')
    end
  end

  context 'EnforcedStyle: no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense when one space in front of backslash' do
      expect_offense(<<~'RUBY')
        if 2 + 2 \
                ^^ Use zero spaces in front of backslash.
          == 4
          foo
        end
      RUBY

      expect_correction(<<~'RUBY')
        if 2 + 2\
          == 4
          foo
        end
      RUBY
    end

    it 'registers an offense when many spaces in front of backslash' do
      expect_offense(<<~'RUBY')
        if 2 + 2  \
                ^^^ Use zero spaces in front of backslash.
          == 4
          foo
        end
      RUBY

      expect_correction(<<~'RUBY')
        if 2 + 2\
          == 4
          foo
        end
      RUBY
    end

    it 'marks the offense correctly when offense is not in first line' do
      expect_offense(<<~'RUBY')
        foo
        bar
        baz
        if 2 + 2    \
                ^^^^^ Use zero spaces in front of backslash.
          == 4
          foo
        end
      RUBY

      expect_correction(<<~'RUBY')
        foo
        bar
        baz
        if 2 + 2\
          == 4
          foo
        end
      RUBY
    end

    it 'registers no offense with zero spaces in front of backslash' do
      expect_no_offenses(<<~'RUBY')
        if 2 + 2\
          == 4
          foo
        end
      RUBY
    end

    it 'registers an offense when too much space in front of backslash in array literals' do
      expect_offense(<<~'RUBY')
        [
          :foo  \
              ^^^ Use zero spaces in front of backslash.
        ]
      RUBY

      expect_correction(<<~'RUBY')
        [
          :foo\
        ]
      RUBY
    end

    it 'ignores heredocs and comments' do
      expect_no_offenses(<<~'RUBY')
        # this \
        <<-X
          is  \
          ok
        X
      RUBY
    end

    it 'ignores percent literals' do
      expect_no_offenses(<<~'RUBY')
        %i[
          foo  \
        ]
      RUBY
    end

    it 'ignores when too much space in front of backslash after `__END__`' do
      expect_no_offenses(<<~'RUBY')
        foo
        bar
        __END__
        baz    \
        qux
      RUBY
    end

    it 'ignores empty code' do
      expect_no_offenses('')
    end
  end
end
