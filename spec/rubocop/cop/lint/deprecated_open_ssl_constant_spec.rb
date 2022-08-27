# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DeprecatedOpenSSLConstant, :config do
  it 'registers an offense with cipher constant and two arguments and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Cipher::AES.new(128, :GCM)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Cipher.new('aes-128-gcm')` instead of `OpenSSL::Cipher::AES.new(128, :GCM)`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Cipher.new('aes-128-gcm')
    RUBY
  end

  it 'registers an offense with cipher constant and one argument and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Cipher::AES.new('128-GCM')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Cipher.new('aes-128-gcm')` instead of `OpenSSL::Cipher::AES.new('128-GCM')`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Cipher.new('aes-128-gcm')
    RUBY
  end

  it 'registers an offense with cipher constant and double quoted string argument and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Cipher::AES128.new("GCM")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Cipher.new('aes-128-gcm')` instead of `OpenSSL::Cipher::AES128.new("GCM")`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Cipher.new('aes-128-gcm')
    RUBY
  end

  it 'registers an offense with cipher constant and `cbc` argument and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Cipher::DES.new('cbc')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Cipher.new('des-cbc')` instead of `OpenSSL::Cipher::DES.new('cbc')`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Cipher.new('des-cbc')
    RUBY
  end

  it 'registers an offense with AES + blocksize constant and mode argument and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Cipher::AES128.new(:GCM)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Cipher.new('aes-128-gcm')` instead of `OpenSSL::Cipher::AES128.new(:GCM)`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Cipher.new('aes-128-gcm')
    RUBY
  end

  RuboCop::Cop::Lint::DeprecatedOpenSSLConstant::NO_ARG_ALGORITHM.each do |algorithm_name|
    it 'registers an offense with cipher constant and no arguments and corrects' do
      expect_offense(<<~RUBY, algorithm_name: algorithm_name)
        OpenSSL::Cipher::#{algorithm_name}.new
        ^^^^^^^^^^^^^^^^^^{algorithm_name}^^^^ Use `OpenSSL::Cipher.new('#{algorithm_name.downcase}')` instead of `OpenSSL::Cipher::#{algorithm_name}.new`.
      RUBY

      expect_correction(<<~RUBY)
        OpenSSL::Cipher.new('#{algorithm_name.downcase}')
      RUBY
    end
  end

  it 'registers an offense with AES + blocksize constant and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Cipher::AES128.new
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Cipher.new('aes-128-cbc')` instead of `OpenSSL::Cipher::AES128.new`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Cipher.new('aes-128-cbc')
    RUBY
  end

  it 'does not register an offense when using cipher with a string' do
    expect_no_offenses(<<~RUBY)
      OpenSSL::Cipher.new('aes-128-gcm')
    RUBY
  end

  it 'does not register an offense with cipher constant and argument is a variable' do
    expect_no_offenses(<<~RUBY)
      mode = "cbc"
      OpenSSL::Cipher::AES128.new(mode)
    RUBY
  end

  it 'does not register an offense with cipher constant and send argument is a method' do
    expect_no_offenses(<<~RUBY)
      OpenSSL::Cipher::AES128.new(do_something)
    RUBY
  end

  it 'does not register an offense with cipher constant and argument is a constant' do
    expect_no_offenses(<<~RUBY)
      OpenSSL::Cipher::AES128.new(MODE)
    RUBY
  end

  it 'registers an offense when building an instance using an digest constant and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Digest::SHA256.new
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Digest.new('SHA256')` instead of `OpenSSL::Digest::SHA256.new`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Digest.new('SHA256')
    RUBY
  end

  it 'registers an offense when using ::Digest class methods on an algorithm constant and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Digest::SHA256.digest('foo')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Digest.digest('SHA256', 'foo')` instead of `OpenSSL::Digest::SHA256.digest('foo')`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Digest.digest('SHA256', 'foo')
    RUBY
  end

  it 'registers an offense when using an digest constant with chained methods and corrects' do
    expect_offense(<<~RUBY)
      OpenSSL::Digest::SHA256.new.digest('foo')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Digest.new('SHA256')` instead of `OpenSSL::Digest::SHA256.new`.
    RUBY

    expect_correction(<<~RUBY)
      OpenSSL::Digest.new('SHA256').digest('foo')
    RUBY
  end

  context 'when used in a block' do
    it 'registers an offense when using ::Digest class methods on an algorithm constant and corrects' do
      expect_offense(<<~RUBY)
        do_something do
          OpenSSL::Digest::SHA1.new
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `OpenSSL::Digest.new('SHA1')` instead of `OpenSSL::Digest::SHA1.new`.
        end
      RUBY

      expect_correction(<<~RUBY)
        do_something do
          OpenSSL::Digest.new('SHA1')
        end
      RUBY
    end
  end

  it 'does not register an offense when building digest using an algorithm string' do
    expect_no_offenses(<<~RUBY)
      OpenSSL::Digest.new('SHA256')
    RUBY
  end

  it 'does not register an offense when building digest using an algorithm string and nested digest constants' do
    expect_no_offenses(<<~RUBY)
      OpenSSL::Digest::Digest.new('SHA256')
    RUBY
  end

  it 'does not register an offense when using ::Digest class methods with an algorithm string and value' do
    expect_no_offenses(<<~RUBY)
      OpenSSL::Digest.digest('SHA256', 'foo')
    RUBY
  end
end
