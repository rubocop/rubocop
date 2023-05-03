# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantFilterChain, :config do
  let(:config) do
    RuboCop::Config.new('AllCops' => { 'ActiveSupportExtensionsEnabled' => false })
  end

  %i[select filter find_all].each do |method|
    it "registers an offense when using `##{method}` followed by `#any?`" do
      expect_offense(<<~RUBY, method: method)
        arr.%{method} { |x| x > 1 }.any?
            ^{method}^^^^^^^^^^^^^^^^^^^ Use `any?` instead of `#{method}.any?`.
      RUBY

      expect_correction(<<~RUBY)
        arr.any? { |x| x > 1 }
      RUBY
    end

    it "registers an offense when using `##{method}` followed by `#empty?`" do
      expect_offense(<<~RUBY, method: method)
        arr.%{method} { |x| x > 1 }.empty?
            ^{method}^^^^^^^^^^^^^^^^^^^^^ Use `none?` instead of `#{method}.empty?`.
      RUBY

      expect_correction(<<~RUBY)
        arr.none? { |x| x > 1 }
      RUBY
    end

    it "registers an offense when using `##{method}` followed by `#none?`" do
      expect_offense(<<~RUBY, method: method)
        arr.%{method} { |x| x > 1 }.none?
            ^{method}^^^^^^^^^^^^^^^^^^^^ Use `none?` instead of `#{method}.none?`.
      RUBY

      expect_correction(<<~RUBY)
        arr.none? { |x| x > 1 }
      RUBY
    end

    it "registers an offense when using `##{method}` with block-pass followed by `#none?`" do
      expect_offense(<<~RUBY, method: method)
        arr.%{method}(&:odd?).none?
            ^{method}^^^^^^^^^^^^^^ Use `none?` instead of `#{method}.none?`.
      RUBY

      expect_correction(<<~RUBY)
        arr.none?(&:odd?)
      RUBY
    end

    it "does not register an offense when using `##{method}` followed by `#many?`" do
      expect_no_offenses(<<~RUBY)
        arr.#{method} { |x| x > 1 }.many?
      RUBY
    end

    it "does not register an offense when using `##{method}` without a block followed by `#any?`" do
      expect_no_offenses(<<~RUBY)
        relation.#{method}(:name).any?
        foo.#{method}.any?
      RUBY
    end

    it "does not register an offense when using `##{method}` followed by `#any?` with arguments" do
      expect_no_offenses(<<~RUBY)
        arr.#{method}(&:odd?).any?(Integer)
        arr.#{method}(&:odd?).any? { |x| x > 10 }
      RUBY
    end
  end

  it 'does not register an offense when using `#any?`' do
    expect_no_offenses(<<~RUBY)
      arr.any? { |x| x > 1 }
    RUBY
  end

  context 'when `AllCops/ActiveSupportExtensionsEnabled: true`' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'ActiveSupportExtensionsEnabled' => true })
    end

    it 'registers an offense when using `#select` followed by `#many?`' do
      expect_offense(<<~RUBY)
        arr.select { |x| x > 1 }.many?
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `many?` instead of `select.many?`.
      RUBY

      expect_correction(<<~RUBY)
        arr.many? { |x| x > 1 }
      RUBY
    end
  end
end
