# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::InfiniteLoop, :config do
  let(:config) { RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 }) }

  %w(1 2.0 [1] {}).each do |lit|
    it "registers an offense for a while loop with #{lit} as condition" do
      expect_offense(<<~RUBY)
        while #{lit}
        ^^^^^ Use `Kernel#loop` for infinite loops.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
          top
        end
      RUBY
    end
  end

  %w[false nil].each do |lit|
    it "registers an offense for a until loop with #{lit} as condition" do
      expect_offense(<<~RUBY)
        until #{lit}
        ^^^^^ Use `Kernel#loop` for infinite loops.
          top
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
          top
        end
      RUBY
    end
  end

  it 'accepts Kernel#loop' do
    expect_no_offenses('loop { break if something }')
  end

  it 'accepts while true if loop {} would change semantics' do
    expect_no_offenses(<<~RUBY)
      def f1
        a = nil # This `a` is local to `f1` and should not affect `f2`.
        puts a
      end

      def f2
        b = 17
        while true
          # `a` springs into existence here, while `b` already existed. Because
          # of `a` we can't introduce a block.
          a, b = 42, 42
          break
        end
        puts a, b
      end
    RUBY
  end

  it 'accepts modifier while true if loop {} would change semantics' do
    expect_no_offenses(<<~RUBY)
      a = next_value or break while true
      p a
    RUBY
  end

  it 'registers an offense for modifier until false if loop {} would not change semantics' do
    expect_offense(<<~RUBY)
      a = nil
      a = next_value or break until false
                              ^^^^^ Use `Kernel#loop` for infinite loops.
      p a
    RUBY

    expect_correction(<<~RUBY)
      a = nil
      loop { a = next_value or break }
      p a
    RUBY
  end

  it 'registers an offense for until false if loop {} would work because of ' \
     'previous assignment in a while loop' do
    expect_offense(<<~RUBY)
      while true
        a = 42
        break
      end
      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        # The variable `a` already exists here, having been introduced in the
        # above `while` loop. We can therefore safely change it too `Kernel#loop`.
        a = 43
        break
      end
      puts a
    RUBY

    expect_correction(<<~RUBY)
      while true
        a = 42
        break
      end
      loop do
        # The variable `a` already exists here, having been introduced in the
        # above `while` loop. We can therefore safely change it too `Kernel#loop`.
        a = 43
        break
      end
      puts a
    RUBY
  end

  it 'registers an offense for until false if loop {} would work because the ' \
     'assigned variable is not used afterwards' do
    expect_offense(<<~RUBY)
      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 43
        break
      end
    RUBY

    expect_correction(<<~RUBY)
      loop do
        a = 43
        break
      end
    RUBY
  end

  it 'registers an offense for while true or until false if loop {} would ' \
     'work because of an earlier assignment' do
    expect_offense(<<~RUBY)
      a = 0
      while true
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 42 # `a` is in scope outside of the `while`
        break
      end
      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 43 # `a` is in scope outside of the `until`
        break
      end
      puts a
    RUBY

    expect_correction(<<~RUBY)
      a = 0
      loop do
        a = 42 # `a` is in scope outside of the `while`
        break
      end
      loop do
        a = 43 # `a` is in scope outside of the `until`
        break
      end
      puts a
    RUBY
  end

  it 'registers an offense for while true if loop {} would work because it ' \
     'is an instance variable being assigned' do
    expect_offense(<<~RUBY)
      while true
      ^^^^^ Use `Kernel#loop` for infinite loops.
        @a = 42
        break
      end
      puts @a
    RUBY

    expect_correction(<<~RUBY)
      loop do
        @a = 42
        break
      end
      puts @a
    RUBY
  end

  shared_examples_for 'autocorrector' do |keyword, lit|
    it "autocorrects single line modifier #{keyword}" do
      expect_offense(<<~RUBY, keyword: keyword, lit: lit)
        something += 1 %{keyword} %{lit} # comment
                       ^{keyword} Use `Kernel#loop` for infinite loops.
      RUBY

      expect_correction(<<~RUBY)
        loop { something += 1 } # comment
      RUBY
    end

    context 'with non-default indentation width' do
      let(:config) { RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 4 }) }

      it "autocorrects multi-line modifier #{keyword} and indents correctly" do
        expect_offense(<<~RUBY, keyword: keyword, lit: lit)
          # comment
          something 1, # comment 1
              # comment 2
              2 %{keyword} %{lit}
                ^{keyword} Use `Kernel#loop` for infinite loops.
        RUBY

        expect_correction(<<~RUBY)
          # comment
          loop do
              something 1, # comment 1
                  # comment 2
                  2
          end
        RUBY
      end
    end

    it "autocorrects begin-end-#{keyword} with one statement" do
      expect_offense(<<~RUBY, keyword: keyword, lit: lit)
        begin # comment 1
          something += 1 # comment 2
        end %{keyword} %{lit} # comment 3
            ^{keyword} Use `Kernel#loop` for infinite loops.
      RUBY

      expect_correction(<<~RUBY)
        loop do # comment 1
          something += 1 # comment 2
        end # comment 3
      RUBY
    end

    it "autocorrects begin-end-#{keyword} with two statements" do
      expect_offense(<<~RUBY, keyword: keyword, lit: lit)
        begin
          something += 1
          something_else += 1
        end %{keyword} %{lit}
            ^{keyword} Use `Kernel#loop` for infinite loops.
      RUBY

      expect_correction(<<~RUBY)
        loop do
          something += 1
          something_else += 1
        end
      RUBY
    end

    it "autocorrects single line modifier #{keyword} with and" do
      expect_offense(<<~RUBY, keyword: keyword, lit: lit)
        something and something_else %{keyword} %{lit}
                                     ^{keyword} Use `Kernel#loop` for infinite loops.
      RUBY

      expect_correction(<<~RUBY)
        loop { something and something_else }
      RUBY
    end

    it "autocorrects the usage of #{keyword} with do" do
      expect_offense(<<~RUBY, keyword: keyword, lit: lit)
        %{keyword} %{lit} do
        ^{keyword} Use `Kernel#loop` for infinite loops.
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
        end
      RUBY
    end

    it "autocorrects the usage of #{keyword} without do" do
      expect_offense(<<~RUBY, keyword: keyword, lit: lit)
        %{keyword} %{lit}
        ^{keyword} Use `Kernel#loop` for infinite loops.
        end
      RUBY

      expect_correction(<<~RUBY)
        loop do
        end
      RUBY
    end
  end

  it_behaves_like 'autocorrector', 'while', 'true'
  it_behaves_like 'autocorrector', 'until', 'false'
end
