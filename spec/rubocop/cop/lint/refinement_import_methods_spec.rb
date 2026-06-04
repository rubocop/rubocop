# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RefinementImportMethods, :config do
  # The "deprecated in Ruby 3.1" wording only applies when the target is exactly 3.1.
  # Prism floors the target Ruby to a higher version, so these run on Parser only.
  context 'Ruby 3.1', :ruby31, unsupported_on: :prism do
    it 'registers an offense and corrects when using `include` in `refine` block' do
      expect_offense(<<~RUBY)
        refine Foo do
          include Bar
          ^^^^^^^ Use `import_methods` instead of `include` because it is deprecated in Ruby 3.1.
        end
      RUBY

      expect_correction(<<~RUBY)
        refine Foo do
          import_methods Bar
        end
      RUBY
    end

    it 'registers an offense and corrects when using `prepend` in `refine` block' do
      expect_offense(<<~RUBY)
        refine Foo do
          prepend Bar
          ^^^^^^^ Use `import_methods` instead of `prepend` because it is deprecated in Ruby 3.1.
        end
      RUBY

      expect_correction(<<~RUBY)
        refine Foo do
          import_methods Bar
        end
      RUBY
    end
  end

  context 'Ruby >= 3.1', :ruby31 do
    it 'does not register an offense when using `import_methods` in `refine` block' do
      expect_no_offenses(<<~RUBY)
        refine Foo do
          import_methods Bar
        end
      RUBY
    end

    it 'does not register an offense when using `include` with a receiver in `refine` block' do
      expect_no_offenses(<<~RUBY)
        refine Foo do
          Bar.include Baz
        end
      RUBY
    end

    it 'does not register an offense when using `include` on the top level' do
      expect_no_offenses(<<~RUBY)
        include Foo
      RUBY
    end
  end

  context 'Ruby >= 3.2', :ruby32 do
    it 'reports that `include` was removed and corrects' do
      expect_offense(<<~RUBY)
        refine Foo do
          include Bar
          ^^^^^^^ Use `import_methods` instead of `include` because it was removed in Ruby 3.2.
        end
      RUBY

      expect_correction(<<~RUBY)
        refine Foo do
          import_methods Bar
        end
      RUBY
    end

    it 'reports that `prepend` was removed and corrects' do
      expect_offense(<<~RUBY)
        refine Foo do
          prepend Bar
          ^^^^^^^ Use `import_methods` instead of `prepend` because it was removed in Ruby 3.2.
        end
      RUBY

      expect_correction(<<~RUBY)
        refine Foo do
          import_methods Bar
        end
      RUBY
    end
  end

  context 'Ruby <= 3.0', :ruby30, unsupported_on: :prism do
    it 'does not register an offense when using `include` in `refine` block' do
      expect_no_offenses(<<~RUBY)
        refine Foo do
          include Bar
        end
      RUBY
    end

    it 'does not register an offense when using `prepend` in `refine` block' do
      expect_no_offenses(<<~RUBY)
        refine Foo do
          prepend Bar
        end
      RUBY
    end
  end
end
