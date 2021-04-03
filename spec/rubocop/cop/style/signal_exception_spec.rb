# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SignalException, :config do
  context 'when enforced style is `semantic`' do
    let(:cop_config) { { 'EnforcedStyle' => 'semantic' } }

    it 'registers an offense for raise in begin section' do
      expect_offense(<<~RUBY)
        begin
          raise
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          fail
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for raise in def body' do
      expect_offense(<<~RUBY)
        def test
          raise
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          fail
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for fail in rescue section' do
      expect_offense(<<~RUBY)
        begin
          fail
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          fail
        rescue Exception
          raise
        end
      RUBY
    end

    it 'accepts raise in rescue section' do
      expect_no_offenses(<<~RUBY)
        begin
          fail
        rescue Exception
          raise RuntimeError
        end
      RUBY
    end

    it 'accepts raise in def with multiple rescues' do
      expect_no_offenses(<<~RUBY)
        def test
          fail
        rescue StandardError
          # handle error
        rescue Exception
          raise
        end
      RUBY
    end

    it 'registers an offense for fail in def rescue section' do
      expect_offense(<<~RUBY)
        def test
          fail
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          fail
        rescue Exception
          raise
        end
      RUBY
    end

    it 'registers an offense for fail in second rescue' do
      expect_offense(<<~RUBY)
        def test
          fail
        rescue StandardError
          # handle error
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          fail
        rescue StandardError
          # handle error
        rescue Exception
          raise
        end
      RUBY
    end

    it 'registers only offense for one raise that should be fail' do
      # This is a special case that has caused double reporting.
      expect_offense(<<~RUBY)
        map do
          raise 'I'
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        end.flatten.compact
      RUBY

      expect_correction(<<~RUBY)
        map do
          fail 'I'
        end.flatten.compact
      RUBY
    end

    it 'accepts raise in def rescue section' do
      expect_no_offenses(<<~RUBY)
        def test
          fail
        rescue Exception
          raise
        end
      RUBY
    end

    it 'accepts `raise` and `fail` with explicit receiver' do
      expect_no_offenses(<<~RUBY)
        def test
          test.raise
        rescue Exception
          test.fail
        end
      RUBY
    end

    it 'registers an offense for `raise` and `fail` with `Kernel` as explicit receiver' do
      expect_offense(<<~RUBY)
        def test
          Kernel.raise
                 ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          Kernel.fail
                 ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          Kernel.fail
        rescue Exception
          Kernel.raise
        end
      RUBY
    end

    it 'registers an offense for `raise` and `fail` with `::Kernel` as explicit receiver' do
      expect_offense(<<~RUBY)
        def test
          ::Kernel.raise
                   ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          ::Kernel.fail
                   ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          ::Kernel.fail
        rescue Exception
          ::Kernel.raise
        end
      RUBY
    end

    it 'registers an offense for raise not in a begin/rescue/end' do
      expect_offense(<<~RUBY)
        case cop_config['EnforcedStyle']
        when 'single_quotes' then true
        when 'double_quotes' then false
        else raise 'Unknown StringLiterals style'
             ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        end
      RUBY

      expect_correction(<<~RUBY)
        case cop_config['EnforcedStyle']
        when 'single_quotes' then true
        when 'double_quotes' then false
        else fail 'Unknown StringLiterals style'
        end
      RUBY
    end

    it 'registers one offense for each raise' do
      expect_offense(<<~RUBY)
        cop.stub(:on_def) { raise RuntimeError }
                            ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        cop.stub(:on_def) { raise RuntimeError }
                            ^^^^^ Use `fail` instead of `raise` to signal exceptions.
      RUBY

      expect_correction(<<~RUBY)
        cop.stub(:on_def) { fail RuntimeError }
        cop.stub(:on_def) { fail RuntimeError }
      RUBY
    end

    it 'is not confused by nested begin/rescue' do
      expect_offense(<<~RUBY)
        begin
          raise
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
          begin
            raise
            ^^^^^ Use `fail` instead of `raise` to signal exceptions.
          rescue
            fail
            ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
          end
        rescue Exception
          #do nothing
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          fail
          begin
            fail
          rescue
            raise
          end
        rescue Exception
          #do nothing
        end
      RUBY
    end
  end

  context 'when enforced style is `raise`' do
    let(:cop_config) { { 'EnforcedStyle' => 'only_raise' } }

    it 'registers an offense for fail in begin section' do
      expect_offense(<<~RUBY)
        begin
          fail
          ^^^^ Always use `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          raise
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for fail in def body' do
      expect_offense(<<~RUBY)
        def test
          fail
          ^^^^ Always use `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          raise
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for fail in rescue section' do
      expect_offense(<<~RUBY)
        begin
          raise
        rescue Exception
          fail
          ^^^^ Always use `raise` to signal exceptions.
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          raise
        rescue Exception
          raise
        end
      RUBY
    end

    it 'accepts `fail` if a custom `fail` instance method is defined' do
      expect_no_offenses(<<~RUBY)
        class A
          def fail(arg)
          end
          def other_method
            fail "message"
          end
        end
      RUBY
    end

    it 'accepts `fail` if a custom `fail` singleton method is defined' do
      expect_no_offenses(<<~RUBY)
        class A
          def self.fail(arg)
          end
          def self.other_method
            fail "message"
          end
        end
      RUBY
    end

    it 'accepts `fail` with explicit receiver' do
      expect_no_offenses('test.fail')
    end

    it 'registers an offense for `fail` with `Kernel` as explicit receiver' do
      expect_offense(<<~RUBY)
        Kernel.fail
               ^^^^ Always use `raise` to signal exceptions.
      RUBY

      expect_correction(<<~RUBY)
        Kernel.raise
      RUBY
    end
  end

  context 'when enforced style is `fail`' do
    let(:cop_config) { { 'EnforcedStyle' => 'only_fail' } }

    it 'registers an offense for raise in begin section' do
      expect_offense(<<~RUBY)
        begin
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          fail
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for raise in def body' do
      expect_offense(<<~RUBY)
        def test
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          fail
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for raise in rescue section' do
      expect_offense(<<~RUBY)
        begin
          fail
        rescue Exception
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          fail
        rescue Exception
          fail
        end
      RUBY
    end

    it 'accepts `raise` with explicit receiver' do
      expect_no_offenses('test.raise')
    end

    it 'registers an offense for `raise` with `Kernel` as explicit receiver' do
      expect_offense(<<~RUBY)
        Kernel.raise
               ^^^^^ Always use `fail` to signal exceptions.
      RUBY

      expect_correction(<<~RUBY)
        Kernel.fail
      RUBY
    end
  end
end
