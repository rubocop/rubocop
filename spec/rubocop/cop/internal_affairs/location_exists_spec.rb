# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::LocationExists, :config do
  context 'code that can be replaced with `loc?`' do
    it 'does not register an offense for `respond_to?` without `&&' do
      expect_no_offenses(<<~RUBY)
        node.loc.respond_to?(:begin)
      RUBY
    end

    it 'does not register an offense when the receiver does not match' do
      expect_no_offenses(<<~RUBY)
        node.loc.respond_to?(:begin) && other_node.loc.begin
      RUBY
    end

    it 'does not register an offense when the location does not match' do
      expect_no_offenses(<<~RUBY)
        node.loc.respond_to?(:begin) && node.loc.end
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

  context 'code that can be replaced with `loc_is?`' do
    it 'does not register an offense when the receiver does not match' do
      expect_no_offenses(<<~RUBY)
        node.loc.respond_to?(:begin) && other_node.loc.begin.is?('(')
      RUBY
    end

    it 'does not register an offense when the location does not match' do
      expect_no_offenses(<<~RUBY)
        node.loc.respond_to?(:begin) && node.loc.end.is?('(')
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
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          node.loc.respond_to?(:begin) && node.loc.begin.source != '('
        RUBY
      end
    end

    context 'when using `source.start_with?`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          node.loc.respond_to?(:begin) && node.loc.begin.source.start_with?('(')
        RUBY
      end
    end
  end
end
