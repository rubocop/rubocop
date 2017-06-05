# frozen_string_literal: true

describe RuboCop::Cop::Style::ModuleFunction, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is `module_function`' do
    let(:cop_config) { { 'EnforcedStyle' => 'module_function' } }

    it 'registers an offense for `extend self` in a module' do
      expect_offense(<<-RUBY.strip_indent)
        module Test
          extend self
          ^^^^^^^^^^^ Use `module_function` instead of `extend self`.
          def test; end
        end
      RUBY
    end

    it 'accepts `extend self` in a class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test
          extend self
        end
      RUBY
    end
  end

  context 'when enforced style is `extend_self`' do
    let(:cop_config) { { 'EnforcedStyle' => 'extend_self' } }

    it 'registers an offense for `module_function` without an argument' do
      expect_offense(<<-RUBY.strip_indent)
        module Test
          module_function
          ^^^^^^^^^^^^^^^ Use `extend self` instead of `module_function`.
          def test; end
        end
      RUBY
    end

    it 'accepts module_function with an argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module Test
          def test; end
          module_function :test
        end
      RUBY
    end
  end
end
