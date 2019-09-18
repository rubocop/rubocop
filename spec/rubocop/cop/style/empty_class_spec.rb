# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyClass, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'error class' do
    it 'add an offense when using error class definition with empty body' do
      expect_offense(<<~RUBY)
        class FooError < StandardError
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a single-line format for class definitions with no body.
        end
      RUBY
    end

    it 'ignores one line error class definition' do
      expect_no_offenses(<<~RUBY)
        class FooError < StandardError; end
      RUBY
    end

    it 'ignores error class with body' do
      expect_no_offenses(<<~RUBY)
        class FooError < StandardError
          def catch
          end
        end
      RUBY
    end
  end

  shared_examples 'exception class' do
    it 'add an offense when using exception class definition with empty body' do
      expect_offense(<<~RUBY)
        class SignalException < Cop
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a single-line format for class definitions with no body.
        end
      RUBY
    end

    it 'ignores one line exception class definition' do
      expect_no_offenses(<<~RUBY)
        class SignalException < Cop; end
      RUBY
    end

    it 'ignores exception class with body' do
      expect_no_offenses(<<~RUBY)
        class SignalException < Cop
          def catch
          end
        end
      RUBY
    end
  end

  shared_examples 'autocorrect error-exception class' do
    it 'autocorrects error class' do
      corrected = autocorrect_source(<<~RUBY)
        class FooError < StandardError
        end
      RUBY

      expect(corrected).to eq(<<~RUBY)
        class FooError < StandardError; end
      RUBY
    end

    it 'autocorrects exception class' do
      corrected = autocorrect_source(<<~RUBY)
        class SignalException < Cop
        end
      RUBY

      expect(corrected).to eq(<<~RUBY)
        class SignalException < Cop; end
      RUBY
    end
  end

  context 'when `ExceptionClassOnly` true' do
    let(:cop_config) { { 'ExceptionClassOnly' => true } }

    include_examples 'error class'
    include_examples 'exception class'
    include_examples 'autocorrect error-exception class'

    it 'ignores class definition with empty body' do
      expect_no_offenses(<<~RUBY)
        class Foo < Base
        end
      RUBY
    end

    it 'ignores one line class definition' do
      expect_no_offenses(<<~RUBY)
        class Foo < Bar; end
      RUBY
    end

    it 'ignores class with body' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def catch
          end
        end
      RUBY
    end

    it 'ignores regular class' do
      corrected = autocorrect_source(<<~RUBY)
        class Foo < Bar
        end
      RUBY

      expect(corrected).to eq(<<~RUBY)
        class Foo < Bar
        end
      RUBY
    end
  end

  context 'when `ExceptionClassOnly` false' do
    let(:cop_config) { { 'ExceptionClassOnly' => false } }

    include_examples 'error class'
    include_examples 'exception class'
    include_examples 'autocorrect error-exception class'

    it 'add an offense for class without body' do
      expect_offense(<<~RUBY)
        class Foo < Base
        ^^^^^^^^^^^^^^^^ Use a single-line format for class definitions with no body.
        end
      RUBY
    end

    it 'ignores one line class definition' do
      expect_no_offenses(<<~RUBY)
        class Foo < Bar; end
      RUBY
    end

    it 'add an offense when using class definition with empty ' \
      'body without parent' do
      expect_offense(<<~RUBY)
        class Foo::Name
        ^^^^^^^^^^^^^^^ Use a single-line format for class definitions with no body.
        end
      RUBY
    end

    it 'registers an offense when using nested class definition with empty ' \
      'body' do
      expect_offense(<<~RUBY)
        class Foo::Name < Parent
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use a single-line format for class definitions with no body.
        end
      RUBY
    end

    it 'corrected regular class' do
      corrected = autocorrect_source(<<~RUBY)
        class Foo < Bar
        end
      RUBY

      expect(corrected).to eq(<<~RUBY)
        class Foo < Bar; end
      RUBY
    end
  end
end
