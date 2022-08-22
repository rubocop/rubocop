# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashTransformValues, :config do
  context 'when using Ruby 2.4 or newer', :ruby24 do
    context 'with inline block' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          x.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          x.transform_values {|v| foo(v)}
        RUBY
      end
    end

    context 'with multiline block' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          some_hash.each_with_object({}) do |(key, val), memo|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object`.
            memo[key] = val * val
          end
        RUBY

        expect_correction(<<~RUBY)
          some_hash.transform_values do |val|
            val * val
          end
        RUBY
      end
    end

    context 'with safe navigation operator' do
      it 'flags each_with_object when transform_values could be used' do
        expect_offense(<<~RUBY)
          x&.each_with_object({}) {|(k, v), h| h[k] = foo(v)}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `each_with_object`.
        RUBY

        expect_correction(<<~RUBY)
          x&.transform_values {|v| foo(v)}
        RUBY
      end
    end

    it 'does not flag each_with_object when both key & value are transformed' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) {|(k, v), h| h[k.to_sym] = foo(v)}
      RUBY
    end

    it 'does not flag each_with_object when value transformation uses key' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[k] = k.to_s}')
    end

    it 'does not flag each_with_object when no transformation occurs' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[k] = v}')
    end

    it 'does not flag each_with_object when its argument is not modified' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) {|(k, v), h| other_h[k] = v * v}
      RUBY
    end

    it 'does not flag `each_with_object` when its argument is used in the value' do
      expect_no_offenses(<<~RUBY)
        x.each_with_object({}) { |(k, v), h| h[k] = h.count }
      RUBY
    end

    it 'does not flag each_with_object when receiver is array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_object({}) {|(k, v), h| h[k] = foo(v)}
      RUBY
    end

    it 'does not flag `each_with_object` when its receiver is `each_with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_index.each_with_object({}) { |(k, v), h| h[k] = foo(v) }
      RUBY
    end

    it 'does not flag `each_with_object` when its receiver is `with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each.with_index.each_with_object({}) { |(k, v), h| h[k] = foo(v) }
      RUBY
    end

    it 'does not flag `each_with_object` when its receiver is `zip`' do
      expect_no_offenses(<<~RUBY)
        %i[a b c].zip([1, 2, 3]).each_with_object({}) { |(k, v), h| h[k] = foo(v) }
      RUBY
    end

    it 'flags _.map {...}.to_h when transform_values could be used' do
      expect_offense(<<~RUBY)
        x.map {|k, v| [k, foo(v)]}.to_h
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `map {...}.to_h`.
      RUBY

      expect_correction(<<~RUBY)
        x.transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags _.map {...}.to_h when transform_values could be used when line break before `to_h`' do
      expect_offense(<<~RUBY)
        x.map {|k, v| [k, foo(v)]}.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `map {...}.to_h`.
          to_h
      RUBY

      expect_correction(<<~RUBY)
        x.transform_values {|v| foo(v)}
      RUBY
    end

    it 'flags _.map {...}.to_h when transform_values could be used when wrapped in another block' do
      expect_offense(<<~RUBY)
        wrapping do
          x.map do |k, v|
          ^^^^^^^^^^^^^^^ Prefer `transform_values` over `map {...}.to_h`.
            [k, v.to_s]
          end.to_h
        end
      RUBY

      expect_correction(<<~RUBY)
        wrapping do
          x.transform_values do |v|
            v.to_s
          end
        end
      RUBY
    end

    it 'does not flag _.map{...}.to_h when both key & value are transformed' do
      expect_no_offenses('x.map {|k, v| [k.to_sym, foo(v)]}.to_h')
    end

    it 'flags Hash[_.map{...}] when transform_values could be used' do
      expect_offense(<<~RUBY)
        Hash[x.map {|k, v| [k, foo(v)]}]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `Hash[_.map {...}]`.
      RUBY

      expect_correction(<<~RUBY)
        x.transform_values {|v| foo(v)}
      RUBY
    end

    it 'does not flag Hash[_.map{...}] when both key & value are transformed' do
      expect_no_offenses('Hash[x.map {|k, v| [k.to_sym, foo(v)]}]')
    end

    it 'does not flag _.map {...}.to_h when value block argument is unused' do
      expect_no_offenses(<<~RUBY)
        x.map {|k, _v| [k, k]}.to_h
      RUBY
    end

    it 'does not flag value transformation in the absence of to_h' do
      expect_no_offenses('x.map {|k, v| [k, foo(v)]}')
    end

    it 'does not flag value transformation when receiver is array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].map {|k, v| [k, foo(v)]}.to_h
      RUBY
    end

    it 'does not flag `_.map{...}.to_h` when its receiver is `each_with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_index.map { |k, v| [k, foo(v)] }.to_h
      RUBY
    end

    it 'does not flag `_.map{...}.to_h` when its receiver is `with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each.with_index.map { |k, v| [k, foo(v)] }.to_h
      RUBY
    end

    it 'does not flag `_.map{...}.to_h` when its receiver is `zip`' do
      expect_no_offenses(<<~RUBY)
        %i[a b c].zip([1, 2, 3]).map { |k, v| [k, foo(v)] }.to_h
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

    it 'does not flag `Hash[_.map{...}]` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        Hash[[1, 2, 3].map { |k, v| [k, foo(v)] }]
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is `each_with_index`' do
      expect_no_offenses(<<~RUBY)
        Hash[[1, 2, 3].each_with_index.map { |k, v| [k, foo(v)] }]
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is `with_index`' do
      expect_no_offenses(<<~RUBY)
        Hash[[1, 2, 3].each.with_index.map { |k, v| [k, foo(v)] }]
      RUBY
    end

    it 'does not flag `Hash[_.map{...}]` when its receiver is `zip`' do
      expect_no_offenses(<<~RUBY)
        Hash[%i[a b c].zip([1, 2, 3]).map { |k, v| [k, foo(v)] }]
      RUBY
    end
  end

  context 'when using Ruby 2.6 or newer', :ruby26 do
    it 'flags _.to_h{...} when transform_values could be used' do
      expect_offense(<<~RUBY)
        x.to_h {|k, v| [k, foo(v)]}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        x.transform_values {|v| foo(v)}
      RUBY
    end

    it 'register and corrects an offense _.to_h{...} when value is a hash literal and is enclosed in braces' do
      expect_offense(<<~RUBY)
        {a: 1, b: 2}.to_h { |key, val| [key, { value: val }] }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `transform_values` over `to_h {...}`.
      RUBY

      expect_correction(<<~RUBY)
        {a: 1, b: 2}.transform_values { |val| { value: val } }
      RUBY
    end

    it 'register and corrects an offense _.to_h{...} when value is a hash literal and is not enclosed in braces' do
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
        x.to_h { |k, v| [k.to_sym, foo(v)] }
      RUBY
    end

    it 'does not flag _.to_h {...} when value block argument is unused' do
      expect_no_offenses(<<~RUBY)
        x.to_h {|k, _v| [k, k]}
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].to_h { |k, v| [k, foo(v)] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is `each_with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each_with_index.to_h { |k, v| [k, foo(v)] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is `with_index`' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each.with_index.to_h { |k, v| [k, foo(v)] }
      RUBY
    end

    it 'does not flag `_.to_h{...}` when its receiver is `zip`' do
      expect_no_offenses(<<~RUBY)
        %i[a b c].zip([1, 2, 3]).to_h { |k, v| [k, foo(v)] }
      RUBY
    end
  end

  context 'below Ruby 2.4', :ruby23 do
    it 'does not flag even if transform_values could be used' do
      expect_no_offenses('x.each_with_object({}) {|(k, v), h| h[k] = foo(v)}')
    end
  end

  context 'below Ruby 2.6', :ruby25 do
    it 'does not flag _.to_h{...}' do
      expect_no_offenses(<<~RUBY)
        x.to_h {|k, v| [k, foo(v)]}
      RUBY
    end
  end
end
