# frozen_string_literal: true

describe RuboCop::Cop::Style::NumericLiteralPrefix, :config do
  subject(:cop) { described_class.new(config) }

  context 'octal literals' do
    context 'when config is zero_with_o' do
      let(:cop_config) do
        {
          'EnforcedOctalStyle' => 'zero_with_o'
        }
      end

      it 'registers an offense for prefixes `0` and `0O`' do
        inspect_source(<<-RUBY.strip_indent)
          a = 01234
          b(0O1234)
        RUBY
        expect(cop.offenses.size).to eq(2)
        expect(cop.messages.uniq).to eq(['Use 0o for octal literals.'])
        expect(cop.highlights).to eq(%w[01234 0O1234])
      end

      it 'does not register offense for lowercase prefix' do
        expect_no_offenses(<<-RUBY.strip_indent)
          a = 0o101
          b = 0o567
        RUBY
      end

      it 'autocorrects an octal literal starting with 0' do
        corrected = autocorrect_source(cop, ['a = 01234'])
        expect(corrected).to eq('a = 0o1234')
      end

      it 'autocorrects an octal literal starting with 0O' do
        corrected = autocorrect_source(cop, ['b(0O1234, a)'])
        expect(corrected).to eq('b(0o1234, a)')
      end
    end

    context 'when config is zero_only' do
      let(:cop_config) do
        {
          'EnforcedOctalStyle' => 'zero_only'
        }
      end

      it 'registers an offense for prefix `0O` and `0o`' do
        inspect_source(<<-RUBY.strip_indent)
          a = 0O1234
          b(0o1234)
        RUBY
        expect(cop.offenses.size).to eq(2)
        expect(cop.messages.uniq).to eq(['Use 0 for octal literals.'])
        expect(cop.highlights).to eq(%w[0O1234 0o1234])
      end

      it 'does not register offense for prefix `0`' do
        expect_no_offenses('b = 0567')
      end

      it 'autocorrects an octal literal starting with 0O or 0o' do
        corrected = autocorrect_source(cop, <<-RUBY.strip_indent)
          a = 0O1234
          b(0o1234)
        RUBY

        expect(corrected).to eq <<-RUBY.strip_indent
          a = 01234
          b(01234)
        RUBY
      end

      it 'does not autocorrect an octal literal starting with 0' do
        corrected = autocorrect_source(cop, ['b(01234, a)'])
        expect(corrected).to eq 'b(01234, a)'
      end
    end
  end

  context 'hex literals' do
    it 'registers an offense for uppercase prefix' do
      inspect_source(<<-RUBY.strip_indent)
        a = 0X1AC
        b(0XABC)
      RUBY
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages.uniq).to eq(['Use 0x for hexadecimal literals.'])
      expect(cop.highlights).to eq(%w[0X1AC 0XABC])
    end

    it 'does not register offense for lowercase prefix' do
      expect_no_offenses('a = 0x101')
    end

    it 'autocorrects literals with uppercase prefix' do
      corrected = autocorrect_source(cop, ['a = 0XAB'])
      expect(corrected).to eq 'a = 0xAB'
    end
  end

  context 'binary literals' do
    it 'registers an offense for uppercase prefix' do
      inspect_source(<<-RUBY.strip_indent)
        a = 0B10101
        b(0B111)
      RUBY
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages.uniq).to eq(['Use 0b for binary literals.'])
      expect(cop.highlights).to eq(%w[0B10101 0B111])
    end

    it 'does not register offense for lowercase prefix' do
      expect_no_offenses('a = 0b101')
    end

    it 'autocorrects literals with uppercase prefix' do
      corrected = autocorrect_source(cop, ['a = 0B1010'])
      expect(corrected).to eq 'a = 0b1010'
    end
  end

  context 'decimal literals' do
    it 'registers an offense for prefixes' do
      inspect_source(<<-RUBY.strip_indent)
        a = 0d1234
        b(0D1234)
      RUBY
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages.uniq)
        .to eq(['Do not use prefixes for decimal literals.'])
      expect(cop.highlights).to eq(%w[0d1234 0D1234])
    end

    it 'does not register offense for no prefix' do
      expect_no_offenses('a = 101')
    end

    it 'autocorrects literals with prefix' do
      corrected = autocorrect_source(cop, ['a = 0d1234', 'b(0D1990)'])
      expect(corrected).to eq "a = 1234\nb(1990)"
    end

    it 'does not autocorrect literals with no prefix' do
      corrected = autocorrect_source(cop, ['a = 1234', 'b(1990)'])
      expect(corrected).to eq "a = 1234\nb(1990)"
    end
  end
end
