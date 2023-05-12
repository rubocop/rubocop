# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashExcept, :config do
  context 'Ruby 3.0 or higher', :ruby30 do
    it 'registers and corrects an offense when using `reject` and comparing with `lvar == :sym`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| k == :bar }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it 'registers and corrects an offense when using `reject` and comparing with `:sym == lvar`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| :bar == k }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it 'registers and corrects an offense when using `select` and comparing with `lvar != :sym`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.select { |k, v| k != :bar }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it 'registers and corrects an offense when using `select` and comparing with `:sym != lvar`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.select { |k, v| :bar != k }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it "registers and corrects an offense when using `reject` and comparing with `lvar == 'str'`" do
      expect_offense(<<~RUBY)
        hash.reject { |k, v| k == 'str' }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except('str')` instead.
      RUBY

      expect_correction(<<~RUBY)
        hash.except('str')
      RUBY
    end

    it 'registers and corrects an offense when using `reject` and other than comparison by string and symbol using `eql?`' do
      expect_offense(<<~RUBY)
        hash.reject { |k, v| k.eql?(0.0) }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(0.0)` instead.
      RUBY

      expect_correction(<<~RUBY)
        hash.except(0.0)
      RUBY
    end

    it 'registers and corrects an offense when using `filter` and comparing with `lvar != :sym`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.filter { |k, v| k != :bar }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    context 'using `in?`' do
      it 'does not register offenses when using `reject` and calling `key.in?` method with symbol array' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.in?(%i[foo bar]) }
        RUBY
      end
    end

    context 'using `include?`' do
      it 'registers and corrects an offense when using `reject` and calling `include?` method with symbol array' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| !%i[foo bar].include?(k) }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
        RUBY
      end

      it 'registers and corrects an offense when using `select` and calling `!include?` method with symbol array' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.select { |k, v| !%i[foo bar].include?(k) }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
        RUBY
      end

      it 'registers and corrects an offense when using `filter` and calling `!include?` method with symbol array' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.filter { |k, v| ![:foo, :bar].include?(k) }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
        RUBY
      end

      it 'registers and corrects an offense when using `reject` and calling `include?` method with dynamic symbol array' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| %I[\#{foo} bar].include?(k) }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:"\#{foo}", :bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:"\#{foo}", :bar)
        RUBY
      end

      it 'registers and corrects an offense when using `reject` and calling `include?` method with dynamic string array' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| %W[\#{foo} bar].include?(k) }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except("\#{foo}", 'bar')` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except("\#{foo}", 'bar')
        RUBY
      end

      it 'registers and corrects an offense when using `reject` and calling `include?` method with variable' do
        expect_offense(<<~RUBY)
          array = [:foo, :bar]
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| !array.include?(k) }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(*array)` instead.
        RUBY

        expect_correction(<<~RUBY)
          array = [:foo, :bar]
          {foo: 1, bar: 2, baz: 3}.except(*array)
        RUBY
      end

      it 'registers and corrects an offense when using `reject` and calling `include?` method with method call' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| !array.include?(k) }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(*array)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(*array)
        RUBY
      end

      it 'does not register an offense when using `reject` and calling `include?` method with symbol array and second block value' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| ![1, 2].include?(v) }
        RUBY
      end

      it 'does not register an offense when using `reject` and calling `include?` method on a key' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.include?('oo') }
        RUBY
      end

      it 'does not register an offense when using `reject` and calling `!include?` method on a key' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| !k.include?('oo') }
        RUBY
      end
    end

    context 'using `exclude?`' do
      it 'does not register offenses when using `reject` and calling `!exclude?` method with symbol array' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| !%i[foo bar].exclude?(k) }
        RUBY
      end

      it 'does not register an offense when using `reject` and calling `exclude?` method on a key' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.exclude?('oo') }
        RUBY
      end

      it 'does not register an offense when using `reject` and calling `!exclude?` method on a key' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| !k.exclude?('oo') }
        RUBY
      end
    end

    it 'does not register an offense when using `reject` and other than comparison by string and symbol using `==`' do
      expect_no_offenses(<<~RUBY)
        hash.reject { |k, v| k == 0.0 }
      RUBY
    end

    it 'does not register an offense when using `delete_if` and comparing with `lvar == :sym`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.delete_if { |k, v| k == :bar }
      RUBY
    end

    it 'does not register an offense when using `keep_if` and comparing with `lvar != :sym`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.keep_if { |k, v| k != :bar }
      RUBY
    end

    it 'does not register an offense when comparing with hash value' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| v.eql? :bar }
      RUBY
    end

    context 'when `AllCops/ActiveSupportExtensionsEnabled: true`' do
      let(:config) do
        RuboCop::Config.new('AllCops' => {
                              'TargetRubyVersion' => '3.0',
                              'ActiveSupportExtensionsEnabled' => true
                            })
      end

      it 'registers and corrects an offense when using `reject` and comparing with `lvar == :sym`' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| k == :bar }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:bar)
        RUBY
      end

      it 'registers and corrects an offense when using `reject` and comparing with `:sym == lvar`' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| :bar == k }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:bar)
        RUBY
      end

      it 'registers and corrects an offense when using `select` and comparing with `lvar != :sym`' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.select { |k, v| k != :bar }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:bar)
        RUBY
      end

      it 'registers and corrects an offense when using `select` and comparing with `:sym != lvar`' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.select { |k, v| :bar != k }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:bar)
        RUBY
      end

      it "registers and corrects an offense when using `reject` and comparing with `lvar == 'str'`" do
        expect_offense(<<~RUBY)
          hash.reject { |k, v| k == 'str' }
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except('str')` instead.
        RUBY

        expect_correction(<<~RUBY)
          hash.except('str')
        RUBY
      end

      it 'registers and corrects an offense when using `reject` and other than comparison by string and symbol using `eql?`' do
        expect_offense(<<~RUBY)
          hash.reject { |k, v| k.eql?(0.0) }
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(0.0)` instead.
        RUBY

        expect_correction(<<~RUBY)
          hash.except(0.0)
        RUBY
      end

      it 'registers and corrects an offense when using `filter` and comparing with `lvar != :sym`' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.filter { |k, v| k != :bar }
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.except(:bar)
        RUBY
      end

      context 'using `in?`' do
        it 'registers and corrects an offense when using `reject` and calling `key.in?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.in?(%i[foo bar]) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `select` and calling `!key.in?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.select { |k, v| !k.in?(%i[foo bar]) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `filter` and calling `!key.in?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.filter { |k, v| !k.in?(%i[foo bar]) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `key.in?` method with dynamic symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.in?(%I[\#{foo} bar]) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:"\#{foo}", :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:"\#{foo}", :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `key.in?` method with dynamic string array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.in?(%W[\#{foo} bar]) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except("\#{foo}", 'bar')` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except("\#{foo}", 'bar')
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `key.in?` method with variable' do
          expect_offense(<<~RUBY)
            array = %i[foo bar]
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.in?(array) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(*array)` instead.
          RUBY

          expect_correction(<<~RUBY)
            array = %i[foo bar]
            {foo: 1, bar: 2, baz: 3}.except(*array)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `key.in?` method with method call' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.in?(array) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(*array)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(*array)
          RUBY
        end

        it 'does not register an offense when using `reject` and calling `in?` method with symbol array and second block value' do
          expect_no_offenses(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| v.in?([1, 2]) }
          RUBY
        end
      end

      context 'using `include?`' do
        it 'registers and corrects an offense when using `reject` and calling `include?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !%i[foo bar].include?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `select` and calling `!include?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.select { |k, v| !%i[foo bar].include?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `filter` and calling `!include?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.filter { |k, v| ![:foo, :bar].include?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `include?` method with dynamic symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| %I[\#{foo} bar].include?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:"\#{foo}", :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:"\#{foo}", :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `include?` method with dynamic string array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| %W[\#{foo} bar].include?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except("\#{foo}", 'bar')` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except("\#{foo}", 'bar')
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `include?` method with variable' do
          expect_offense(<<~RUBY)
            array = %i[foo bar]
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !array.include?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(*array)` instead.
          RUBY

          expect_correction(<<~RUBY)
            array = %i[foo bar]
            {foo: 1, bar: 2, baz: 3}.except(*array)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `include?` method with method call' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !array.include?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(*array)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(*array)
          RUBY
        end

        it 'does not register an offense when using `reject` and calling `include?` method on a key' do
          expect_no_offenses(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.include?('oo') }
          RUBY
        end

        it 'does not register an offense when using `reject` and calling `!include?` method on a key' do
          expect_no_offenses(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !k.include?('oo') }
          RUBY
        end
      end

      context 'using `exclude?`' do
        it 'registers and corrects an offense when using `reject` and calling `!exclude?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !%i[foo bar].exclude?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `select` and calling `exclude?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.select { |k, v| %i[foo bar].exclude?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `filter` and calling `exclude?` method with symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.filter { |k, v| [:foo, :bar].exclude?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:foo, :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:foo, :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `!exclude?` method with dynamic symbol array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !%I[\#{foo} bar].exclude?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:"\#{foo}", :bar)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(:"\#{foo}", :bar)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `!exclude?` method with dynamic string array' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !%W[\#{foo} bar].exclude?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except("\#{foo}", 'bar')` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except("\#{foo}", 'bar')
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `!exclude?` method with variable' do
          expect_offense(<<~RUBY)
            array = %i[foo bar]
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !array.exclude?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(*array)` instead.
          RUBY

          expect_correction(<<~RUBY)
            array = %i[foo bar]
            {foo: 1, bar: 2, baz: 3}.except(*array)
          RUBY
        end

        it 'registers and corrects an offense when using `reject` and calling `!exclude?` method with method call' do
          expect_offense(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !array.exclude?(k) }
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(*array)` instead.
          RUBY

          expect_correction(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.except(*array)
          RUBY
        end

        it 'does not register an offense when using `reject` and calling `exclude?` method with symbol array and second block value' do
          expect_no_offenses(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| ![1, 2].exclude?(v) }
          RUBY
        end

        it 'does not register an offense when using `reject` and calling `exclude?` method on a key' do
          expect_no_offenses(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| k.exclude?('oo') }
          RUBY
        end

        it 'does not register an offense when using `reject` and calling `!exclude?` method on a key' do
          expect_no_offenses(<<~RUBY)
            {foo: 1, bar: 2, baz: 3}.reject { |k, v| !k.exclude?('oo') }
          RUBY
        end
      end

      it 'does not register an offense when using `reject` and other than comparison by string and symbol using `==`' do
        expect_no_offenses(<<~RUBY)
          hash.reject { |k, v| k == 0.0 }
        RUBY
      end

      it 'does not register an offense when using `delete_if` and comparing with `lvar == :sym`' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.delete_if { |k, v| k == :bar }
        RUBY
      end

      it 'does not register an offense when using `keep_if` and comparing with `lvar != :sym`' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.keep_if { |k, v| k != :bar }
        RUBY
      end

      it 'does not register an offense when comparing with hash value' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: 2, baz: 3}.reject { |k, v| v.eql? :bar }
        RUBY
      end
    end
  end

  context 'Ruby 2.7 or lower', :ruby27 do
    it 'does not register an offense when using `reject` and comparing with `lvar == :key`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| k == :bar }
      RUBY
    end

    it 'does not register an offense when using `reject` and comparing with `:key == lvar`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| :bar == k }
      RUBY
    end

    it 'does not register an offense when using `select` and comparing with `lvar != :key`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.select { |k, v| k != :bar }
      RUBY
    end

    it 'does not register an offense when using `select` and comparing with `:key != lvar`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.select { |k, v| :bar != k }
      RUBY
    end
  end

  it 'does not register an offense when using `reject` and comparing with `lvar != :key`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject { |k, v| k != :bar }
    RUBY
  end

  it 'does not register an offense when using `reject` and comparing with `:key != lvar`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject { |k, v| :bar != key }
    RUBY
  end

  it 'does not register an offense when using `select` and comparing with `lvar == :key`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.select { |k, v| k == :bar }
    RUBY
  end

  it 'does not register an offense when using `select` and comparing with `:key == lvar`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.select { |k, v| :bar == key }
    RUBY
  end

  it 'does not register an offense when not using key block argument`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject { |k, v| do_something != :bar }
    RUBY
  end

  it 'does not register an offense when using `reject` and `include?`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject { |k, v| [:bar].include?(k) }
    RUBY
  end

  it 'does not register an offense when not using block`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject
    RUBY
  end

  it 'does not register an offense when using `Hash#except`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.except(:bar)
    RUBY
  end
end
