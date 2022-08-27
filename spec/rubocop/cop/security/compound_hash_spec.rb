# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::CompoundHash, :config do
  it 'registers an offense when using XOR operator in the implementation of the hash method' do
    expect_offense(<<~RUBY)
      def hash
        1.hash ^ 2.hash ^ 3.hash
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using XOR operator in the implementation of the hash method, even without sub-calls to hash' do
    expect_offense(<<~RUBY)
      def hash
        1 ^ 2 ^ 3
        ^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using XOR operator in the implementation of the hash singleton method' do
    expect_offense(<<~RUBY)
      def object.hash
        1.hash ^ 2.hash ^ 3.hash
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using XOR operator in the implementation of a dynamic hash method' do
    expect_offense(<<~RUBY)
      define_method(:hash) do
        1.hash ^ 2.hash ^ 3.hash
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using XOR operator in the implementation of a dynamic hash singleton method' do
    expect_offense(<<~RUBY)
      define_singleton_method(:hash) do
        1.hash ^ 2.hash ^ 3.hash
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when delegating to Array#hash for a single value' do
    expect_offense(<<~RUBY)
      def hash
        [1].hash
        ^^^^^^^^ Delegate hash directly without wrapping in an array when only using a single value
      end
    RUBY
  end

  it 'registers an offense if .hash is called on any elements of a hashed array' do
    expect_offense(<<~RUBY)
      [1, 2.hash, 3].hash
          ^^^^^^ Calling .hash on elements of a hashed array is redundant
    RUBY
  end

  it 'does not register an offense when delegating to Array#hash' do
    expect_no_offenses(<<~RUBY)
      def hash
        [1, 2, 3].hash
      end
    RUBY
  end

  it 'does not register an offense when delegating to a single object' do
    expect_no_offenses(<<~RUBY)
      def hash
        1.hash
      end
    RUBY
  end

  it 'registers an offense when using XOR operator in the implementation of the hash method, even if intermediate variable is used' do
    expect_offense(<<~RUBY)
      def hash
        value = 1.hash ^ 2.hash ^ 3.hash
                ^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
        value
      end
    RUBY
  end

  it 'registers an offense when using XOR assignment operator in the implementation of the hash method' do
    expect_offense(<<~RUBY)
      def hash
        h = 0

        things.each do |thing|
          h ^= thing.hash
          ^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
        end

        h
      end
    RUBY
  end

  it 'registers an offense when using addition assignment operator in the implementation of the hash method' do
    expect_offense(<<~RUBY)
      def hash
        h = 0

        things.each do |thing|
          h += thing.hash
          ^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
        end

        h
      end
    RUBY
  end

  it 'registers an offense when using multiplication assignment operator in the implementation of the hash method' do
    expect_offense(<<~RUBY)
      def hash
        h = 0

        things.each do |thing|
          h *= thing.hash
          ^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
        end

        h
      end
    RUBY
  end

  it 'registers an offense when using addition in the implementation of the hash method' do
    expect_offense(<<~RUBY)
      def hash
        foo.hash + bar.hash
        ^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using multiplication in the implementation of the hash method' do
    expect_offense(<<~RUBY)
      def hash
        to_s.hash * -1
        ^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using XOR between an array hash and a class' do
    expect_offense(<<~RUBY)
      def hash
        [red, blue, green, alpha].hash ^ self.class.hash
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using XOR involving super' do
    expect_offense(<<~RUBY)
      def hash
        foo.hash ^ super ^ bar.hash
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using XOR and bitshifts' do
    expect_offense(<<~RUBY)
      def hash
        foo.hash ^ bar.hash << 1 ^ biz.hash << 2 ^ bar.hash << 3
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense when using bitshift and OR' do
    expect_offense(<<~RUBY)
      def hash
        ([@addr, @mask_addr, @zone_id].hash << 1) | (ipv4? ? 0 : 1)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
      end
    RUBY
  end

  it 'registers an offense for complex usage' do
    expect_offense(<<~RUBY)
      def hash
        @hash ||= begin
          hash_ = [@factory, geometry_type].hash
          (0...num_geometries).inject(hash_) do |h_, i_|
            (1664525 * h_ + geometry_n(i_).hash).hash
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `[...].hash` instead of combining hash values manually.
          end
        end
      end
    RUBY
  end
end
