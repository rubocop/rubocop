# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashTransformValues, :config do
  context 'when using Ruby 2.4 or newer', :ruby24 do
    context 'with inline block' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          {a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          {a: 1, b: 2}.transform_values {|v| foo(v)}
        RUBY
      end
    end

    context 'with multiline block' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          some_hash.to_h.each_with_object({}) do |(key, val), memo|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object`.
            memo[key] = val * val
          end
        RUBY

        expect_correction(<<~RUBY)
          some_hash.to_h.transform_values do |val|
            val * val
          end
        RUBY
      end
    end

    context 'with safe navigation operator' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          x.to_h&.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          x.to_h&.transform_values {|v| foo(v)}
        RUBY
      end
    end

    it 'does not flag each_with_object when both key & value are transformed' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[k.to_sym] = foo(v)}
      RUBY
    end

    it 'does not flag each_with_object when value transformation uses key' do
      expect_no_offenses('{a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[k] = k.to_s}')
    end

    it 'does not flag each_with_object when no transformation occurs' do
      expect_no_offenses('{a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[k] = v}')
    end

    it 'does not flag each_with_object when its argument is not modified' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.each_with_object({}) {|(k, v), h| other_h[k] = v * v}
      RUBY
    end

    it 'does not flag `each_with_object` when its argument is used in the value' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.each_with_object({}) { |(k, v), h| h[k] = h.count }
      RUBY
    end

    it 'does not flag each_with_object when receiver is not a hash' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
      RUBY
    end

    it 'does not flag each_with_object when receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_object({}) {|(k, v), h| h[k] = foo(v)}
      RUBY
    end

    it 'does not flag each_with_object when receiver is a method chain through non-hash methods' do
      expect_no_offenses(<<~RUBY)
        x.to_enum(:foreach, path).select { |entry| entry.file? }.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
      RUBY
    end

    it 'flags each_with_object when receiver is a hash-producing method' do
      expect_offense(<<~RUBY)
        x.to_h.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        x.to_h.transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags each_with_object when receiver is a group_by block' do
      expect_offense(<<~RUBY)
        x.group_by { |e| e.type }.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        x.group_by { |e| e.type }.transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags _.map {...}.to_h when transform_values could be used' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.map {|k, v| [k, foo(v)]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `map {...}.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags _.map {...}.to_h when transform_values could be used when line break before `to_h`' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.map {|k, v| [k, foo(v)]}.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `map {...}.to_h`.
          to_h
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags _.map {...}.to_h when transform_values could be used when wrapped in another block' do
      expect_offense(<<~RUBY)
        wrapping do
          {a: 1, b: 2}.map do |k, v|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `map {...}.to_h`.
            [k, v.to_s]
          end.to_h
        end
      RUBY

      expect_correction(<<~RUBY)
        wrapping do
          {a: 1, b: 2}.transform_values do |v|
            v.to_s
          end
        end
      RUBY
    end

    it 'does not flag _.map{...}.to_h when both key & value are transformed' do
      expect_no_offenses('{a: 1, b: 2}.map {|k, v| [k.to_sym, foo(v)]}.to_h')
    end

    it 'flags Hash[_.map{...}] when transform_values could be used' do
      expect_offense(<<~RUBY)
        Hash[{a: 1, b: 2}.map {|k, v| [k, foo(v)]}]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `Hash[_.map {...}]`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_values {|v| foo(v)}
      RUBY
    end

    it 'does not flag Hash[_.map{...}] when both key & value are transformed' do
      expect_no_offenses('Hash[{a: 1, b: 2}.map {|k, v| [k.to_sym, foo(v)]}]')
    end

    it 'does not flag _.map {...}.to_h when value block argument is unused' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.map {|k, _v| [k, k]}.to_h
      RUBY
    end

    it 'does not flag value transformation in the absence of to_h' do
      expect_no_offenses('{a: 1, b: 2}.map {|k, v| [k, foo(v)]}')
    end

    it 'does not flag value transformation when receiver is not a hash' do
      expect_no_offenses(<<~RUBY)
        x.map {|k, v| [k, foo(v)]}.to_h
      RUBY
    end

    it 'does not flag `_.map{...}.to_h` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].map {|k, v| [k, foo(v)]}.to_h
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is not a hash' do
      expect_no_offenses(<<~RUBY)
        Hash[x.map { |k, v| [k, foo(v)] }]
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        Hash[[1, 2, 3].map { |k, v| [k, foo(v)] }]
      RUBY
    end

    it 'flags _.map{...}.to_h when receiver is a hash-producing method' do
      expect_offense(<<~RUBY)
        x.to_h.map {|k, v| [k, foo(v)]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `map {...}.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        x.to_h.transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags Hash[_.map{...}] when receiver is a hash-producing method' do
      expect_offense(<<~RUBY)
        Hash[x.merge(y).map {|k, v| [k, foo(v)]}]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `Hash[_.map {...}]`.
      RUBY

      expect_correction(<<~RUBY)
        x.merge(y).transform_values {|v| foo(v)}
      RUBY
    end

    it 'correctly autocorrects _.map{...}.to_h with block' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.map {|k, v| [k, foo(v)]}.to_h {|k, v| [v, k]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `map {...}.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_values {|v| foo(v)}.to_h {|k, v| [v, k]}
      RUBY
    end
  end

  context 'when using Ruby 2.6 or newer', :ruby26 do
    it 'flags _.to_h{...} when transform_values could be used' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.to_h {|k, v| [k, foo(v)]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags _.to_h{...} when receiver is a hash-producing method' do
      expect_offense(<<~RUBY)
        x.merge(y).to_h {|k, v| [k, foo(v)]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        x.merge(y).transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags _.to_h{...} when receiver is tally' do
      expect_offense(<<~RUBY)
        x.tally.to_h {|k, v| [k, foo(v)]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        x.tally.transform_values {|v| foo(v)}
      RUBY
    end

    it 'registers and corrects an offense _.to_h{...} when value is a hash literal and is enclosed in braces' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.to_h { |key, val| [key, { value: val }] }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_values { |val| { value: val } }
      RUBY
    end

    it 'registers and corrects an offense _.to_h{...} when value is a hash literal and is not enclosed in braces' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.to_h { |key, val| [key, value: val] }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_values { |val| { value: val } }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when both key & value are transformed' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.to_h { |k, v| [k.to_sym, foo(v)] }
      RUBY
    end

    it 'does not flag _.to_h {...} when value block argument is unused' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.to_h {|k, _v| [k, k]}
      RUBY
    end

    it 'does not flag `_.to_h{...}` when receiver is not a hash' do
      expect_no_offenses(<<~RUBY)
        x.to_h { |k, v| [k, foo(v)] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].to_h { |k, v| [k, foo(v)] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is a method chain through non-hash methods' do
      expect_no_offenses(<<~RUBY)
        x.to_enum(:foreach, path).select { |e| e.file? }.map { |e| [e, name(e)] }.each { |e, p| e.extract(p) }.to_h { |k, v| [k, foo(v)] }
      RUBY
    end
  end

  context 'below Ruby 2.4', :ruby23, unsupported_on: :prism do
    it 'does not flag even if transform_values could be used' do
      expect_no_offenses('{a: 1, b: 2}.each_with_object({}) {|(k, v), h| h[k] = foo(v)}')
    end
  end

  context 'below Ruby 2.6', :ruby25, unsupported_on: :prism do
    it 'does not flag _.to_h{...}' do
      expect_no_offenses(<<~RUBY)
        {a: 1, b: 2}.to_h {|k, v| [k, foo(v)]}
      RUBY
    end
  end
end
