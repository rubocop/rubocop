# frozen_string_literal: true

describe RuboCop::Cop::Style::SignalException, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is `semantic`' do
    let(:cop_config) { { 'EnforcedStyle' => 'semantic' } }

    it 'registers an offense for raise in begin section' do
      inspect_source(cop, <<-END.strip_indent)
        begin
          raise
        rescue Exception
          #do nothing
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.'])
    end

    it 'registers an offense for raise in def body' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          raise
        rescue Exception
          #do nothing
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.'])
    end

    it 'registers an offense for fail in rescue section' do
      inspect_source(cop, <<-END.strip_indent)
        begin
          fail
        rescue Exception
          fail
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `raise` instead of `fail` to rethrow exceptions.'])
    end

    it 'accepts raise in rescue section' do
      inspect_source(cop, <<-END.strip_indent)
        begin
          fail
        rescue Exception
          raise RuntimeError
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts raise in def with multiple rescues' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          fail
        rescue StandardError
          # handle error
        rescue Exception
          raise
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for fail in def rescue section' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          fail
        rescue Exception
          fail
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `raise` instead of `fail` to rethrow exceptions.'])
    end

    it 'registers an offense for fail in second rescue' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          fail
        rescue StandardError
          # handle error
        rescue Exception
          fail
        end
      END
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers only offense for one raise that should be fail' do
      # This is a special case that has caused double reporting.
      inspect_source(cop, <<-END.strip_indent)
        map do
          raise 'I'
        end.flatten.compact
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.'])
    end

    it 'accepts raise in def rescue section' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          fail
        rescue Exception
          raise
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts `raise` and `fail` with explicit receiver' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          test.raise
        rescue Exception
          test.fail
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for `raise` and `fail` with `Kernel` as ' \
       'explicit receiver' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          Kernel.raise
        rescue Exception
          Kernel.fail
        end
      END
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.',
                'Use `raise` instead of `fail` to rethrow exceptions.'])
    end

    it 'registers an offense for raise not in a begin/rescue/end' do
      inspect_source(cop, <<-END.strip_indent)
        case cop_config['EnforcedStyle']
        when 'single_quotes' then true
        when 'double_quotes' then false
        else raise 'Unknown StringLiterals style'
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.'])
    end

    it 'registers one offense for each raise' do
      inspect_source(cop, <<-END.strip_indent)
        cop.stub(:on_def) { raise RuntimeError }
        cop.stub(:on_def) { raise RuntimeError }
      END
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.'] * 2)
    end

    it 'is not confused by nested begin/rescue' do
      inspect_source(cop, <<-END.strip_indent)
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
      END
      expect(cop.offenses.size).to eq(3)
      expect(cop.messages)
        .to eq(['Use `fail` instead of `raise` to signal exceptions.'] * 2 +
               ['Use `raise` instead of `fail` to rethrow exceptions.'])
    end

    it 'auto-corrects raise to fail when appropriate' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        begin
          raise
        rescue Exception
          raise
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        begin
          fail
        rescue Exception
          raise
        end
      END
    end

    it 'auto-corrects fail to raise when appropriate' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        begin
          fail
        rescue Exception
          fail
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        begin
          fail
        rescue Exception
          raise
        end
      END
    end
  end

  context 'when enforced style is `raise`' do
    let(:cop_config) { { 'EnforcedStyle' => 'only_raise' } }

    it 'registers an offense for fail in begin section' do
      inspect_source(cop, <<-END.strip_indent)
        begin
          fail
        rescue Exception
          #do nothing
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Always use `raise` to signal exceptions.'])
    end

    it 'registers an offense for fail in def body' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          fail
        rescue Exception
          #do nothing
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Always use `raise` to signal exceptions.'])
    end

    it 'registers an offense for fail in rescue section' do
      inspect_source(cop, <<-END.strip_indent)
        begin
          raise
        rescue Exception
          fail
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Always use `raise` to signal exceptions.'])
    end

    it 'accepts `fail` if a custom `fail` instance method is defined' do
      inspect_source(cop, <<-END.strip_indent)
        class A
          def fail(arg)
          end
          def other_method
            fail "message"
          end
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts `fail` if a custom `fail` singleton method is defined' do
      inspect_source(cop, <<-END.strip_indent)
        class A
          def self.fail(arg)
          end
          def self.other_method
            fail "message"
          end
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts `fail` with explicit receiver' do
      expect_no_offenses('test.fail')
    end

    it 'registers an offense for `fail` with `Kernel` as explicit receiver' do
      inspect_source(cop, 'Kernel.fail')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Always use `raise` to signal exceptions.'])
    end

    it 'auto-corrects fail to raise always' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        begin
          fail
        rescue Exception
          fail
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        begin
          raise
        rescue Exception
          raise
        end
      END
    end
  end

  context 'when enforced style is `fail`' do
    let(:cop_config) { { 'EnforcedStyle' => 'only_fail' } }

    it 'registers an offense for raise in begin section' do
      inspect_source(cop, <<-END.strip_indent)
        begin
          raise
        rescue Exception
          #do nothing
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Always use `fail` to signal exceptions.'])
    end

    it 'registers an offense for raise in def body' do
      inspect_source(cop, <<-END.strip_indent)
        def test
          raise
        rescue Exception
          #do nothing
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Always use `fail` to signal exceptions.'])
    end

    it 'registers an offense for raise in rescue section' do
      inspect_source(cop, <<-END.strip_indent)
        begin
          fail
        rescue Exception
          raise
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Always use `fail` to signal exceptions.'])
    end

    it 'accepts `raise` with explicit receiver' do
      expect_no_offenses('test.raise')
    end

    it 'registers an offense for `raise` with `Kernel` as explicit receiver' do
      inspect_source(cop, 'Kernel.raise')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Always use `fail` to signal exceptions.'])
    end

    it 'auto-corrects raise to fail always' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        begin
          raise
        rescue Exception
          raise
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        begin
          fail
        rescue Exception
          fail
        end
      END
    end
  end
end
