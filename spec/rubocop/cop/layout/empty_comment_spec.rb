# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyComment, :config do
  let(:cop_config) { { 'AllowBorderComment' => true, 'AllowMarginComment' => true } }

  it 'registers an offense and corrects using single line empty comment' do
    expect_offense(<<~RUBY)
      #
      ^ Source code comment is empty.
    RUBY

    expect_correction('')
  end

  it 'registers an offense and corrects using multiline empty comments' do
    expect_offense(<<~RUBY)
      #
      ^ Source code comment is empty.
      #
      ^ Source code comment is empty.
    RUBY

    expect_correction('')
  end

  it 'registers an offense and corrects using an empty comment next to code' do
    expect_offense(<<~RUBY)
      def foo #
              ^ Source code comment is empty.
        something
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        something
      end
    RUBY
  end

  it 'does not register an offense when using comment text' do
    expect_no_offenses(<<~RUBY)
      # Description of `Foo` class.
      class Foo
        # Description of `hello` method.
        def hello
        end
      end
    RUBY
  end

  it 'does not register an offense when using comment text with leading and trailing blank lines' do
    expect_no_offenses(<<~RUBY)
      #
      # Description of `Foo` class.
      #
      class Foo
        #
        # Description of `hello` method.
        #
        def hello
        end
      end
    RUBY
  end

  context 'allow border comment (default)' do
    it 'does not register an offense when using border comment' do
      expect_no_offenses(<<~RUBY)
        #################################
      RUBY
    end
  end

  context 'disallow border comment' do
    let(:cop_config) { { 'AllowBorderComment' => false } }

    it 'registers an offense and corrects using single line empty comment' do
      expect_offense(<<~RUBY)
        #
        ^ Source code comment is empty.
      RUBY

      expect_correction('')
    end

    it 'registers an offense and corrects using border comment' do
      expect_offense(<<~RUBY)
        #################################
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Source code comment is empty.
      RUBY

      expect_correction('')
    end
  end

  context 'allow margin comment (default)' do
    it 'does not register an offense when using margin comment' do
      expect_no_offenses(<<~RUBY)
        #
        # Description of `hello` method.
        #
        def hello
        end
      RUBY
    end
  end

  context 'disallow margin comment' do
    let(:cop_config) { { 'AllowMarginComment' => false } }

    it 'registers an offense and corrects using margin comment' do
      expect_offense(<<~RUBY)
        #
        ^ Source code comment is empty.
        # Description of `hello` method.
        #
        ^ Source code comment is empty.
        def hello
        end
      RUBY

      expect_correction(<<~RUBY)
        # Description of `hello` method.
        def hello
        end
      RUBY
    end
  end

  it 'registers an offense and corrects an empty comment without space next to code' do
    expect_offense(<<~RUBY)
      def foo#
             ^ Source code comment is empty.
        something
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        something
      end
    RUBY
  end

  it 'register offenses and correct multiple empty comments next to code' do
    expect_offense(<<~RUBY)
      def foo #
              ^ Source code comment is empty.
        something #
                  ^ Source code comment is empty.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        something
      end
    RUBY
  end

  it 'register offenses and correct multiple aligned empty comments next to code' do
    expect_offense(<<~RUBY)
      def foo     #
                  ^ Source code comment is empty.
        something #
                  ^ Source code comment is empty.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        something
      end
    RUBY
  end
end
