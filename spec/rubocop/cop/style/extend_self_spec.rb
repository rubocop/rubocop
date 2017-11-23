# frozen_string_literal: true

describe RuboCop::Cop::Style::ExtendSelf, :config do
  subject(:cop) { described_class.new(config) }

  context 'when configured to enforce `module_function` style' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'module_function'
      }
    end

    it 'registers an offense when used alone in a module' do
      expect_offense(<<-RUBY.strip_indent)
        module Foo
          extend self
          ^^^^^^^^^^^ Use `module_function` instead of `extend self`.
        end
      RUBY
    end

    it 'registers an offense when used alone in a module wrapped in begin' do
      expect_offense(<<-RUBY.strip_indent)
        module Foo
          begin
            extend self
            ^^^^^^^^^^^ Use `module_function` instead of `extend self`.
          end
        end
      RUBY
    end

    it 'registers an offense when used with other statements in a module' do
      expect_offense(<<-RUBY.strip_indent)
        module Foo
          extend self
          ^^^^^^^^^^^ Use `module_function` instead of `extend self`.

          def bar; end
        end
      RUBY
    end

    it 'does not register an offense when used in a class nested in a module' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module Foo
          class Bar
            extend self
          end
        end
      RUBY
    end

    it 'auto-corrects `extend self` to `module_function` when used alone' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        module Foo
          extend self
        end
      RUBY

      expected_source = <<-RUBY.strip_indent
        module Foo
          module_function
        end
      RUBY

      expect(new_source).to eq(expected_source)
    end

    it 'auto-corrects `extend self` to `module_function`' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        module Foo
          extend self

          def foo; end
        end
      RUBY

      expected_source = <<-RUBY.strip_indent
        module Foo
          module_function

          def foo; end
        end
      RUBY

      expect(new_source).to eq(expected_source)
    end
  end

  context 'when configured to enforce `extend self` style' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'extend_self'
      }
    end

    it 'registers an offense when used alone in a module' do
      expect_offense(<<-RUBY.strip_indent)
        module Foo
          module_function
          ^^^^^^^^^^^^^^^ Use `extend self` instead of `module_function`.
        end
      RUBY
    end

    it 'registers an offense when used alone in a module wrapped in begin' do
      expect_offense(<<-RUBY.strip_indent)
        module Foo
          begin
            module_function
            ^^^^^^^^^^^^^^^ Use `extend self` instead of `module_function`.
          end
        end
      RUBY
    end

    it 'registers an offense when used with other statements in a module' do
      expect_offense(<<-RUBY.strip_indent)
        module Foo
          module_function
          ^^^^^^^^^^^^^^^ Use `extend self` instead of `module_function`.

          def bar; end
        end
      RUBY
    end

    it 'does not register an offense when used in a class nested in a module' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module Foo
          class Bar
            module_function
          end
        end
      RUBY
    end

    it 'auto-corrects `extend self` to `module_function` when used alone' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        module Foo
          module_function
        end
      RUBY

      expected_source = <<-RUBY.strip_indent
        module Foo
          extend self
        end
      RUBY

      expect(new_source).to eq(expected_source)
    end

    it 'auto-corrects `extend self` to `module_function`' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        module Foo
          module_function

          def foo; end
        end
      RUBY

      expected_source = <<-RUBY.strip_indent
        module Foo
          extend self

          def foo; end
        end
      RUBY

      expect(new_source).to eq(expected_source)
    end
  end
end
