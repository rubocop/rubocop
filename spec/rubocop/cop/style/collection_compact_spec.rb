# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionCompact, :config, :ruby24 do
  it 'registers an offense and corrects when using `reject` on array to reject nils' do
    expect_offense(<<~RUBY)
      array.reject { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |e| e.nil? }`.
      array.delete_if { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `delete_if { |e| e.nil? }`.
      array.reject! { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |e| e.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      array.compact
      array.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` with block pass arg on array to reject nils' do
    expect_offense(<<~RUBY)
      array.reject(&:nil?)
            ^^^^^^^^^^^^^^ Use `compact` instead of `reject(&:nil?)`.
      array.delete_if(&:nil?)
            ^^^^^^^^^^^^^^^^^ Use `compact` instead of `delete_if(&:nil?)`.
      array.reject!(&:nil?)
            ^^^^^^^^^^^^^^^ Use `compact!` instead of `reject!(&:nil?)`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      array.compact
      array.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` with block pass arg and no parentheses' do
    expect_offense(<<~RUBY)
      array.reject &:nil?
            ^^^^^^^^^^^^^ Use `compact` instead of `reject &:nil?`.
      array.delete_if &:nil?
            ^^^^^^^^^^^^^^^^ Use `compact` instead of `delete_if &:nil?`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      array.compact
    RUBY
  end

  it 'registers an offense and corrects when using `reject` on hash to reject nils' do
    expect_offense(<<~RUBY)
      hash.reject { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |k, v| v.nil? }`.
      hash.delete_if { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `delete_if { |k, v| v.nil? }`.
      hash.reject! { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |k, v| v.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      hash.compact
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

  it 'registers an offense and corrects when using `reject` and receiver is a variable' do
    expect_offense(<<~RUBY)
      def foo(params)
        params.reject { |_k, v| v.nil? }
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |_k, v| v.nil? }`.
        params.delete_if { |_k, v| v.nil? }
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `delete_if { |_k, v| v.nil? }`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo(params)
        params.compact
        params.compact
      end
    RUBY
  end

  it 'does not register an offense when using `reject` to not to rejecting nils' do
    expect_no_offenses(<<~RUBY)
      array.reject { |e| e.odd? }
      array.delete_if { |e| e.odd? }
    RUBY
  end

  it 'does not register an offense when using `compact/compact!`' do
    expect_no_offenses(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end

  context 'when without receiver' do
    it 'does not register an offense and corrects when using `reject` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        reject { |e| e.nil? }
        delete_if { |e| e.nil? }
        reject! { |e| e.nil? }
      RUBY
    end

    it 'does not register an offense and corrects when using `select/select!` to reject nils' do
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

    it 'does not register an offense and corrects when using `to_enum.delete_if` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        array.to_enum.delete_if { |e| e.nil? }
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

    it 'does not register an offense and corrects when using `lazy.delete_if` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        array.lazy.delete_if { |e| e.nil? }
      RUBY
    end
  end

  context 'Ruby <= 3.0', :ruby30 do
    it 'does not register an offense and corrects when using `to_enum.reject` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        array.to_enum.reject { |e| e.nil? }
        array.to_enum.delete_if { |e| e.nil? }
        array.to_enum.reject! { |e| e.nil? }
      RUBY
    end

    it 'does not register an offense and corrects when using `lazy.reject` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        array.lazy.reject { |e| e.nil? }
        array.lazy.delete_if { |e| e.nil? }
        array.lazy.reject! { |e| e.nil? }
      RUBY
    end
  end

  context 'when Ruby <= 2.3', :ruby23 do
    it 'does not register an offense when using `reject` on hash to reject nils' do
      expect_no_offenses(<<~RUBY)
        hash.reject { |k, v| v.nil? }
        hash.reject! { |k, v| v.nil? }
      RUBY
    end
  end
end
