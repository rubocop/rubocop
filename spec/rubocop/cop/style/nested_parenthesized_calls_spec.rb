# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NestedParenthesizedCalls, :config do
  let(:config) do
    RuboCop::Config.new('Style/NestedParenthesizedCalls' => { 'AllowedMethods' => ['be'] })
  end

  context 'on a non-parenthesized method call' do
    it "doesn't register an offense" do
      expect_no_offenses('puts 1, 2')
    end
  end

  context 'on a method call with no arguments' do
    it "doesn't register an offense" do
      expect_no_offenses('puts')
    end
  end

  context 'on a nested, parenthesized method call' do
    it "doesn't register an offense" do
      expect_no_offenses('puts(compute(something))')
    end
  end

  context 'on a non-parenthesized call nested in a parenthesized one' do
    context 'with a single argument to the nested call' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          puts(compute something)
               ^^^^^^^^^^^^^^^^^ Add parentheses to nested method call `compute something`.
        RUBY

        expect_correction(<<~RUBY)
          puts(compute(something))
        RUBY
      end

      context 'when using safe navigation operator' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            puts(receiver&.compute something)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add parentheses to nested method call `receiver&.compute something`.
          RUBY

          expect_correction(<<~RUBY)
            puts(receiver&.compute(something))
          RUBY
        end
      end
    end

    context 'with multiple arguments to the nested call' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          puts(compute first, second)
               ^^^^^^^^^^^^^^^^^^^^^ Add parentheses to nested method call `compute first, second`.
        RUBY

        expect_correction(<<~RUBY)
          puts(compute(first, second))
        RUBY
      end
    end
  end

  context 'on a call with no arguments, nested in a parenthesized one' do
    it "doesn't register an offense" do
      expect_no_offenses('puts(compute)')
    end
  end

  context 'on an aref, nested in a parenthesized method call' do
    it "doesn't register an offense" do
      expect_no_offenses('method(obj[1])')
    end
  end

  context 'on a deeply nested argument' do
    it "doesn't register an offense" do
      expect_no_offenses('method(block_taker { another_method 1 })')
    end
  end

  context 'on a permitted method' do
    it "doesn't register an offense" do
      expect_no_offenses('expect(obj).to(be true)')
    end
  end

  context 'on a call to a setter method' do
    it "doesn't register an offense" do
      expect_no_offenses('expect(object1.attr = 1).to eq 1')
    end
  end

  context 'backslash newline in method call' do
    it 'registers an offense' do
      expect_offense(<<~'RUBY')
        puts(nex \
             ^^^^^ Add parentheses to nested method call [...]
               5)
      RUBY

      expect_correction(<<~RUBY)
        puts(nex(5))
      RUBY
    end
  end
end
