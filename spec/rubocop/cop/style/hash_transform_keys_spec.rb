# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashTransformKeys, :config do
  context 'when using Ruby 2.5 or newer', :ruby25 do
    context 'with inline block' do
      it 'flags each_with_object when transform_keys could be used' do
        expect_offense(<<~RUBY)
          {a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          {a: 1, b: 2}.transform_keys {|k| foo(k)}
        RUBY
      end
    end

    context 'with multiline block' do
      it 'flags each_with_object when transform_keys could be used' do
        expect_offense(<<~RUBY)
          some_hash.to_h.each_with_object({}) do |(key, val), memo|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
            memo[key.to_sym] = val
          end
        RUBY

        expect_correction(<<~RUBY)
          some_hash.to_h.transform_keys do |key|
            key.to_sym
          end
        RUBY
      end
    end

    context 'with safe navigation operator' do
      it 'flags each_with_object when transform_keys could be used' do
        expect_offense(<<~RUBY)
          x.to_h&.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          x.to_h&.transform_keys {|k| foo(k)}
        RUBY
      end
    end

    it 'does not flag each_with_object when both key & value are transformed' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[k.to_sym] = foo(v)}
      RUBY
    end

    it 'does not flag each_with_object when key transformation uses value' do
      expect_no_offenses('{a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[foo(v)] = v}')
    end

    it 'does not flag each_with_object when no transformation occurs' do
      expect_no_offenses('{a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[k] = v}')
    end

    it 'does not flag each_with_object when its argument is not modified' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.each_with_object({}) {|(k, v), h| other_h[k.to_sym] = v}
      RUBY
    end

    it 'does not flag `each_with_object` when its argument is used in the key' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.each_with_object({}) { |(k, v), h| h[h[k.to_sym]] = v }
      RUBY
    end

    it 'does not flag each_with_object when receiver is not a hash' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
      RUBY
    end

    it 'does not flag each_with_object when receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_object({}) {|(k, v), h| h[foo(k)] = v}
      RUBY
    end

    it 'does not flag each_with_object when receiver is a method chain through non-hash methods' do
      expect_no_offenses(<<~RUBY)
        x.to_enum(:foreach, path).select { |entry| entry.file? }.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
      RUBY
    end

    it 'flags each_with_object when receiver is a hash-producing method' do
      expect_offense(<<~RUBY)
        x.to_h.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        x.to_h.transform_keys {|k| foo(k)}
      RUBY
    end

    it 'flags each_with_object when receiver is a group_by block' do
      expect_offense(<<~RUBY)
        x.group_by { |e| e.type }.each_with_object({}) {|(k, v), h| h[foo(k)] = v}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        x.group_by { |e| e.type }.transform_keys {|k| foo(k)}
      RUBY
    end

    it 'flags _.map{...}.to_h when transform_keys could be used' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.map {|k, v| [k.to_sym, v]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'flags _.map{...}.to_h when transform_keys could be used when line break before `to_h`' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.map {|k, v| [k.to_sym, v]}.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
          to_h
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'flags _.map {...}.to_h when transform_keys could be used when wrapped in another block' do
      expect_offense(<<~RUBY)
        wrapping do
          {a: 1, b: 2}.map do |k, v|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
            [k.to_sym, v]
          end.to_h
        end
      RUBY

      expect_correction(<<~RUBY)
        wrapping do
          {a: 1, b: 2}.transform_keys do |k|
            k.to_sym
          end
        end
      RUBY
    end

    it 'does not flag _.map{...}.to_h when both key & value are transformed' do
      expect_no_offenses('{a: 1, b: 2}.map {|k, v| [k.to_sym, foo(v)]}.to_h')
    end

    it 'flags Hash[_.map{...}] when transform_keys could be used' do
      expect_offense(<<~RUBY)
        Hash[{a: 1, b: 2}.map {|k, v| [k.to_sym, v]}]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `Hash[_.map {...}]`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'does not flag Hash[_.map{...}] when both key & value are transformed' do
      expect_no_offenses('Hash[{a: 1, b: 2}.map {|k, v| [k.to_sym, foo(v)]}]')
    end

    it 'does not flag _.map {...}.to_h when key block argument is unused' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.map {|_k, v| [v, v]}.to_h
      RUBY
    end

    it 'does not flag key transformation in the absence of to_h' do
      expect_no_offenses('{a: 1, b: 2}.map {|k, v| [k.to_sym, v]}')
    end

    it 'does not flag key transformation when receiver is not a hash' do
      expect_no_offenses(<<~RUBY)
        x.map {|k, v| [k.to_sym, v]}.to_h
      RUBY
    end

    it 'does not flag `_.map{...}.to_h` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].map {|k, v| [k.to_sym, v]}.to_h
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is not a hash' do
      expect_no_offenses(<<~RUBY)
        Hash[x.map { |k, v| [k.to_sym, v] }]
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        Hash[[1, 2, 3].map { |k, v| [k.to_sym, v] }]
      RUBY
    end

    it 'flags _.map{...}.to_h when receiver is a hash-producing method' do
      expect_offense(<<~RUBY)
        x.to_h.map {|k, v| [k.to_sym, v]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `map {...}.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        x.to_h.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'flags Hash[_.map{...}] when receiver is a hash-producing method' do
      expect_offense(<<~RUBY)
        Hash[x.merge(y).map {|k, v| [k.to_sym, v]}]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `Hash[_.map {...}]`.
      RUBY

      expect_correction(<<~RUBY)
        x.merge(y).transform_keys {|k| k.to_sym}
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
  end

  context 'below Ruby 2.5', :ruby24, unsupported_on: :prism do
    it 'does not flag even if transform_keys could be used' do
      expect_no_offenses('{a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[foo(k)] = v}')
    end
  end

  context 'when using Ruby 2.6 or newer', :ruby26 do
    it 'flags _.to_h{...} when transform_keys could be used' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.to_h {|k, v| [k.to_sym, v]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'flags _.to_h{...} when receiver is a hash-producing method' do
      expect_offense(<<~RUBY)
        x.merge(y).to_h {|k, v| [k.to_sym, v]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        x.merge(y).transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'flags _.to_h{...} when receiver is tally' do
      expect_offense(<<~RUBY)
        x.tally.to_h {|k, v| [k.to_sym, v]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_keys` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        x.tally.transform_keys {|k| k.to_sym}
      RUBY
    end

    it 'does not flag `_.to_h{...}` when both key & value are transformed' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.to_h { |k, v| [k.to_sym, foo(v)] }
      RUBY
    end

    it 'does not flag _.to_h {...} when key block argument is unused' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.to_h {|_k, v| [v, v]}
      RUBY
    end

    it 'does not flag `_.to_h{...}` when receiver is not a hash' do
      expect_no_offenses(<<~RUBY)
        x.to_h { |k, v| [k.to_sym, v] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].to_h { |k, v| [k.to_sym, v] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is a method chain through non-hash methods' do
      expect_no_offenses(<<~RUBY)
        x.to_enum(:foreach, path).select { |e| e.file? }.map { |e| [e, name(e)] }.each { |e, p| e.extract(p) }.to_h { |k, v| [k.to_sym, v] }
      RUBY
    end
  end

  context 'below Ruby 2.6', :ruby25, unsupported_on: :prism do
    it 'does not flag _.to_h{...}' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.to_h {|k, v| [k.to_sym, v]}
      RUBY
    end
  end
end
