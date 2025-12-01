# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::LocationExists, :config do
  context 'within an `and` node' do
    context 'code that can be replaced with `loc?`' do
      it 'registers an offense when the receiver does not match' do
        expect_offense(<<~RUBY)
          node.loc.respond_to?(:begin) && other_node.loc.begin
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of `node.loc.respond_to?(:begin)`.
        RUBY

        expect_correction(<<~RUBY)
          node.loc?(:begin) && other_node.loc.begin
        RUBY
      end

      it 'registers an offense when the location does not match' do
        expect_offense(<<~RUBY)
          node.loc.respond_to?(:begin) && node.loc.end
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of `node.loc.respond_to?(:begin)`.
        RUBY

        expect_correction(<<~RUBY)
          node.loc?(:begin) && node.loc.end
        RUBY
      end

      context 'when there is no receiver' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            loc.respond_to?(:begin) && loc.begin
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `loc?(:begin)` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            loc?(:begin)
          RUBY
        end
      end

      context 'when there is a single receiver' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            node.loc.respond_to?(:begin) && node.loc.begin
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            node.loc?(:begin)
          RUBY
        end
      end

      context 'when there is a single receiver with safe navigation' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            node&.loc&.respond_to?(:begin) && node&.loc&.begin
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node&.loc?(:begin)` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            node&.loc?(:begin)
          RUBY
        end
      end

      context 'when the receiver is a method chain' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            foo.bar.loc.respond_to?(:begin) && foo.bar.loc.begin
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo.bar.loc?(:begin)` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            foo.bar.loc?(:begin)
          RUBY
        end
      end

      context 'when the receiver is a method chain with safe navigation' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            foo&.bar&.loc&.respond_to?(:begin) && foo&.bar&.loc&.begin
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo&.bar&.loc?(:begin)` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            foo&.bar&.loc?(:begin)
          RUBY
        end
      end

      context 'when assigned' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            value = node.loc.respond_to?(:begin) && node.loc.begin
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc.begin if node.loc?(:begin)` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            value = node.loc.begin if node.loc?(:begin)
          RUBY
        end

        context 'with safe navigation' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY)
              value = node&.loc&.respond_to?(:begin) && node&.loc&.begin
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node&.loc&.begin if node&.loc?(:begin)` instead of [...]
            RUBY

            expect_correction(<<~RUBY)
              value = node&.loc&.begin if node&.loc?(:begin)
            RUBY
          end
        end
      end
    end

    context 'code that can potentially be replaced with `loc_is?`' do
      it 'registers an offense but does not replace with `loc_is?` when the receiver does not match' do
        expect_offense(<<~RUBY)
          node.loc.respond_to?(:begin) && other_node.loc.begin.is?('(')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of `node.loc.respond_to?(:begin)`.
        RUBY

        expect_correction(<<~RUBY)
          node.loc?(:begin) && other_node.loc.begin.is?('(')
        RUBY
      end

      it 'registers an offense but does not replace with `loc_is?` when the location does not match' do
        expect_offense(<<~RUBY)
          node.loc.respond_to?(:begin) && node.loc.end.is?('(')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of `node.loc.respond_to?(:begin)`.
        RUBY

        expect_correction(<<~RUBY)
          node.loc?(:begin) && node.loc.end.is?('(')
        RUBY
      end

      context 'when there is no receiver' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            loc.respond_to?(:begin) && loc.begin.is?('(')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `loc_is?(:begin, '(')` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            loc_is?(:begin, '(')
          RUBY
        end
      end

      context 'when there is a single receiver' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            node.loc.respond_to?(:begin) && node.loc.begin.is?('(')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc_is?(:begin, '(')` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            node.loc_is?(:begin, '(')
          RUBY
        end
      end

      context 'when there is a single receiver with safe navigation' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            node&.loc&.respond_to?(:begin) && node&.loc&.begin.is?('(')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node&.loc_is?(:begin, '(')` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            node&.loc_is?(:begin, '(')
          RUBY
        end
      end

      context 'when the receiver is a method chain' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            foo.bar.loc.respond_to?(:begin) && foo.bar.loc.begin.is?('(')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo.bar.loc_is?(:begin, '(')` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            foo.bar.loc_is?(:begin, '(')
          RUBY
        end
      end

      context 'when the receiver is a method chain with safe navigation' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            foo&.bar&.loc&.respond_to?(:begin) && foo&.bar&.loc&.begin.is?('(')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo&.bar&.loc_is?(:begin, '(')` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            foo&.bar&.loc_is?(:begin, '(')
          RUBY
        end
      end

      context 'when using `source ==`' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            node.loc.respond_to?(:begin) && node.loc.begin.source == '('
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc_is?(:begin, '(')` instead of [...]
          RUBY

          expect_correction(<<~RUBY)
            node.loc_is?(:begin, '(')
          RUBY
        end
      end

      context 'when using `source !=`' do
        it 'registers an offense but does not replace with `loc_is?`' do
          expect_offense(<<~RUBY)
            node.loc.respond_to?(:begin) && node.loc.begin.source != '('
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of `node.loc.respond_to?(:begin)`.
          RUBY

          expect_correction(<<~RUBY)
            node.loc?(:begin) && node.loc.begin.source != '('
          RUBY
        end
      end

      context 'when using `source.start_with?`' do
        it 'registers an offense but does not replace with `loc_is?`' do
          expect_offense(<<~RUBY)
            node.loc.respond_to?(:begin) && node.loc.begin.source.start_with?('(')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of `node.loc.respond_to?(:begin)`.
          RUBY

          expect_correction(<<~RUBY)
            node.loc?(:begin) && node.loc.begin.source.start_with?('(')
          RUBY
        end
      end
    end
  end

  context 'as a `send` node' do
    it 'registers an offense on `node.loc.respond_to?`' do
      expect_offense(<<~RUBY)
        node.loc.respond_to?(:begin)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of `node.loc.respond_to?(:begin)`.
      RUBY

      expect_correction(<<~RUBY)
        node.loc?(:begin)
      RUBY
    end

    it 'registers an offense and autocorrects on `loc.respond_to?` without receiver' do
      expect_offense(<<~RUBY)
        loc.respond_to?(:begin)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `loc?(:begin)` instead of `loc.respond_to?(:begin)`.
      RUBY

      expect_correction(<<~RUBY)
        loc?(:begin)
      RUBY
    end

    it 'registers an offense within an `if` node' do
      expect_offense(<<~RUBY)
        foo if node.loc.respond_to?(:begin)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.loc?(:begin)` instead of `node.loc.respond_to?(:begin)`.
      RUBY

      expect_correction(<<~RUBY)
        foo if node.loc?(:begin)
      RUBY
    end

    it 'registers an offense within an `if` node without receiver' do
      expect_offense(<<~RUBY)
        foo if loc.respond_to?(:begin)
               ^^^^^^^^^^^^^^^^^^^^^^^ Use `loc?(:begin)` instead of `loc.respond_to?(:begin)`.
      RUBY

      expect_correction(<<~RUBY)
        foo if loc?(:begin)
      RUBY
    end
  end
end
