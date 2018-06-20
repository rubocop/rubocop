# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IpAddresses, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { {} }

  it 'does not register an offense on an empty string' do
    expect_no_offenses("''")
  end

  context 'IPv4' do
    it 'registers an offense for a valid address' do
      expect_offense(<<-RUBY.strip_indent)
        '255.255.255.255'
        ^^^^^^^^^^^^^^^^^ Do not hardcode IP addresses.
      RUBY
    end

    it 'does not register an offense for an invalid address' do
      expect_no_offenses('"578.194.591.059"')
    end

    it 'does not register an offense for an address inside larger text' do
      expect_no_offenses('"My IP is 192.168.1.1"')
    end
  end

  context 'IPv6' do
    it 'registers an offense for a valid address' do
      expect_offense(<<-RUBY.strip_indent)
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not hardcode IP addresses.
      RUBY
    end

    it 'registers an offense for an address with 0s collapsed' do
      expect_offense(<<-RUBY.strip_indent)
        '2001:db8:85a3::8a2e:370:7334'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not hardcode IP addresses.
      RUBY
    end

    it 'registers an offense for a shortened address' do
      expect_offense(<<-RUBY.strip_indent)
        '2001:db8::1'
        ^^^^^^^^^^^^^ Do not hardcode IP addresses.
      RUBY
    end

    it 'registers an offense for a very short address' do
      expect_offense(<<-RUBY.strip_indent)
        '1::'
        ^^^^^ Do not hardcode IP addresses.
      RUBY
    end

    it 'registers an offense for the loopback address' do
      expect_offense(<<-RUBY.strip_indent)
        '::1'
        ^^^^^ Do not hardcode IP addresses.
      RUBY
    end

    it 'does not register an offense for an invalid address' do
      expect_no_offenses('"2001:db8::1xyz"')
    end

    context 'the unspecified address :: (shortform of 0:0:0:0:0:0:0:0)' do
      it 'does not register an offense' do
        expect_no_offenses('"::"')
      end

      context 'when it is removed from the whitelist' do
        let(:cop_config) { { 'Whitelist' => [] } }

        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            '::'
            ^^^^ Do not hardcode IP addresses.
          RUBY
        end
      end
    end
  end

  context 'with whitelist' do
    let(:cop_config) { { 'Whitelist' => ['a::b'] } }

    it 'does not register an offense for a whitelisted address' do
      expect_no_offenses('"a::b"')
    end

    it 'does not register an offense if the case differs' do
      expect_no_offenses('"A::B"')
    end
  end
end
