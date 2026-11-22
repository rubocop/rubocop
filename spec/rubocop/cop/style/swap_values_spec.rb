# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SwapValues, :config do
  shared_examples 'verbosely swapping' do |type, x, y, correction|
    it "registers an offense and corrects when verbosely swapping #{type} variables" do
      expect_offense(<<~RUBY, x: x)
        tmp = %{x}
        ^^^^^^^{x} Replace this and assignments at lines 2 and 3 with `#{correction}`.
        #{x} = #{y}
        #{y} = tmp
      RUBY

      expect_correction(<<~RUBY)
        #{correction}
      RUBY
    end
  end

  it_behaves_like('verbosely swapping', 'local', 'x', 'y', 'x, y = y, x')
  it_behaves_like('verbosely swapping', 'global', '$x', '$y', '$x, $y = $y, $x')
  it_behaves_like('verbosely swapping', 'instance', '@x', '@y', '@x, @y = @y, @x')
  it_behaves_like('verbosely swapping', 'class', '@@x', '@@y', '@@x, @@y = @@y, @@x')
  it_behaves_like('verbosely swapping', 'constant', 'X', 'Y', 'X, Y = Y, X')
  it_behaves_like('verbosely swapping', 'constant with namespaces',
                  '::X', 'Foo::Y', '::X, Foo::Y = Foo::Y, ::X')
  it_behaves_like('verbosely swapping', 'mixed', '@x', '$y', '@x, $y = $y, @x')

  it 'preserves statements sharing a line with the swap' do
    expect_offense(<<~RUBY)
      prepare; tmp = x
               ^^^^^^^ Replace this and assignments at lines 2 and 3 with `x, y = y, x`.
      x = y
      y = tmp; publish
    RUBY

    expect_correction(<<~RUBY)
      prepare; x, y = y, x; publish
    RUBY
  end

  it 'preserves indentation and the comment after the last assignment' do
    expect_offense(<<~RUBY)
      if ready
        tmp = x
        ^^^^^^^ Replace this and assignments at lines 3 and 4 with `x, y = y, x`.
        x = y
        y = tmp # keep
      end
    RUBY

    expect_correction(<<~RUBY)
      if ready
        x, y = y, x # keep
      end
    RUBY
  end

  it 'does not remove a heredoc body between the assignments' do
    expect_offense(<<~RUBY)
      log(<<~TEXT); tmp = x
                    ^^^^^^^ Replace this and assignments at lines 4 and 5 with `x, y = y, x`.
        message
      TEXT
      x = y
      y = tmp
    RUBY

    expect_no_corrections
  end

  it 'does not discard comments between the assignments' do
    expect_offense(<<~RUBY)
      tmp = x # comment 1
      ^^^^^^^ Replace this and assignments at lines 3 and 4 with `x, y = y, x`.
      # comment 2
      x = y
      y = tmp # comment 3
    RUBY

    expect_no_corrections
  end

  it 'does not combine assignments passed as separate arguments' do
    expect_no_offenses('emit(tmp = x, x = y, y = tmp)')
  end

  it 'does not register an offense when idiomatically swapping variables' do
    expect_no_offenses(<<~RUBY)
      x, y = y, x
    RUBY
  end

  it 'does not register an offense when almost swapping variables' do
    expect_no_offenses(<<~RUBY)
      tmp = x
      x = y
      y = not_a_tmp
    RUBY
  end

  it 'does not register an offense when assigning receiver object at `def`' do
    expect_no_offenses(<<~RUBY)
      def (foo = Object.new).do_something
      end
    RUBY
  end
end
