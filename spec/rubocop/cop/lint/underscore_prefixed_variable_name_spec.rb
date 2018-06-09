# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnderscorePrefixedVariableName do
  subject(:cop) { described_class.new }

  context 'when an underscore-prefixed variable is used' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def some_method
          _foo = 1
          ^^^^ Do not use prefix `_` for a variable that is used.
          puts _foo
        end
      RUBY
    end
  end

  context 'when non-underscore-prefixed variable is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def some_method
          foo = 1
          puts foo
        end
      RUBY
    end
  end

  context 'when an underscore-prefixed variable is reassigned' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def some_method
          _foo = 1
          _foo = 2
        end
      RUBY
    end
  end

  context 'when an underscore-prefixed method argument is used' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def some_method(_foo)
                        ^^^^ Do not use prefix `_` for a variable that is used.
          puts _foo
        end
      RUBY
    end
  end

  context 'when an underscore-prefixed block argument is used' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        1.times do |_foo|
                    ^^^^ Do not use prefix `_` for a variable that is used.
          puts _foo
        end
      RUBY
    end
  end

  context 'when an underscore-prefixed variable in top-level scope is used' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        _foo = 1
        ^^^^ Do not use prefix `_` for a variable that is used.
        puts _foo
      RUBY
    end
  end

  context 'when an underscore-prefixed variable is captured by a block' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        _foo = 1
        1.times do
          _foo = 2
        end
      RUBY
    end
  end

  context 'when an underscore-prefixed named capture variable is used' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        /(?<_foo>\\w+)/ =~ 'FOO'
        ^^^^^^^^^^^^^^ Do not use prefix `_` for a variable that is used.
        puts _foo
      RUBY
    end
  end

  %w[super binding].each do |keyword|
    context "in a method calling `#{keyword}` without arguments" do
      context 'when an underscore-prefixed argument is not used explicitly' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            def some_method(*_)
              #{keyword}
            end
          RUBY
        end
      end

      context 'when an underscore-prefixed argument is used explicitly' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            def some_method(*_)
                             ^ Do not use prefix `_` for a variable that is used.
              #{keyword}
              puts _
            end
          RUBY
        end
      end
    end

    context "in a method calling `#{keyword}` with arguments" do
      context 'when an underscore-prefixed argument is not used' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            def some_method(*_)
              #{keyword}(:something)
            end
          RUBY
        end
      end

      context 'when an underscore-prefixed argument is used explicitly' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            def some_method(*_)
                             ^ Do not use prefix `_` for a variable that is used.
              #{keyword}(*_)
            end
          RUBY
        end
      end
    end
  end
end
