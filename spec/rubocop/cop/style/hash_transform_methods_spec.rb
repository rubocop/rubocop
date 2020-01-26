# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashTransformMethods, :config do
  subject(:cop) { described_class.new(config) }

  context 'when using Ruby 2.5 or newer', :ruby25 do
    context 'with inline block' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          x.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object` or `map`.
        RUBY
      end
    end

    context 'with multiline block' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          some_hash.each_with_object({}) do |(key, val), memo|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object` or `map`.
            memo[key] = val * val
          end
        RUBY
      end
    end

    context 'with safe navigation operator' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          x&.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object` or `map`.
        RUBY
      end
    end

    it 'flags each_with_object when transform_keys could be used' do
      expect_offense(<<~RUBY)
        x.each_with_object({}) {|(k, v), h| h[k.to_sym] = v}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object` or `map`.
      RUBY
    end

    it 'does not flag each_with_object when both key & value are transformed' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) {|(k, v), h| h[k.to_sym] = foo(v)}
      RUBY
    end

    it 'does not flag each_with_object when key transformation uses value' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[foo(v)] = v}')
    end

    it 'does not flag each_with_object when value transformation uses key' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[k] = k.to_s}')
    end

    it 'does not flag each_with_object when no transformation occurs' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[k] = v}')
    end

    it 'does not flag each_with_object when its argument is not modified' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| other_h[k] = v}')
    end

    it 'flags _.map{...}.to_h when transform_values could be used' do
      expect_offense(<<~RUBY)
        x.map {|k, v| [k, foo(v)]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object` or `map`.
      RUBY
    end

    it 'flags _.map{...}.to_h when transform_keys could be used' do
      expect_offense(<<~RUBY)
        x.map {|k, v| [k.to_sym, v]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object` or `map`.
      RUBY
    end

    it 'does not flag _.map{...}.to_h when both key & value are transformed' do
      expect_no_offenses('x.map {|k, v| [k.to_sym, foo(v)]}.to_h')
    end

    it 'flags Hash[_.map{...}] when transform_values could be used' do
      expect_offense(<<~RUBY)
        Hash[x.map {|k, v| [k, foo(v)]}]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object` or `map`.
      RUBY
    end

    it 'flags Hash[_.map{...}] when transform_keys could be used' do
      expect_offense(<<~RUBY)
        Hash[x.map {|k, v| [k.to_sym, v]}]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object` or `map`.
      RUBY
    end

    it 'does not flag Hash[_.map{...}] when both key & value are transformed' do
      expect_no_offenses('Hash[x.map {|k, v| [k.to_sym, foo(v)]}]')
    end

    it 'does not flag value transformation in the absence of to_h' do
      expect_no_offenses('x.map {|k, v| [k, foo(v)]}')
    end

    it 'does not flag key transformation in the absence of to_h' do
      expect_no_offenses('x.map {|k, v| [k.to_sym, v]}')
    end

    it 'correctly autocorrects each_with_object for transform_keys' do
      corrected = autocorrect_source(<<~RUBY)
        {a: 1, b: 2}.each_with_object({}) do |(k, v), h|
          h[k.to_s] = v
        end
      RUBY

      expect(corrected).to eq(<<~RUBY)
        {a: 1, b: 2}.transform_keys do |k|
          k.to_s
        end
      RUBY
    end

    it 'correctly autocorrects each_with_object for transform_values' do
      corrected = autocorrect_source(<<~RUBY)
        {a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
      RUBY

      expect(corrected).to eq(<<~RUBY)
        {a: 1, b: 2}.transform_values {|v| foo(v)}
      RUBY
    end

    it 'correctly autocorrects _.map{...}.to_h for transform_keys' do
      corrected = autocorrect_source(<<~RUBY)
        {a: 1, b: 2}.map do |k, v|
          [k.to_s, v]
        end.to_h
      RUBY

      expect(corrected).to eq(<<~RUBY)
        {a: 1, b: 2}.transform_keys do |k|
          k.to_s
        end
      RUBY
    end

    it 'correctly autocorrects _.map{...}.to_h for transform_values' do
      corrected = autocorrect_source(<<~RUBY)
        {a: 1, b: 2}.map {|k, v| [k, foo(v)]}.to_h
      RUBY

      expect(corrected).to eq(<<~RUBY)
        {a: 1, b: 2}.transform_values {|v| foo(v)}
      RUBY
    end

    it 'correctly autocorrects Hash[_.map{...}] for transform_keys' do
      corrected = autocorrect_source(<<~RUBY)
        Hash[{a: 1, b: 2}.map do |k, v|
          [k.to_s, v]
        end]
      RUBY

      expect(corrected).to eq(<<~RUBY)
        {a: 1, b: 2}.transform_keys do |k|
          k.to_s
        end
      RUBY
    end

    it 'correctly autocorrects Hash[_.map{...}] for transform_values' do
      corrected = autocorrect_source(<<~RUBY)
        Hash[{a: 1, b: 2}.map {|k, v| [k, foo(v)]}]
      RUBY

      expect(corrected).to eq(<<~RUBY)
        {a: 1, b: 2}.transform_values {|v| foo(v)}
      RUBY
    end
  end

  context 'below Ruby 2.5', :ruby24 do
    it 'does not flag even if transform_values could be used' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[k] = foo(v)}')
    end
  end
end
