# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::TopLevelReturnWithArgument, :config do
  context "Files with only top-level return statement" do
    it 'Expect no offense from the top level return node' do
      expect_no_offenses(<<~RUBY)
        return
      RUBY
    end

    it 'Expect offense from the top level return node' do
      expect_offense(<<~RUBY)
        return 1, 2, 3 # Should raise a `top level return with argument detected` offense
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY
    end

    it 'Expect multiple offenses from the top level return node' do
      expect_offense(<<~RUBY)
        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY
    end
  end

  context "File contains multiple statements other than the top-level return statement" do
    it 'Expect no offense from the top level return node with block level return' do
      expect_no_offenses(<<~RUBY)
        foo

        [1, 2, 3, 4, 5].each { |n| return n }

        return # Should raise a `top level return with argument detected` offense

        bar
      RUBY
    end

    it 'Expect offense from the top level return node' do
      expect_offense(<<~RUBY)
        foo

        [1, 2, 3, 4, 5].each { |n| return n }

        return 1, 2, 3 # Should raise a `top level return with argument detected` offense
        ^^^^^^^^^^^^^^ Top level return with argument detected.

        bar
      RUBY
    end
  end

  context "Code segment with method-level return statements" do
    it 'Expect no offense from the method-level return statement' do
      expect_no_offenses(<<~RUBY)
        def method
          return "Hello World"
        end
      RUBY
    end

    it "Expect offense when method-level & top-level return co-exist" do
      expect_offense(<<~RUBY)
        def method
          return "Hello World"
        end

        return 1, 2, 3
        ^^^^^^^^^^^^^^ Top level return with argument detected.
      RUBY
    end
  end
end
