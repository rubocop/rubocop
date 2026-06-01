# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousBlockAssociation, :config do
  shared_examples 'accepts' do |code|
    it 'does not register an offense' do
      expect_no_offenses(code)
    end
  end

  it_behaves_like 'accepts', 'foo == bar { baz a }'
  it_behaves_like 'accepts', 'foo ->(a) { bar a }'
  it_behaves_like 'accepts', 'some_method(a) { |el| puts el }'
  it_behaves_like 'accepts', 'some_method(a) { puts _1 }'
  it_behaves_like 'accepts', 'some_method(a) do;puts a;end'
  it_behaves_like 'accepts', 'some_method a do;puts "dev";end'
  it_behaves_like 'accepts', 'some_method a do |e|;puts e;end'
  it_behaves_like 'accepts', 'Foo.bar(a) { |el| puts el }'
  it_behaves_like 'accepts', 'env ENV.fetch("ENV") { "dev" }'
  it_behaves_like 'accepts', 'env(ENV.fetch("ENV") { "dev" })'
  it_behaves_like 'accepts', '{ f: "b"}.fetch(:a) do |e|;puts e;end'
  it_behaves_like 'accepts', 'Hash[some_method(a) { |el| el }]'
  it_behaves_like 'accepts', 'foo = lambda do |diagnostic|;end'
  it_behaves_like 'accepts', 'Proc.new { puts "proc" }'
  it_behaves_like 'accepts', 'expect { order.save }.to(change { orders.size })'
  it_behaves_like 'accepts', 'scope :active, -> { where(status: "active") }'
  it_behaves_like 'accepts', 'scope :active, proc { where(status: "active") }'
  it_behaves_like 'accepts', 'scope :active, Proc.new { where(status: "active") }'
  it_behaves_like('accepts', 'assert_equal posts.find { |p| p.title == "Foo" }, results.first')
  it_behaves_like('accepts', 'assert_equal(posts.find { |p| p.title == "Foo" }, results.first)')
  it_behaves_like('accepts', 'assert_equal(results.first, posts.find { |p| p.title == "Foo" })')
  it_behaves_like('accepts', 'allow(cop).to receive(:on_int) { raise RuntimeError }')
  it_behaves_like('accepts', 'allow(cop).to(receive(:on_int) { raise RuntimeError })')

  context 'without parentheses' do
    context 'without receiver' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          some_method a { |el| puts el }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| puts el }` to make sure that the block will be associated with the `a` method call.
        RUBY

        expect_correction(<<~RUBY)
          some_method(a { |el| puts el })
        RUBY
      end
    end

    context 'without receiver and numblock' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          some_method a { puts _1 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { puts _1 }` to make sure that the block will be associated with the `a` method call.
        RUBY

        expect_correction(<<~RUBY)
          some_method(a { puts _1 })
        RUBY
      end
    end

    context 'without receiver and itblock', :ruby34 do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          some_method a { puts it }
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { puts it }` to make sure that the block will be associated with the `a` method call.
        RUBY

        expect_correction(<<~RUBY)
          some_method(a { puts it })
        RUBY
      end
    end

    context 'with receiver' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Foo.some_method a { |el| puts el }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| puts el }` to make sure that the block will be associated with the `a` method call.
        RUBY

        expect_correction(<<~RUBY)
          Foo.some_method(a { |el| puts el })
        RUBY
      end

      context 'when using safe navigation operator' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            Foo&.some_method a { |el| puts el }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| puts el }` to make sure that the block will be associated with the `a` method call.
          RUBY

          expect_correction(<<~RUBY)
            Foo&.some_method(a { |el| puts el })
          RUBY
        end
      end
    end

    context 'rspec expect {}.to change {}' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          expect { order.expire }.to change { order.events }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `change { order.events }` to make sure that the block will be associated with the `change` method call.
        RUBY

        expect_correction(<<~RUBY)
          expect { order.expire }.to(change { order.events })
        RUBY
      end
    end

    context 'as a hash key' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Hash[some_method a { |el| el }]
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| el }` to make sure that the block will be associated with the `a` method call.
        RUBY

        expect_correction(<<~RUBY)
          Hash[some_method(a { |el| el })]
        RUBY
      end
    end

    context 'with assignment' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          foo = some_method a { |el| puts el }
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| puts el }` to make sure that the block will be associated with the `a` method call.
        RUBY

        expect_correction(<<~RUBY)
          foo = some_method(a { |el| puts el })
        RUBY
      end
    end
  end

  context 'when a do...end block binds to outer method instead of enumerable in arguments' do
    it 'registers an offense for `map` with keyword argument' do
      expect_offense(<<~RUBY)
        render json: queries.map do |q|
                     ^^^^^^^^^^^ `map` is called without a block because the `do` block binds to `render`. Use braces or extract to a variable.
          q.to_h
        end
      RUBY
    end

    it 'registers an offense for `select` with positional argument' do
      expect_offense(<<~RUBY)
        foo bar.select do |x|
            ^^^^^^^^^^ `select` is called without a block because the `do` block binds to `foo`. Use braces or extract to a variable.
          x
        end
      RUBY
    end

    it 'registers an offense for `each`' do
      expect_offense(<<~RUBY)
        foo bar.each do |x|
            ^^^^^^^^ `each` is called without a block because the `do` block binds to `foo`. Use braces or extract to a variable.
          x
        end
      RUBY
    end

    it 'registers an offense for `filter_map`' do
      expect_offense(<<~RUBY)
        foo bar.filter_map do |x|
            ^^^^^^^^^^^^^^ `filter_map` is called without a block because the `do` block binds to `foo`. Use braces or extract to a variable.
          x
        end
      RUBY
    end

    it 'registers an offense for safe navigation on inner method' do
      expect_offense(<<~RUBY)
        foo bar&.map do |x|
            ^^^^^^^^ `map` is called without a block because the `do` block binds to `foo`. Use braces or extract to a variable.
          x
        end
      RUBY
    end

    it 'does not register an offense when the method itself receives the block' do
      expect_no_offenses(<<~RUBY)
        bar.map do |x|
          x
        end
      RUBY
    end

    it 'does not register an offense when outer method is parenthesized' do
      expect_no_offenses(<<~RUBY)
        render(json: queries.map) do |q|
          q
        end
      RUBY
    end

    it 'does not register an offense when inner method has arguments' do
      expect_no_offenses(<<~RUBY)
        render json: queries.map(&:to_s) do |q|
          q
        end
      RUBY
    end

    it 'does not register an offense when inner method already has a block' do
      expect_no_offenses(<<~RUBY)
        render json: queries.map { |q| q } do |q|
          q
        end
      RUBY
    end

    it 'does not register an offense for methods not in the block methods list' do
      expect_no_offenses(<<~RUBY)
        foo bar.something do |x|
          x
        end
      RUBY
    end

    it 'does not register an offense for braces blocks with parentheses' do
      expect_no_offenses(<<~RUBY)
        foo(bar.map { |x| x })
      RUBY
    end

    context 'when AllowedMethods includes the inner method' do
      let(:cop_config) { { 'AllowedMethods' => %w[map] } }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          render json: queries.map do |q|
            q.to_h
          end
        RUBY
      end
    end

    context 'when AllowedPatterns matches the inner method' do
      let(:cop_config) { { 'AllowedPatterns' => [/^queries\.map/] } }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          render json: queries.map do |q|
            q.to_h
          end
        RUBY
      end
    end
  end

  context 'when AllowedMethods is enabled' do
    let(:cop_config) { { 'AllowedMethods' => %w[change] } }

    it 'does not register an offense for an allowed method' do
      expect_no_offenses(<<~RUBY)
        expect { order.expire }.to change { order.events }
      RUBY
    end

    it 'registers an offense for other methods' do
      expect_offense(<<~RUBY)
        expect { order.expire }.to update { order.events }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `update { order.events }` to make sure that the block will be associated with the `update` method call.
      RUBY

      expect_correction(<<~RUBY)
        expect { order.expire }.to(update { order.events })
      RUBY
    end
  end

  context 'when AllowedPatterns is enabled' do
    let(:cop_config) { { 'AllowedPatterns' => [/change/, /receive\(.*?\)\.twice/] } }

    it 'does not register an offense for an allowed method' do
      expect_no_offenses(<<~RUBY)
        expect { order.expire }.to not_change { order.events }
      RUBY

      expect_no_offenses(<<~RUBY)
        expect(order).to receive(:complete).twice { OrderCount.update! }
      RUBY
    end

    it 'registers an offense for other methods' do
      expect_offense(<<~RUBY)
        expect { order.expire }.to update { order.events }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `update { order.events }` to make sure that the block will be associated with the `update` method call.
      RUBY

      expect_correction(<<~RUBY)
        expect { order.expire }.to(update { order.events })
      RUBY
    end
  end
end
