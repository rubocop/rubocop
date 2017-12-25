# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense for methods using a class name' do
    expect_offense(<<-RUBY.strip_indent)
      class Test
        def Test.some_method
            ^^^^ Use `self.some_method` instead of `Test.some_method`.
          do_something
        end
      end
    RUBY
  end

  it 'registers an offense for methods using a module name' do
    expect_offense(<<-RUBY.strip_indent)
      module Test
        def Test.some_method
            ^^^^ Use `self.some_method` instead of `Test.some_method`.
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense for methods using self' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module Test
        def self.some_method
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense for other top-level singleton methods' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Test
        X = Something.new

        def X.some_method
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense outside class/module bodies' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def Test.some_method
        do_something
      end
    RUBY
  end

  it 'autocorrects class name to self' do
    src = <<-RUBY.strip_indent
      class Test
        def Test.some_method
          do_something
        end
      end
    RUBY

    correct_source = <<-RUBY.strip_indent
      class Test
        def self.some_method
          do_something
        end
      end
    RUBY

    new_source = autocorrect_source(src)
    expect(new_source).to eq(correct_source)
  end
end
