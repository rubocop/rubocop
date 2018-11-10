# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::InfiniteLoop do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 })
  end

  %w(1 2.0 [1] {}).each do |lit|
    it "registers an offense for a while loop with #{lit} as condition" do
      expect_offense(<<-RUBY.strip_indent)
        while #{lit}
        ^^^^^ Use `Kernel#loop` for infinite loops.
          top
        end
      RUBY
    end
  end

  %w[false nil].each do |lit|
    it "registers an offense for a until loop with #{lit} as condition" do
      expect_offense(<<-RUBY.strip_indent)
        until #{lit}
        ^^^^^ Use `Kernel#loop` for infinite loops.
          top
        end
      RUBY
    end
  end

  it 'accepts Kernel#loop' do
    expect_no_offenses('loop { break if something }')
  end

  it 'accepts while true if loop {} would change semantics' do
    expect_no_offenses(<<-RUBY.strip_indent)
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
    expect_no_offenses(<<-RUBY.strip_indent)
      a = next_value or break while true
      p a
    RUBY
  end

  it 'registers an offense for modifier until false if loop {} would not ' \
     'change semantics' do
    expect_offense(<<-RUBY.strip_indent)
      a = nil
      a = next_value or break until false
                              ^^^^^ Use `Kernel#loop` for infinite loops.
      p a
    RUBY
  end

  it 'registers an offense for until false if loop {} would work because of ' \
     'previous assignment in a while loop' do
    expect_offense(<<-RUBY.strip_indent)
      while true
        a = 42
        break
      end
      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        # The variable `a` already exits here, having been introduced in the
        # above `while` loop. We can therefore safely change it too `Kernel#loop`.
        a = 43
        break
      end
      puts a
    RUBY
  end

  it 'registers an offense for until false if loop {} would work because the ' \
     'assigned variable is not used afterwards' do
    expect_offense(<<-RUBY.strip_indent)
      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 43
        break
      end
    RUBY
  end

  it 'registers an offense for while true or until false if loop {} would ' \
     'work because of an earlier assignment' do
    expect_offense(<<-RUBY.strip_indent)
      a = 0
      while true
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 42 # `a` is in scope outside of the `while`
        break
      end
      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 43 # `a` is in scope outside of the `while`
        break
      end
      puts a
    RUBY
  end

  it 'registers an offense for while true if loop {} would work because it ' \
     'is an instance variable being assigned' do
    expect_offense(<<-RUBY.strip_indent)
      while true
      ^^^^^ Use `Kernel#loop` for infinite loops.
        @a = 42
        break
      end
      puts @a
    RUBY
  end

  shared_examples_for 'auto-corrector' do |keyword, lit|
    it "auto-corrects single line modifier #{keyword}" do
      new_source =
        autocorrect_source("something += 1 #{keyword} #{lit} # comment")
      expect(new_source).to eq('loop { something += 1 } # comment')
    end

    context 'with non-default indentation width' do
      let(:config) do
        RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 4 })
      end

      it "auto-corrects multi-line modifier #{keyword} and indents correctly" do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          # comment
          something 1, # comment 1
              # comment 2
              2 #{keyword} #{lit}
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          # comment
          loop do
              something 1, # comment 1
                  # comment 2
                  2
          end
        RUBY
      end
    end

    it "auto-corrects begin-end-#{keyword} with one statement" do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        begin # comment 1
          something += 1 # comment 2
        end #{keyword} #{lit} # comment 3
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        loop do # comment 1
          something += 1 # comment 2
        end # comment 3
      RUBY
    end

    it "auto-corrects begin-end-#{keyword} with two statements" do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        begin
          something += 1
          something_else += 1
        end #{keyword} #{lit}
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        loop do
          something += 1
          something_else += 1
        end
      RUBY
    end

    it "auto-corrects single line modifier #{keyword} with and" do
      new_source =
        autocorrect_source("something and something_else #{keyword} #{lit}")
      expect(new_source).to eq('loop { something and something_else }')
    end

    it "auto-corrects the usage of #{keyword} with do" do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        #{keyword} #{lit} do
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        loop do
        end
      RUBY
    end

    it "auto-corrects the usage of #{keyword} without do" do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        #{keyword} #{lit}
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        loop do
        end
      RUBY
    end
  end

  it_behaves_like 'auto-corrector', 'while', 'true'
  it_behaves_like 'auto-corrector', 'until', 'false'
end
