# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NestedParenthesizedCalls do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Style/NestedParenthesizedCalls' => { 'Whitelist' => ['be'] }
    )
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
      let(:source) { 'puts(compute something)' }

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          puts(compute something)
               ^^^^^^^^^^^^^^^^^ Add parentheses to nested method call `compute something`.
        RUBY
      end

      it 'auto-corrects by adding parentheses' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq('puts(compute(something))')
      end
    end

    context 'with multiple arguments to the nested call' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          puts(compute first, second)
               ^^^^^^^^^^^^^^^^^^^^^ Add parentheses to nested method call `compute first, second`.
        RUBY
      end

      it 'auto-corrects by adding parentheses' do
        new_source = autocorrect_source('puts(compute first, second)')
        expect(new_source).to eq('puts(compute(first, second))')
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

  context 'on a whitelisted method' do
    it "doesn't register an offense" do
      expect_no_offenses('expect(obj).to(be true)')
    end
  end

  context 'on a call to a setter method' do
    it "doesn't register an offense" do
      expect_no_offenses('expect(object1.attr = 1).to eq 1')
    end
  end
end
