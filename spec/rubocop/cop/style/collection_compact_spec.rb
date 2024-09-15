# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionCompact, :config, :ruby24 do
  it 'registers an offense and corrects when using `reject` on array to reject nils' do
    expect_offense(<<~RUBY)
      array.reject { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |e| e.nil? }`.
      array.reject! { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |e| e.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end

  it 'registers an offense and corrects when using safe navigation `reject` call on array to reject nils' do
    expect_offense(<<~RUBY)
      array&.reject { |e| e&.nil? }
             ^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |e| e&.nil? }`.
      array&.reject! { |e| e&.nil? }
             ^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |e| e&.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      array&.compact
      array&.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` with block pass arg on array to reject nils' do
    expect_offense(<<~RUBY)
      array.reject(&:nil?)
            ^^^^^^^^^^^^^^ Use `compact` instead of `reject(&:nil?)`.
      array.reject!(&:nil?)
            ^^^^^^^^^^^^^^^ Use `compact!` instead of `reject!(&:nil?)`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end

  it 'registers an offense and corrects when using safe navigation `reject` call with block pass arg on array to reject nils' do
    expect_offense(<<~RUBY)
      array&.reject(&:nil?)
             ^^^^^^^^^^^^^^ Use `compact` instead of `reject(&:nil?)`.
      array&.reject!(&:nil?)
             ^^^^^^^^^^^^^^^ Use `compact!` instead of `reject!(&:nil?)`.
    RUBY

    expect_correction(<<~RUBY)
      array&.compact
      array&.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` with block pass arg and no parentheses' do
    expect_offense(<<~RUBY)
      array.reject &:nil?
            ^^^^^^^^^^^^^ Use `compact` instead of `reject &:nil?`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
    RUBY
  end

  it 'registers an offense and corrects when using `reject` on hash to reject nils' do
    expect_offense(<<~RUBY)
      hash.reject { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |k, v| v.nil? }`.
      hash.reject! { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |k, v| v.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      hash.compact
      hash.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `select/select!` to reject nils' do
    expect_offense(<<~RUBY)
      array.select { |e| !e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `select { |e| !e.nil? }`.
      hash.select! { |k, v| !v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `select! { |k, v| !v.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      hash.compact!
    RUBY
  end

  it 'registers an offense and corrects when using safe navigation `select/select!` call to reject nils' do
    expect_offense(<<~RUBY)
      array&.select { |e| e&.nil?&.! }
             ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `select { |e| e&.nil?&.! }`.
      hash&.select! { |k, v| v&.nil?&.! }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `select! { |k, v| v&.nil?&.! }`.
    RUBY

    expect_correction(<<~RUBY)
      array&.compact
      hash&.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` and receiver is a variable' do
    expect_offense(<<~RUBY)
      def foo(params)
        params.reject { |_k, v| v.nil? }
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |_k, v| v.nil? }`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo(params)
        params.compact
      end
    RUBY
  end

  it 'registers an offense and corrects when using `grep_v(nil)`' do
    expect_offense(<<~RUBY)
      array.grep_v(nil)
            ^^^^^^^^^^^ Use `compact` instead of `grep_v(nil)`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
    RUBY
  end

  it 'registers an offense and corrects when using `grep_v(NilClass)`' do
    expect_offense(<<~RUBY)
      array.grep_v(NilClass)
            ^^^^^^^^^^^^^^^^ Use `compact` instead of `grep_v(NilClass)`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
    RUBY
  end

  it 'registers an offense and corrects when using `grep_v(::NilClass)`' do
    expect_offense(<<~RUBY)
      array.grep_v(::NilClass)
            ^^^^^^^^^^^^^^^^^^ Use `compact` instead of `grep_v(::NilClass)`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
    RUBY
  end

  it 'does not register an offense when using `grep_v(pattern)`' do
    expect_no_offenses(<<~RUBY)
      array.grep_v(pattern)
    RUBY
  end

  it 'does not register an offense when using `reject` to not to rejecting nils' do
    expect_no_offenses(<<~RUBY)
      array.reject { |e| e.odd? }
    RUBY
  end

  it 'does not register an offense when using `compact/compact!`' do
    expect_no_offenses(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end

  # NOTE: Unlike `reject` or `compact` which return a new collection object,
  # `delete_if` always returns its own object `self` making them incompatible.
  # Additionally, `compact!` returns `nil` if no changes are made.
  it 'does not register an offense when using `delete_if`' do
    expect_no_offenses(<<~RUBY)
      array.delete_if(&:nil?)
      array.delete_if { |e| e.nil? }
    RUBY
  end

  context 'when without receiver' do
    it 'does not register an offense when using `reject` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        reject { |e| e.nil? }
        reject! { |e| e.nil? }
      RUBY
    end

    it 'does not register an offense when using `select/select!` to reject nils' do
      expect_no_offenses(<<~RUBY)
        select { |e| !e.nil? }
        select! { |k, v| !v.nil? }
      RUBY
    end
  end

  context 'Ruby >= 3.1', :ruby31 do
    it 'registers an offense and corrects when using `to_enum.reject` on array to reject nils' do
      expect_offense(<<~RUBY)
        array.to_enum.reject { |e| e.nil? }
                      ^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |e| e.nil? }`.
        array.to_enum.reject! { |e| e.nil? }
                      ^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |e| e.nil? }`.
      RUBY

      expect_correction(<<~RUBY)
        array.to_enum.compact
        array.to_enum.compact!
      RUBY
    end

    it 'registers an offense and corrects when using `lazy.reject` on array to reject nils' do
      expect_offense(<<~RUBY)
        array.lazy.reject { |e| e.nil? }
                   ^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |e| e.nil? }`.
        array.lazy.reject! { |e| e.nil? }
                   ^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |e| e.nil? }`.
      RUBY

      expect_correction(<<~RUBY)
        array.lazy.compact
        array.lazy.compact!
      RUBY
    end
  end

  context 'Ruby <= 3.0', :ruby30, unsupported_on: :prism do
    it 'does not register an offense when using `to_enum.reject` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        array.to_enum.reject { |e| e.nil? }
        array.to_enum.reject! { |e| e.nil? }
      RUBY
    end

    it 'does not register an offense when using `lazy.reject` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        array.lazy.reject { |e| e.nil? }
        array.lazy.reject! { |e| e.nil? }
      RUBY
    end
  end

  context 'Ruby >= 2.6', :ruby26, unsupported_on: :prism do
    it 'registers an offense and corrects when using `filter/filter!` to reject nils' do
      expect_offense(<<~RUBY)
        array.filter { |e| !e.nil? }
              ^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `filter { |e| !e.nil? }`.
        hash.filter! { |k, v| !v.nil? }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `filter! { |k, v| !v.nil? }`.
      RUBY

      expect_correction(<<~RUBY)
        array.compact
        hash.compact!
      RUBY
    end

    it 'registers an offense and corrects when using safe navigation `filter/filter!` call to reject nils' do
      expect_offense(<<~RUBY)
        array&.filter { |e| e&.nil?&.! }
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `filter { |e| e&.nil?&.! }`.
        hash&.filter! { |k, v| v&.nil?&.! }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `filter! { |k, v| v&.nil?&.! }`.
      RUBY

      expect_correction(<<~RUBY)
        array&.compact
        hash&.compact!
      RUBY
    end

    it 'does not register an offense when using `filter/filter!` to reject nils without a receiver' do
      expect_no_offenses(<<~RUBY)
        filter { |e| !e.nil? }
        filter! { |k, v| !v.nil? }
      RUBY
    end
  end

  context 'Ruby <= 2.5', :ruby25, unsupported_on: :prism do
    it 'does not register an offense when using `filter/filter!`' do
      expect_no_offenses(<<~RUBY)
        array.filter { |e| !e.nil? }
        hash.filter! { |k, v| !v.nil? }
      RUBY
    end
  end

  context 'when Ruby <= 2.3', :ruby23, unsupported_on: :prism do
    it 'does not register an offense when using `reject` on hash to reject nils' do
      expect_no_offenses(<<~RUBY)
        hash.reject { |k, v| v.nil? }
        hash.reject! { |k, v| v.nil? }
      RUBY
    end
  end

  context "when `AllowedReceivers: ['params']`" do
    let(:cop_config) { { 'AllowedReceivers' => ['params'] } }

    it 'does not register an offense when receiver is `params` method' do
      expect_no_offenses(<<~RUBY)
        params.reject { |param| param.nil? }
      RUBY
    end

    it 'does not register an offense when method chained receiver is `params` method' do
      expect_no_offenses(<<~RUBY)
        params.merge(key: value).reject { |_k, v| v.nil? }
      RUBY
    end

    it 'registers an offense when receiver is not allowed name' do
      expect_offense(<<~RUBY)
        foo.reject { |param| param.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |param| param.nil? }`.
      RUBY
    end
  end
end
