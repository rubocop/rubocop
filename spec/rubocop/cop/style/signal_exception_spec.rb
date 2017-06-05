# frozen_string_literal: true

describe RuboCop::Cop::Style::SignalException, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is `semantic`' do
    let(:cop_config) { { 'EnforcedStyle' => 'semantic' } }

    it 'registers an offense for raise in begin section' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          raise
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for raise in def body' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          raise
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for fail in rescue section' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          fail
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
      RUBY
    end

    it 'accepts raise in rescue section' do
      expect_no_offenses(<<-RUBY.strip_indent)
        begin
          fail
        rescue Exception
          raise RuntimeError
        end
      RUBY
    end

    it 'accepts raise in def with multiple rescues' do
      expect_no_offenses(<<-RUBY.strip_indent)
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
      expect_offense(<<-RUBY.strip_indent)
        def test
          fail
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
      RUBY
    end

    it 'registers an offense for fail in second rescue' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          fail
        rescue StandardError
          # handle error
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
      RUBY
    end

    it 'registers only offense for one raise that should be fail' do
      # This is a special case that has caused double reporting.
      expect_offense(<<-RUBY.strip_indent)
        map do
          raise 'I'
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        end.flatten.compact
      RUBY
    end

    it 'accepts raise in def rescue section' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test
          fail
        rescue Exception
          raise
        end
      RUBY
    end

    it 'accepts `raise` and `fail` with explicit receiver' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test
          test.raise
        rescue Exception
          test.fail
        end
      RUBY
    end

    it 'registers an offense for `raise` and `fail` with `Kernel` as ' \
       'explicit receiver' do
      inspect_source(cop, <<-RUBY.strip_indent)
        def test
          Kernel.raise
        rescue Exception
          Kernel.fail
        end
      RUBY
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.',
                'Use `raise` instead of `fail` to rethrow exceptions.'])
    end

    it 'registers an offense for raise not in a begin/rescue/end' do
      expect_offense(<<-RUBY.strip_indent)
        case cop_config['EnforcedStyle']
        when 'single_quotes' then true
        when 'double_quotes' then false
        else raise 'Unknown StringLiterals style'
             ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        end
      RUBY
    end

    it 'registers one offense for each raise' do
      inspect_source(cop, <<-RUBY.strip_indent)
        cop.stub(:on_def) { raise RuntimeError }
        cop.stub(:on_def) { raise RuntimeError }
      RUBY
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.'] * 2)
    end

    it 'is not confused by nested begin/rescue' do
      inspect_source(cop, <<-RUBY.strip_indent)
        begin
          raise
          begin
            raise
          rescue
            fail
          end
        rescue Exception
          #do nothing
        end
      RUBY
      expect(cop.offenses.size).to eq(3)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.'] * 2 +
               ['Use `raise` instead of `fail` to rethrow exceptions.'])
    end

    it 'auto-corrects raise to fail when appropriate' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        begin
          raise
        rescue Exception
          raise
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        begin
          fail
        rescue Exception
          raise
        end
      RUBY
    end

    it 'auto-corrects fail to raise when appropriate' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        begin
          fail
        rescue Exception
          fail
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        begin
          fail
        rescue Exception
          raise
        end
      RUBY
    end
  end

  context 'when enforced style is `raise`' do
    let(:cop_config) { { 'EnforcedStyle' => 'only_raise' } }

    it 'registers an offense for fail in begin section' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          fail
          ^^^^ Always use `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for fail in def body' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          fail
          ^^^^ Always use `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for fail in rescue section' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          raise
        rescue Exception
          fail
          ^^^^ Always use `raise` to signal exceptions.
        end
      RUBY
    end

    it 'accepts `fail` if a custom `fail` instance method is defined' do
      expect_no_offenses(<<-RUBY.strip_indent)
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
      expect_no_offenses(<<-RUBY.strip_indent)
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
      expect_offense(<<-RUBY.strip_indent)
        Kernel.fail
               ^^^^ Always use `raise` to signal exceptions.
      RUBY
    end

    it 'auto-corrects fail to raise always' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        begin
          fail
        rescue Exception
          fail
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        begin
          raise
        rescue Exception
          raise
        end
      RUBY
    end
  end

  context 'when enforced style is `fail`' do
    let(:cop_config) { { 'EnforcedStyle' => 'only_fail' } }

    it 'registers an offense for raise in begin section' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for raise in def body' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        rescue Exception
          #do nothing
        end
      RUBY
    end

    it 'registers an offense for raise in rescue section' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          fail
        rescue Exception
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        end
      RUBY
    end

    it 'accepts `raise` with explicit receiver' do
      expect_no_offenses('test.raise')
    end

    it 'registers an offense for `raise` with `Kernel` as explicit receiver' do
      expect_offense(<<-RUBY.strip_indent)
        Kernel.raise
               ^^^^^ Always use `fail` to signal exceptions.
      RUBY
    end

    it 'auto-corrects raise to fail always' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        begin
          raise
        rescue Exception
          raise
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        begin
          fail
        rescue Exception
          fail
        end
      RUBY
    end
  end
end
