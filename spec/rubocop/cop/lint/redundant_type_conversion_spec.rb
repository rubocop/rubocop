# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantTypeConversion, :config do
  shared_examples 'accepted' do |source|
    it "does not register an offense on `#{source}`" do
      expect_no_offenses(source)
    end
  end

  shared_examples 'offense' do |conversion, receiver, suffix = ''|
    it "registers an offense and corrects on `#{receiver}.#{conversion}#{suffix}`" do
      expect_offense(<<~RUBY, receiver: receiver, conversion: conversion)
        #{receiver}.#{conversion}#{suffix}
        _{receiver} ^{conversion} Redundant `#{conversion}` detected.
      RUBY

      expect_correction("#{receiver}#{suffix}\n")
    end

    it "registers an offense and corrects on `#{receiver}&.#{conversion}#{suffix}`" do
      expect_offense(<<~RUBY, receiver: receiver, conversion: conversion)
        #{receiver}&.#{conversion}#{suffix}
        _{receiver}  ^{conversion} Redundant `#{conversion}` detected.
      RUBY

      expect_correction("#{receiver}#{suffix}\n")
    end
  end

  shared_examples 'conversion' do |conversion|
    it_behaves_like 'accepted', conversion.to_s.freeze
    it_behaves_like 'accepted', "self.#{conversion}"
    it_behaves_like 'accepted', "foo.#{conversion}"
    it_behaves_like 'accepted', "foo.#{conversion}(2)"
    it_behaves_like 'accepted', "(foo).#{conversion}"
    it_behaves_like 'accepted', "(foo.#{conversion}).bar"
    it_behaves_like 'accepted', "(foo + 'bar').#{conversion}"

    it_behaves_like 'accepted', "'string'.#{conversion}" unless conversion == :to_s
    it_behaves_like 'accepted', ":sym.#{conversion}" unless conversion == :to_sym
    it_behaves_like 'accepted', "1.#{conversion}" unless conversion == :to_i
    it_behaves_like 'accepted', "1.0.#{conversion}" unless conversion == :to_f
    it_behaves_like 'accepted', "1r.#{conversion}" unless conversion == :to_r
    it_behaves_like 'accepted', "1i.#{conversion}" unless conversion == :to_c
    it_behaves_like 'accepted', "[].#{conversion}" unless conversion == :to_a
    it_behaves_like 'accepted', "{}.#{conversion}" unless conversion == :to_h
    it_behaves_like 'accepted', "Set.new.#{conversion}" unless conversion == :to_set

    it "does not register an offense when calling `#{conversion}` on an local variable named `#{conversion}`" do
      expect_no_offenses(<<~RUBY)
        #{conversion} = foo
        #{conversion}.#{conversion}
      RUBY
    end

    context "when chaining `#{conversion}` calls" do
      it "registers an offense and corrects when calling `#{conversion}` on a `#{conversion}` call" do
        expect_offense(<<~RUBY, conversion: conversion)
          foo.#{conversion}.#{conversion}
              _{conversion} ^{conversion} Redundant `#{conversion}` detected.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{conversion}
        RUBY
      end

      it 'registers an offense and corrects when calling `to_s` on a `to_s` call with safe navigation' do
        expect_offense(<<~RUBY, conversion: conversion)
          foo&.#{conversion}&.#{conversion}
               _{conversion}  ^{conversion} Redundant `#{conversion}` detected.
        RUBY

        expect_correction(<<~RUBY)
          foo&.#{conversion}
        RUBY
      end

      it 'registers an offense and corrects when calling `to_s` on a `to_s` call with an argument' do
        expect_offense(<<~RUBY, conversion: conversion)
          foo.#{conversion}(2).#{conversion}
              _{conversion}    ^{conversion} Redundant `#{conversion}` detected.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{conversion}(2)
        RUBY
      end

      it 'registers an offense and corrects when calling `to_s` on a `to_s` call with an argument and safe navigation' do
        expect_offense(<<~RUBY, conversion: conversion)
          foo&.#{conversion}(2)&.#{conversion}
               _{conversion}     ^{conversion} Redundant `#{conversion}` detected.
        RUBY

        expect_correction(<<~RUBY)
          foo&.#{conversion}(2)
        RUBY
      end

      it 'registers an offense and corrects when the redundant `to_s` is chained further' do
        expect_offense(<<~RUBY, conversion: conversion)
          foo.#{conversion}.#{conversion}.bar
              _{conversion} ^{conversion} Redundant `#{conversion}` detected.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{conversion}.bar
        RUBY
      end

      it 'registers an offense and corrects when the redundant `to_s` is chained further with safe navigation' do
        expect_offense(<<~RUBY, conversion: conversion)
          foo&.#{conversion}&.#{conversion}&.bar
               _{conversion}  ^{conversion} Redundant `#{conversion}` detected.
        RUBY

        expect_correction(<<~RUBY)
          foo&.#{conversion}&.bar
        RUBY
      end

      it 'registers an offense for a `to_s` call wrapped in parens' do
        expect_offense(<<~RUBY, conversion: conversion)
          (foo.#{conversion}).#{conversion}
               _{conversion}  ^{conversion} Redundant `#{conversion}` detected.
        RUBY

        expect_correction(<<~RUBY)
          (foo.#{conversion})
        RUBY
      end

      it 'registers an offense for a `to_s` call wrapped in multiple parens' do
        expect_offense(<<~RUBY, conversion: conversion)
          ((foo.#{conversion})).#{conversion}
               _{conversion}    ^{conversion} Redundant `#{conversion}` detected.
        RUBY

        expect_correction(<<~RUBY)
          ((foo.#{conversion}))
        RUBY
      end
    end
  end

  shared_examples 'chained typed method' do |conversion, method|
    it "registers an offense and corrects for `#{method}.#{conversion}" do
      expect_offense(<<~RUBY, method: method, conversion: conversion)
        %{method}.%{conversion}
        _{method} ^{conversion} Redundant `%{conversion}` detected.
      RUBY

      expect_correction(<<~RUBY)
        #{method}
      RUBY
    end

    it "registers an offense and corrects for `foo.#{method}.#{conversion}" do
      expect_offense(<<~RUBY, method: method, conversion: conversion)
        foo.%{method}.%{conversion}
            _{method} ^{conversion} Redundant `%{conversion}` detected.
      RUBY

      expect_correction(<<~RUBY)
        foo.#{method}
      RUBY
    end
  end

  it 'does not register an offense for chaining different conversion methods' do
    expect_no_offenses(<<~RUBY)
      foo.to_i.to_s
    RUBY
  end

  describe '`to_s`' do
    it_behaves_like 'conversion', :to_s

    it_behaves_like 'offense', :to_s, %('string')
    it_behaves_like 'offense', :to_s, %("string")
    it_behaves_like 'offense', :to_s, '%{string}'
    it_behaves_like 'offense', :to_s, '%q{string}'
    it_behaves_like 'offense', :to_s, '%Q{string}'
    it_behaves_like 'offense', :to_s, 'String.new("string")'
    it_behaves_like 'offense', :to_s, '::String.new("string")'
    it_behaves_like 'offense', :to_s, 'String("string")'
    it_behaves_like 'offense', :to_s, 'Kernel::String("string")'
    it_behaves_like 'offense', :to_s, '::Kernel::String("string")'
    it_behaves_like 'offense', :to_s, %{('string')}
    it_behaves_like 'offense', :to_s, %{(('string'))}
    it_behaves_like 'offense', :to_s, %('string'), '.bar'

    it_behaves_like 'chained typed method', :to_s, 'inspect'

    it 'registers an offense and corrects with a heredoc' do
      expect_offense(<<~RUBY)
        <<~STR.to_s
               ^^^^ Redundant `to_s` detected.
          string
        STR
      RUBY

      expect_correction(<<~RUBY)
        <<~STR
          string
        STR
      RUBY
    end
  end

  describe '`to_sym`' do
    it_behaves_like 'conversion', :to_sym

    it_behaves_like 'offense', :to_sym, ':sym'
    it_behaves_like 'offense', :to_sym, ':"#{sym}"'
  end

  describe '`to_i`' do
    it_behaves_like 'conversion', :to_i

    it_behaves_like 'offense', :to_i, '42'
    it_behaves_like 'offense', :to_i, 'Integer(42)'
    it_behaves_like 'offense', :to_i, 'Kernel::Integer(42)'
    it_behaves_like 'offense', :to_i, '::Kernel::Integer(42)'

    it 'does not register an offense with `inspect.to_i`' do
      expect_no_offenses(<<~RUBY)
        inspect.to_i
      RUBY
    end
  end

  describe '`to_f`' do
    it_behaves_like 'conversion', :to_f

    it_behaves_like 'offense', :to_f, '42.0'
    it_behaves_like 'offense', :to_f, 'Float(42)'
    it_behaves_like 'offense', :to_f, 'Kernel::Float(42)'
    it_behaves_like 'offense', :to_f, '::Kernel::Float(42)'
  end

  describe '`to_r`' do
    it_behaves_like 'conversion', :to_r

    it_behaves_like 'offense', :to_r, '5r'
    it_behaves_like 'offense', :to_r, 'Rational(42)'
    it_behaves_like 'offense', :to_r, 'Kernel::Rational(42)'
    it_behaves_like 'offense', :to_r, '::Kernel::Rational(42)'
  end

  describe '`to_c`' do
    it_behaves_like 'conversion', :to_c

    it_behaves_like 'offense', :to_c, '5i'
    it_behaves_like 'offense', :to_c, '5ri'
    it_behaves_like 'offense', :to_c, 'Complex(42)'
    it_behaves_like 'offense', :to_c, 'Kernel::Complex(42)'
    it_behaves_like 'offense', :to_c, '::Kernel::Complex(42)'
  end

  describe '`to_a`' do
    it_behaves_like 'conversion', :to_a

    it_behaves_like 'offense', :to_a, '[1, 2, 3]'
    it_behaves_like 'offense', :to_a, 'Array.new([1, 2, 3])'
    it_behaves_like 'offense', :to_a, '::Array.new([1, 2, 3])'
    it_behaves_like 'offense', :to_a, 'Array([1, 2, 3])'
    it_behaves_like 'offense', :to_a, 'Kernel::Array([1, 2, 3])'
    it_behaves_like 'offense', :to_a, '::Kernel::Array([1, 2, 3])'
    it_behaves_like 'offense', :to_a, 'Array[1, 2, 3]'
    it_behaves_like 'offense', :to_a, '::Array[1, 2, 3]'
  end

  describe '`to_h`' do
    it_behaves_like 'conversion', :to_h

    it_behaves_like 'offense', :to_h, '{ foo: bar }'
    it_behaves_like 'offense', :to_h, 'Hash.new(default)'
    it_behaves_like 'offense', :to_h, '::Hash.new(default)'
    it_behaves_like 'offense', :to_h, 'Hash.new { |key, value| default }'
    it_behaves_like 'offense', :to_h, '::Hash.new { |key, value| default }'
    it_behaves_like 'offense', :to_h, 'Hash({ foo: bar })'
    it_behaves_like 'offense', :to_h, 'Kernel::Hash({ foo: bar })'
    it_behaves_like 'offense', :to_h, '::Kernel::Hash({ foo: bar })'
    it_behaves_like 'offense', :to_h, 'Hash[foo: bar]'
    it_behaves_like 'offense', :to_h, '::Hash[foo: bar]'
  end

  describe '`to_set`' do
    it_behaves_like 'conversion', :to_set

    it_behaves_like 'offense', :to_set, 'Set.new([1, 2, 3])'
    it_behaves_like 'offense', :to_set, '::Set.new([1, 2, 3])'
    it_behaves_like 'offense', :to_set, 'Set[1, 2, 3]'
    it_behaves_like 'offense', :to_set, '::Set[1, 2, 3]'
  end
end
