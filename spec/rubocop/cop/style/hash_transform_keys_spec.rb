# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashTransformKeys, :config do
  context 'when using Ruby 2.5 or newer', :ruby25 do
    context 'with inline block' do
      it 'flags each_with_object when transform_keys could be used' do
        expect_offense(<<~RUBY)
          x.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          x.transform_keys {|k| foo(k)}
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

        expect_correction(<<~RUBY)
          some_hash.transform_keys do |key|
            key.to_sym
          end
        RUBY
      end
    end

    context 'with safe navigation operator' do
      it 'flags each_with_object when transform_keys could be used' do
        expect_offense(<<~RUBY)
          x&.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          x&.transform_keys {|k| foo(k)}
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

    it 'does not flag `each_with_object` when its argument is used in the key' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) { |(k, v), h| h[h[k.to_sym]] = v }
      RUBY
    end

    it 'does not flag each_with_object when its receiver is array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_object({}) {|(k, v), h| h[foo(k)] = v}
      RUBY
    end

    it 'does not flag `each_with_object` when its receiver is `each_with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_index.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      RUBY
    end

    it 'does not flag `each_with_object` when its receiver is `with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each.with_index.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      RUBY
    end

    it 'does not flag `each_with_object` when its receiver is `zip`' do
      expect_no_offenses(<<~RUBY)
        %i[a b c].zip([1, 2, 3]).each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      RUBY
    end

    it 'flags _.map{...}.to_h when transform_keys could be used' do
      expect_offense(<<~RUBY)
        x.map {|k, v| [k.to_sym, v]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        x.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'flags _.map{...}.to_h when transform_keys could be used when line break before `to_h`' do
      expect_offense(<<~RUBY)
        x.map {|k, v| [k.to_sym, v]}.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
          to_h
      RUBY

      expect_correction(<<~RUBY)
        x.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'flags _.map {...}.to_h when transform_keys could be used when wrapped in another block' do
      expect_offense(<<~RUBY)
        wrapping do
          x.map do |k, v|
          ^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
            [k.to_sym, v]
          end.to_h
        end
      RUBY

      expect_correction(<<~RUBY)
        wrapping do
          x.transform_keys do |k|
            k.to_sym
          end
        end
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

      expect_correction(<<~RUBY)
        x.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'does not flag Hash[_.map{...}] when both key & value are transformed' do
      expect_no_offenses('Hash[x.map {|k, v| [k.to_sym, foo(v)]}]')
    end

    it 'does not flag _.map {...}.to_h when key block argument is unused' do
      expect_no_offenses(<<~RUBY)
        x.map {|_k, v| [v, v]}.to_h
      RUBY
    end

    it 'does not flag key transformation in the absence of to_h' do
      expect_no_offenses('x.map {|k, v| [k.to_sym, v]}')
    end

    it 'does not flag key transformation when receiver is array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].map {|k, v| [k.to_sym, v]}.to_h
      RUBY
    end

    it 'does not flag `_.map{...}.to_h` when its receiver is `each_with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_index.map { |k, v| [k.to_sym, v] }.to_h
      RUBY
    end

    it 'does not flag `_.map{...}.to_h` when its receiver is `with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each.with_index.map { |k, v| [k.to_sym, v] }.to_h
      RUBY
    end

    it 'does not flag `_.map{...}.to_h` when its receiver is `zip`' do
      expect_no_offenses(<<~RUBY)
        %i[a b c].zip([1, 2, 3]).map { |k, v| [k.to_sym, v] }.to_h
      RUBY
    end

    it 'correctly autocorrects _.map{...}.to_h without block' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.map do |k, v|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
          [k.to_s, v]
        end.to_h
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_keys do |k|
          k.to_s
        end
      RUBY
    end

    it 'correctly autocorrects _.map{...}.to_h with block' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.map {|k, v| [k.to_s, v]}.to_h {|k, v| [v, k]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_keys {|k| k.to_s}.to_h {|k, v| [v, k]}
      RUBY
    end

    it 'correctly autocorrects Hash[_.map{...}]' do
      expect_offense(<<~RUBY)
        Hash[{a: 1, b: 2}.map do |k, v|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `Hash[_.map {...}]`.
          [k.to_s, v]
        end]
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_keys do |k|
          k.to_s
        end
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        Hash[[1, 2, 3].map { |k, v| [k.to_sym, v] }]
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is `each_with_index`' do
      expect_no_offenses(<<~RUBY)
        Hash[[1, 2, 3].each_with_index.map { |k, v| [k.to_sym, v] }]
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is `with_index`' do
      expect_no_offenses(<<~RUBY)
        Hash[[1, 2, 3].each.with_index.map { |k, v| [k.to_sym, v] }]
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is `zip`' do
      expect_no_offenses(<<~RUBY)
        Hash[%i[a b c].zip([1, 2, 3]).map { |k, v| [k.to_sym, v] }]
      RUBY
    end
  end

  context 'below Ruby 2.5', :ruby24 do
    it 'does not flag even if transform_keys could be used' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[foo(k)] = v}')
    end
  end

  context 'when using Ruby 2.6 or newer', :ruby26 do
    it 'flags _.to_h{...} when transform_keys could be used' do
      expect_offense(<<~RUBY)
        x.to_h {|k, v| [k.to_sym, v]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        x.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'does not flag `_.to_h{...}` when both key & value are transformed' do
      expect_no_offenses(<<~RUBY)
        x.to_h { |k, v| [k.to_sym, foo(v)] }
      RUBY
    end

    it 'does not flag _.to_h {...} when key block argument is unused' do
      expect_no_offenses(<<~RUBY)
        x.to_h {|_k, v| [v, v]}
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].to_h { |k, v| [k.to_sym, v] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is `each_with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_index.to_h { |k, v| [k.to_sym, v] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is `with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each.with_index.to_h { |k, v| [k.to_sym, v] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is `zip`' do
      expect_no_offenses(<<~RUBY)
        %i[a b c].zip([1, 2, 3]).to_h { |k, v| [k.to_sym, v] }
      RUBY
    end
  end

  context 'below Ruby 2.6', :ruby25 do
    it 'does not flag _.to_h{...}' do
      expect_no_offenses(<<~RUBY)
        x.to_h {|k, v| [k.to_sym, v]}
      RUBY
    end
  end
end
