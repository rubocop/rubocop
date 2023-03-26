# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MapToSet, :config do
  %i[map collect].each do |method|
    context "for `#{method}.to_set` with block arity 1" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          foo.#{method} { |x| [x, x * 2] }.to_set
              ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
        RUBY

        expect_correction(<<~RUBY)
          foo.to_set { |x| [x, x * 2] }
        RUBY
      end
    end

    context "for `#{method}.to_set` with block arity 2" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          foo.#{method} { |x, y| [x.to_s, y.to_i] }.to_set
              ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
        RUBY

        expect_correction(<<~RUBY)
          foo.to_set { |x, y| [x.to_s, y.to_i] }
        RUBY
      end
    end

    context 'when using numbered parameters', :ruby27 do
      context "for `#{method}.to_set` with block arity 1" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { [_1, _1 * 2] }.to_set
                ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
          RUBY

          expect_correction(<<~RUBY)
            foo.to_set { [_1, _1 * 2] }
          RUBY
        end
      end

      context "for `#{method}.to_set` with block arity 2" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { [_1.to_s, _2.to_i] }.to_set
                ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
          RUBY

          expect_correction(<<~RUBY)
            foo.to_set { [_1.to_s, _2.to_i] }
          RUBY
        end
      end
    end

    context "for `#{method}.to_set` with symbol proc" do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          foo.#{method}(&:do_something).to_set
              ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
        RUBY

        expect_correction(<<~RUBY)
          foo.to_set(&:do_something)
        RUBY
      end
    end

    context 'when the receiver is an array' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          [1, 2, 3].#{method} { |x| [x, x * 2] }.to_set
                    ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].to_set { |x| [x, x * 2] }
        RUBY
      end
    end

    context 'when the receiver is an hash' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          { foo: :bar }.#{method} { |x, y| [x.to_s, y.to_s] }.to_set
                        ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
        RUBY

        expect_correction(<<~RUBY)
          { foo: :bar }.to_set { |x, y| [x.to_s, y.to_s] }
        RUBY
      end
    end

    context 'when chained further' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, method: method)
          foo.#{method} { |x| x * 2 }.to_set.bar
              ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
        RUBY

        expect_correction(<<~RUBY)
          foo.to_set { |x| x * 2 }.bar
        RUBY
      end
    end

    context "`#{method}` without `to_set`" do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, method: method)
          foo.#{method} { |x| x * 2 }
        RUBY
      end
    end

    context "`#{method}.to_set` with a block on `to_set`" do
      it 'registers an offense but does not correct' do
        expect_offense(<<~RUBY, method: method)
          foo.#{method} { |x| x * 2 }.to_set { |x| [x.to_s, x] }
              ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
        RUBY

        expect_no_corrections
      end
    end

    context "`map` and `#{method}.to_set` with newlines" do
      it 'registers an offense and corrects with newline removal' do
        expect_offense(<<~RUBY, method: method)
          {foo: bar}
            .#{method} { |k, v| [k.to_s, v.do_something] }
             ^{method} Pass a block to `to_set` instead of calling `#{method}.to_set`.
            .to_set
            .freeze
        RUBY

        expect_correction(<<~RUBY)
          {foo: bar}
            .to_set { |k, v| [k.to_s, v.do_something] }
            .freeze
        RUBY
      end
    end
  end
end
