# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NonNilCheck, :config do
  context 'when not allowing semantic changes' do
    let(:cop_config) { { 'IncludeSemanticChanges' => false } }

    it 'registers an offense for != nil' do
      expect_offense(<<~RUBY)
        x != nil
        ^^^^^^^^ Prefer `!x.nil?` over `x != nil`.
      RUBY

      expect_correction(<<~RUBY)
        !x.nil?
      RUBY
    end

    it 'does not register an offense for != 0' do
      expect_no_offenses('x != 0')
    end

    it 'does not register an offense for !x.nil?' do
      expect_no_offenses('!x.nil?')
    end

    it 'does not register an offense for not x.nil?' do
      expect_no_offenses('not x.nil?')
    end

    it 'does not register an offense if only expression in predicate' do
      expect_no_offenses(<<~RUBY)
        def signed_in?
          !current_user.nil?
        end
      RUBY
    end

    it 'does not register an offense if only expression in class predicate' do
      expect_no_offenses(<<~RUBY)
        def Test.signed_in?
          current_user != nil
        end
      RUBY
    end

    it 'does not register an offense if last expression in predicate' do
      expect_no_offenses(<<~RUBY)
        def signed_in?
          something
          current_user != nil
        end
      RUBY
    end

    it 'does not register an offense if last expression in class predicate' do
      expect_no_offenses(<<~RUBY)
        def Test.signed_in?
          something
          current_user != nil
        end
      RUBY
    end

    it 'does not register an offense with implicit receiver' do
      expect_no_offenses('!nil?')
    end

    it 'registers an offense but does not correct when the code was not modified' do
      expect_offense(<<~RUBY)
        return nil unless (line =~ //) != nil
                          ^^^^^^^^^^^^^^^^^^^ Prefer `!(line =~ //).nil?` over `(line =~ //) != nil`.
      RUBY

      expect_no_corrections
    end
  end

  context 'when allowing semantic changes' do
    let(:cop_config) { { 'IncludeSemanticChanges' => true } }

    it 'registers an offense for `!x.nil?`' do
      expect_offense(<<~RUBY)
        !x.nil?
        ^^^^^^^ Explicit non-nil checks are usually redundant.
      RUBY

      expect_correction(<<~RUBY)
        x
      RUBY
    end

    it 'registers an offense for unless x.nil?' do
      expect_offense(<<~RUBY)
        puts b unless x.nil?
                      ^^^^^^ Explicit non-nil checks are usually redundant.
      RUBY

      expect_correction(<<~RUBY)
        puts b if x
      RUBY
    end

    it 'does not register an offense for `x.nil?`' do
      expect_no_offenses('x.nil?')
    end

    it 'does not register an offense for `!x`' do
      expect_no_offenses('!x')
    end

    it 'registers an offense for `not x.nil?`' do
      expect_offense(<<~RUBY)
        not x.nil?
        ^^^^^^^^^^ Explicit non-nil checks are usually redundant.
      RUBY

      expect_correction(<<~RUBY)
        x
      RUBY
    end

    it 'does not blow up with ternary operators' do
      expect_no_offenses('my_var.nil? ? 1 : 0')
    end

    it 'autocorrects by changing `x != nil` to `x`' do
      expect_offense(<<~RUBY)
        x != nil
        ^^^^^^^^ Explicit non-nil checks are usually redundant.
      RUBY

      expect_correction(<<~RUBY)
        x
      RUBY
    end

    it 'does not blow up when autocorrecting implicit receiver' do
      expect_offense(<<~RUBY)
        !nil?
        ^^^^^ Explicit non-nil checks are usually redundant.
      RUBY

      expect_correction(<<~RUBY)
        self
      RUBY
    end

    it 'corrects code that would not be modified if IncludeSemanticChanges were false' do
      expect_offense(<<~RUBY)
        return nil unless (line =~ //) != nil
                          ^^^^^^^^^^^^^^^^^^^ Explicit non-nil checks are usually redundant.
      RUBY

      expect_correction(<<~RUBY)
        return nil unless (line =~ //)
      RUBY
    end
  end

  context 'when `EnforcedStyle: comparison` of `Style/NilComparison` cop' do
    let(:other_cops) { { 'Style/NilComparison' => { 'EnforcedStyle' => 'comparison' } } }

    context '`IncludeSemanticChanges: false`' do
      let(:cop_config) { { 'IncludeSemanticChanges' => false } }

      it 'does not register an offense for `foo != nil`' do
        expect_no_offenses('foo != nil')
      end
    end

    context '`IncludeSemanticChanges: true`' do
      let(:cop_config) { { 'IncludeSemanticChanges' => true } }

      it 'registers an offense for `foo != nil`' do
        expect_offense(<<~RUBY)
          foo != nil
          ^^^^^^^^^^ Explicit non-nil checks are usually redundant.
        RUBY

        expect_correction(<<~RUBY)
          foo
        RUBY
      end
    end
  end
end
