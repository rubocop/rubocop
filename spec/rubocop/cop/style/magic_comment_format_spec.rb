# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MagicCommentFormat, :config do
  subject(:cop_config) do
    {
      'EnforcedStyle' => enforced_style,
      'DirectiveCapitalization' => directive_capitalization,
      'ValueCapitalization' => value_capitalization
    }
  end

  let(:enforced_style) { 'snake_case' }
  let(:directive_capitalization) { nil }
  let(:value_capitalization) { nil }

  context 'invalid config' do
    let(:source) do
      <<~RUBY
        # encoding: utf-8
        puts 1
      RUBY
    end

    context 'DirectiveCapitalization' do
      let(:directive_capitalization) { 'foobar' }

      it 'raises an error' do
        expect { inspect_source(source) }
          .to raise_error('Unknown `DirectiveCapitalization` foobar selected!')
      end
    end

    context 'ValueCapitalization' do
      let(:value_capitalization) { 'foobar' }

      it 'raises an error' do
        expect { inspect_source(source) }
          .to raise_error('Unknown `ValueCapitalization` foobar selected!')
      end
    end
  end

  context 'snake case style' do
    let(:enforced_style) { 'snake_case' }

    it 'accepts a magic comments in snake case' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true
        # encoding: utf-8
        # shareable_constant_value: literal
        # typed: ignore
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal in snake case in emacs style' do
      expect_no_offenses(<<~RUBY)
        # -*- encoding: ASCII-8BIT; frozen_string_literal: true -*-
        puts 1
      RUBY
    end

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'registers an offense for kebab case' do
      expect_offense(<<~RUBY)
        # frozen-string-literal: true
          ^^^^^^^^^^^^^^^^^^^^^ Prefer snake case for magic comments.
        # encoding: utf-8
        # shareable-constant-value: literal
          ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer snake case for magic comments.
        # typed: ignore

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true
        # encoding: utf-8
        # shareable_constant_value: literal
        # typed: ignore

        puts 1
      RUBY
    end

    it 'registers an offense for kebab case in emacs style' do
      expect_offense(<<~RUBY)
        # -*- encoding: ASCII-8BIT; frozen-string-literal: true -*-
                                    ^^^^^^^^^^^^^^^^^^^^^ Prefer snake case for magic comments.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # -*- encoding: ASCII-8BIT; frozen_string_literal: true -*-
        puts 1
      RUBY
    end

    it 'registers an offense for mixed case' do
      expect_offense(<<~RUBY)
        # frozen-string_literal: true
          ^^^^^^^^^^^^^^^^^^^^^ Prefer snake case for magic comments.

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true

        puts 1
      RUBY
    end

    it 'does not register an offense for dashes in other comments' do
      expect_no_offenses('# foo-bar-baz ')
    end

    it 'does not register an offense for incorrect style in comments after the first statement' do
      expect_no_offenses(<<~RUBY)
        puts 1
        # frozen-string-literal: true
      RUBY
    end
  end

  context 'kebab case style' do
    let(:enforced_style) { 'kebab_case' }

    it 'accepts a magic comments in kebab case' do
      expect_no_offenses(<<~RUBY)
        # frozen-string-literal: true
        # encoding: utf-8
        # shareable-constant-value: literal
        # typed: ignore
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal in snake case in emacs style' do
      expect_no_offenses(<<~RUBY)
        # -*- encoding: ASCII-8BIT; frozen-string-literal: true -*-
        puts 1
      RUBY
    end

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'registers an offense for snake case' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: true
          ^^^^^^^^^^^^^^^^^^^^^ Prefer kebab case for magic comments.
        # encoding: utf-8
        # shareable_constant_value: literal
          ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer kebab case for magic comments.
        # typed: ignore

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen-string-literal: true
        # encoding: utf-8
        # shareable-constant-value: literal
        # typed: ignore

        puts 1
      RUBY
    end

    it 'registers an offense for snake case in emacs style' do
      expect_offense(<<~RUBY)
        # -*- encoding: ASCII-8BIT; frozen_string_literal: true -*-
                                    ^^^^^^^^^^^^^^^^^^^^^ Prefer kebab case for magic comments.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # -*- encoding: ASCII-8BIT; frozen-string-literal: true -*-
        puts 1
      RUBY
    end

    it 'registers an offense for mixed case' do
      expect_offense(<<~RUBY)
        # frozen-string_literal: true
          ^^^^^^^^^^^^^^^^^^^^^ Prefer kebab case for magic comments.

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen-string-literal: true

        puts 1
      RUBY
    end

    it 'does not register an offense for dashes in other comments' do
      expect_no_offenses('# foo-bar-baz ')
    end

    it 'does not register an offense for incorrect style in comments after the first statement' do
      expect_no_offenses(<<~RUBY)
        puts 1
        # frozen-_string_literal: true
      RUBY
    end
  end

  context 'DirectiveCapitalization' do
    context 'when not set' do
      it 'does not change the case of magic comment directives' do
        expect_no_offenses(<<~RUBY)
          # eNcOdInG: utf-8
          puts 1
        RUBY
      end
    end

    context 'when lowercase' do
      let(:directive_capitalization) { 'lowercase' }

      it 'registers an offense and corrects when the case does not match' do
        expect_offense(<<~RUBY)
          # eNcOdInG: utf-8
            ^^^^^^^^ Prefer lower snake case for magic comments.
          puts 1
        RUBY

        expect_correction(<<~RUBY)
          # encoding: utf-8
          puts 1
        RUBY
      end
    end

    context 'when uppercase' do
      let(:directive_capitalization) { 'uppercase' }

      it 'registers an offense and corrects when the case does not match' do
        expect_offense(<<~RUBY)
          # eNcOdInG: utf-8
            ^^^^^^^^ Prefer upper snake case for magic comments.
          puts 1
        RUBY

        expect_correction(<<~RUBY)
          # ENCODING: utf-8
          puts 1
        RUBY
      end
    end
  end

  context 'ValueCapitalization' do
    context 'when not set' do
      it 'does not change the case of magic comment directives' do
        expect_no_offenses(<<~RUBY)
          # encoding: UtF-8
          puts 1
        RUBY
      end
    end

    context 'when lowercase' do
      let(:value_capitalization) { 'lowercase' }

      it 'registers an offense and corrects when the case does not match' do
        expect_offense(<<~RUBY)
          # encoding: UtF-8
                      ^^^^^ Prefer lowercase for magic comment values.
          puts 1
        RUBY

        expect_correction(<<~RUBY)
          # encoding: utf-8
          puts 1
        RUBY
      end
    end

    context 'when uppercase' do
      let(:value_capitalization) { 'uppercase' }

      it 'registers an offense and corrects when the case does not match' do
        expect_offense(<<~RUBY)
          # encoding: UtF-8
                      ^^^^^ Prefer uppercase for magic comment values.
          puts 1
        RUBY

        expect_correction(<<~RUBY)
          # encoding: UTF-8
          puts 1
        RUBY
      end
    end
  end

  context 'all issues at once' do
    let(:enforced_style) { 'snake_case' }
    let(:directive_capitalization) { 'uppercase' }
    let(:value_capitalization) { 'lowercase' }

    it 'registers and corrects multiple issues' do
      expect_offense(<<~RUBY)
        # frozen-STRING-literal: TRUE
                                 ^^^^ Prefer lowercase for magic comment values.
          ^^^^^^^^^^^^^^^^^^^^^ Prefer upper snake case for magic comments.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # FROZEN_STRING_LITERAL: true
        puts 1
      RUBY
    end
  end
end
