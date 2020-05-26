# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashTransformKeys, :config do
  context 'when using Ruby 2.5 or newer', :ruby25 do
    context 'with inline block' do
      it 'flags each_with_object when transform_keys could be used' do
        expect_offense(<<~RUBY)
          x.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
        RUBY
      end
    end

    context 'with multiline block' do
      it 'flags each_with_object when transform_keys could be used' do
        expect_offense(<<~RUBY)
          some_hash.each_with_object({}) do |(key, val), memo|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
            memo[key.to_sym] = val
          end
        RUBY
      end
    end

    context 'with safe navigation operator' do
      it 'flags each_with_object when transform_keyscould be used' do
        expect_offense(<<~RUBY)
          x&.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
        RUBY
      end
    end

    it 'does not flag each_with_object when both key & value are transformed' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) {|(k, v), h| h[k.to_sym] = foo(v)}
      RUBY
    end

    it 'does not flag each_with_object when key transformation uses value' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[foo(v)] = v}')
    end

    it 'does not flag each_with_object when no transformation occurs' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[k] = v}')
    end

    it 'does not flag each_with_object when its argument is not modified' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) {|(k, v), h| other_h[k.to_sym] = v}
      RUBY
    end

    it 'does not flag each_with_object when its receiver is array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_object({}) {|(k, v), h| h[foo(k)] = v}
      RUBY
    end

    it 'flags _.map{...}.to_h when transform_keys could be used' do
      expect_offense(<<~RUBY)
        x.map {|k, v| [k.to_sym, v]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
      RUBY
    end

    it 'flags _.map{...}.to_h when transform_keys could be used ' \
       'when line break before `to_h`' do
      expect_offense(<<~RUBY)
        x.map {|k, v| [k.to_sym, v]}.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
          to_h
      RUBY

      expect_correction(<<~RUBY)
        x.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'does not flag _.map{...}.to_h when both key & value are transformed' do
      expect_no_offenses('x.map {|k, v| [k.to_sym, foo(v)]}.to_h')
    end

    it 'flags Hash[_.map{...}] when transform_keys could be used' do
      expect_offense(<<~RUBY)
        Hash[x.map {|k, v| [k.to_sym, v]}]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `Hash[_.map {...}]`.
      RUBY
    end

    it 'does not flag Hash[_.map{...}] when both key & value are transformed' do
      expect_no_offenses('Hash[x.map {|k, v| [k.to_sym, foo(v)]}]')
    end

    it 'does not flag key transformation in the absence of to_h' do
      expect_no_offenses('x.map {|k, v| [k.to_sym, v]}')
    end

    it 'does not flag key transformation when receiver is array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].map {|k, v| [k.to_sym, v]}.to_h
      RUBY
    end

    it 'correctly autocorrects each_with_object' do
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

    it 'correctly autocorrects _.map{...}.to_h without block' do
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

    it 'correctly autocorrects _.map{...}.to_h with block' do
      corrected = autocorrect_source(<<~RUBY)
        {a: 1, b: 2}.map {|k, v| [k.to_s, v]}.to_h {|k, v| [v, k]}
      RUBY

      expect(corrected).to eq(<<~RUBY)
        {a: 1, b: 2}.transform_keys {|k| k.to_s}.to_h {|k, v| [v, k]}
      RUBY
    end

    it 'correctly autocorrects Hash[_.map{...}]' do
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
  end

  context 'below Ruby 2.5', :ruby24 do
    it 'does not flag even if transform_keys could be used' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[foo(k)] = v}')
    end
  end
end
