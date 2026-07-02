# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantTap, :config do
  it 'registers an offense when using `#tap` with `&:freeze`' do
    expect_offense(<<~RUBY)
      obj.tap(&:freeze)
      ^^^^^^^^^^^^^^^^^ Use `#freeze` directly instead of `#tap`.
    RUBY

    expect_correction(<<~RUBY)
      obj.freeze
    RUBY
  end

  it 'registers an offense when using `#tap` with a block that calls a method returning self' do
    expect_offense(<<~RUBY)
      obj.tap { |x| x.freeze }
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `#freeze` directly instead of `#tap`.
    RUBY

    expect_correction(<<~RUBY)
      obj.freeze
    RUBY
  end

  it 'registers an offense when using `#tap` with a `numblock` that calls a method returning self' do
    expect_offense(<<~RUBY)
      obj.tap { _1.freeze }
      ^^^^^^^^^^^^^^^^^^^^^ Use `#freeze` directly instead of `#tap`.
    RUBY

    expect_correction(<<~RUBY)
      obj.freeze
    RUBY
  end

  it 'registers an offense when using `#tap` with a `itblock` that calls a method returning self', :ruby34 do
    expect_offense(<<~RUBY)
      obj.tap { it.freeze }
      ^^^^^^^^^^^^^^^^^^^^^ Use `#freeze` directly instead of `#tap`.
    RUBY

    expect_correction(<<~RUBY)
      obj.freeze
    RUBY
  end

  it 'registers an offense for a method chain receiver' do
    expect_offense(<<~RUBY)
      foo.bar.baz.tap(&:freeze)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#freeze` directly instead of `#tap`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar.baz.freeze
    RUBY
  end

  it 'registers an offense for a literal receiver' do
    expect_offense(<<~RUBY)
      'string'.tap { |s| s.freeze }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#freeze` directly instead of `#tap`.
    RUBY

    expect_correction(<<~RUBY)
      'string'.freeze
    RUBY
  end

  it 'registers an offense when using safe navigation' do
    expect_offense(<<~RUBY)
      obj&.tap(&:freeze)
      ^^^^^^^^^^^^^^^^^^ Use `#freeze` directly instead of `#tap`.
    RUBY

    expect_correction(<<~RUBY)
      obj&.freeze
    RUBY
  end

  context 'when MethodsReturningSelf is configured' do
    let(:cop_config) { { 'MethodsReturningSelf' => %w[sort! upcase!] } }

    it 'registers an offense for a configured method in symbol proc form' do
      expect_offense(<<~RUBY)
        ary.tap(&:sort!)
        ^^^^^^^^^^^^^^^^ Use `#sort!` directly instead of `#tap`.
      RUBY

      expect_correction(<<~RUBY)
        ary.sort!
      RUBY
    end

    it 'registers an offense for a configured method in block form' do
      expect_offense(<<~RUBY)
        str.tap { |s| s.upcase! }
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#upcase!` directly instead of `#tap`.
      RUBY

      expect_correction(<<~RUBY)
        str.upcase!
      RUBY
    end

    it 'does not register an offense for a method not in the list with symbol proc' do
      expect_no_offenses(<<~RUBY)
        obj.tap(&:freeze)
      RUBY
    end

    it 'does not register an offense for a method not in the list in block form' do
      expect_no_offenses(<<~RUBY)
        obj.tap { |x| x.freeze }
      RUBY
    end
  end

  context 'when MethodsReturningSelf includes a method with arguments' do
    let(:cop_config) { { 'MethodsReturningSelf' => %w[force_encoding] } }

    it 'registers an offense when the block passes arguments' do
      expect_offense(<<~RUBY)
        str.tap { |s| s.force_encoding('UTF-8') }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#force_encoding` directly instead of `#tap`.
      RUBY

      expect_correction(<<~RUBY)
        str.force_encoding('UTF-8')
      RUBY
    end

    it 'does not register an offense for a method not in the list' do
      expect_no_offenses(<<~RUBY)
        obj.tap(&:freeze)
      RUBY
    end
  end

  context 'when MethodsReturningSelf includes multiple methods' do
    let(:cop_config) { { 'MethodsReturningSelf' => %w[freeze force_encoding] } }

    it 'registers an offense for each configured method' do
      expect_offense(<<~RUBY)
        obj.tap(&:freeze)
        ^^^^^^^^^^^^^^^^^ Use `#freeze` directly instead of `#tap`.
        str.tap { |s| s.force_encoding('UTF-8') }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#force_encoding` directly instead of `#tap`.
      RUBY

      expect_correction(<<~RUBY)
        obj.freeze
        str.force_encoding('UTF-8')
      RUBY
    end
  end

  it 'does not register an offense when using the method directly' do
    expect_no_offenses(<<~RUBY)
      obj.freeze
    RUBY
  end

  it 'does not register an offense when `#tap` uses a method that does not return self' do
    expect_no_offenses(<<~RUBY)
      obj.tap(&:dup)
    RUBY
  end

  it 'does not register an offense when the block calls a method that does not return self' do
    expect_no_offenses(<<~RUBY)
      obj.tap { |x| x.dup }
    RUBY
  end

  it 'does not register an offense when the block calls the method on a different variable' do
    expect_no_offenses(<<~RUBY)
      obj.tap { |x| y.freeze }
    RUBY
  end

  it 'does not register an offense when the block has multiple statements' do
    expect_no_offenses(<<~RUBY)
      obj.tap do |x|
        x.foo
        x.freeze
      end
    RUBY
  end

  it 'does not register an offense when `#tap` has a block with side effects' do
    expect_no_offenses(<<~RUBY)
      obj.tap { |x| do_something(x) }
    RUBY
  end
end
